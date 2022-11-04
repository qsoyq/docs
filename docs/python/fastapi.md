# fastapi

[fastapi](https://fastapi.tiangolo.com/)

## Dependencies

最近在实现 `SetTraceId` 的中间件, 想法是在 ASGI Middleware 中, 在 scope 里检查 headers, 并写入一个 TraceId. 然后在 dependiences 中, 强制检查 X-Request-Trace-Id 这个标头.

大致代码如下

```python
from contextvars import ContextVar

from starlette.types import ASGIApp, Message, Receive, Scope, Send

from utils.snowflake import Snowflake

TRACE_ID: ContextVar[bytes] = ContextVar("TraceId")
SEND_VAR: ContextVar[Send] = ContextVar('Send callable')
REQ_KEY = b"X-Request-Trace-Id"
RES_KEY = b"X-Response-Trace-Id"


class SetTraceIdMiddleware:
    """为请求和响应添加 traceid"""

    def __init__(
        self,
        app: ASGIApp,
        **options,
    ) -> None:
        self.app = app

    async def send(self, message: Message):
        _send = SEND_VAR.get()

        if message['type'] == 'http.response.start':
            headers = message['headers']
            for key, _ in headers:
                if key == RES_KEY:
                    break
            else:
                headers.append((RES_KEY, TRACE_ID.get()))

        await _send(message)

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        for k, v in scope['headers']:
            if k == REQ_KEY:
                break
        else:
            global TRACE_ID
            trace_id = str(Snowflake().generate()).encode('ascii')
            TRACE_ID.set(trace_id)
            scope['headers'].append((REQ_KEY, trace_id))


        if scope['type'] != 'http':
            await self.app(scope, receive, send)
            return

        global
        SEND_VAR.set(send)
        await self.app(scope, receive, self.send)

```

这样调用方可以传入 TraceId, 也可以由服务在中间件里生成一个.

### 未预料到的现象

---

```python
from fastapi import Header, Request

async def check_x_request_trace_id(
    req: Request,
    trace_id: int = Header(None,
                           alias='X-Request-Trace-Id',
                           title='全局请求链路跟踪id',
                           description='不存在时, 中间件会自动分配'),
):
    print('headers', trace_id, req.scope['headers'])

```

但是结果不如人意. 在上面的代码中, trace_id 实际是 None, 而访问 scope 对象中的 headers, 又是实际存在由中间件写入的 `X-Request-Trace-Id` 标头的.

从结果上看, `check_x_request_trace_id` 的调用是发生在用户中间件之后.

那么 fastapi 内 dependencies 为 `check_x_request_trace_id`绑定参数的行为发生在中间件之前, 也可能使用了一个深拷贝的 scope.headers 对象.

接下来就需要深入源码去寻找答案了.

### FastAPI 调用链

根据 `FastAPI.__call__`和 `Starlette.__call__` 可知, 在 FastAPI 中, ASGI Application 的调用顺序如下

1. `ServerErrorMiddleware`、
2. `user_middleware`、
3. `ExceptionMiddleware`
4. `Router`
    1. `Route`

传递给 FastAPI 的`dependencies` 会随着 `APIRouter` 向下传递到 `APIRoute`, 而 `APIRoute` 就是最终匹配到并会执行 `endpoint`.

而 `fastapi.routing.APIRouter` 并没有实现`__call__`, 而是继承了`starlette.routing.Router` 的 `__call__` 实现.

同样, `fastapi.routing.APIRoute` 的 `__call__`方法也是继承自 `starlette.routing.BaseRoute`.

### APIRoute 调用链

对于`APIRoute`的调用链如下:

1. APIRoute.__call__
2. starlette.routing.BaseRoute.__call__
3. starlette.routing.Route.handle
4. APIRoute.app

`APIRoute.app`实际上是调用了 `fastapi.routing.get_route_handler` 并经过`starlette.routing.request_response`装饰器来获得的可调用对象并传入 根据 scope 实例化的 request 对象来最终向上响应.

更明确的说, `fastapi.routing.get_request_handler.app` 就是最终真正去执行请求并向上响应的函数.

### Dependant 依赖传递

通过`APIRoute`实例化源码可以发现, `dependencies` 和 `endpoint` 都会被注入到 `APIRoute.dependant`对象中.

而`APIRoute.dependant`对象会被传递到 `fastapi.routing.get_request_handler.app` 内, 并通过`fastapi.dependencies.utils.solve_dependencies` 对请求和`dependencies`进行解析, 拿到`endpoint` 和 `dependencies` 依赖的请求参数.

### solve_dependencies 获得依赖值

通过阅读 `fastapi.dependencies.utils.solve_dependencies`的源代码发现, `solve_dependencies` 会遍历并逐个调用被注入到的`dependant`中的`dependencies`.

在 `solve_dependencies`中会分次调用`request_params_to_args`, 去获得对应 HTTP 请求中的`params`,`query`,`headers`,`cookies`

并且调用 `request_body_to_args` 去获得 `body` 参数的值.

在上述的调用中, 对应的 HTTP 请求参数都是通过 `fastapi.routing.get_request_handler.app` 的首个 `scope` 对象实例化生成.

所以要解决最初的问题, 就需要找到 `fastapi.routing.get_request_handler.app` 对象的 scope 参数是如何具体传递的

### 反思

在阅读上面的源码后, 基本可以推翻一开始的预测, `APIRoute.app`的调用顺序发生在中间件处理之后, 而 `scope` 对象也是由上层一步步传递下来.

那么问题大概就出现在 `solve_dependencies` 中从 `request_params_to_args` 解析 `headers` 参数的部分.

FastAPI 中实际的 Request 对象是从 `starlette.requests.Request` 导入的, 为了分析 `headers` 的解析逻辑, 下一步需要从这出发.

### starlette 对 headers 的解析规则

`starlette.requests.Request` 的基本行为都是继承自 `starlette.requests.HTTPConnection`.

而 `headers`是以 `scope` 作为参数的传递给 `starlette.datastructures.Headers`的实例化对象.

`starlette.datastructures.Headers` 对象保存了 `score["headers"]`对象

通过阅读源代码发现, `starlette.datastructures.Headers` 在读取元素的时候, 会将 key 转为小写, 再从 `_list` 里遍历读取.

### 结论

那么最终结果就非常明确了, 需要在中间件里写入标头的时候, 需要写入小写的 header name.

在做对应的修改后, 结果也正如预期.

而在[asgi-specs-http-connection-scope](https://asgi.readthedocs.io/en/latest/specs/www.html#http-connection-scope)中对于 `headers` 也的确有关于应该是小写的建议, 但不是强制的.

如果 `starlette.datastructures.Headers` 在构造 `_list` 对象的时候将 `scope` 内的 `headers` 全部小写处理, 或者在读取的时候做大小写适配, 应该是一种更好的策略.

### 补充

#### contextvars使用注意

`FastAPI` 并没有通过 `asyncio.Loop.call_later` 这种 API 来创建一个后台的协程去调用中间件或路由函数.

所以在`FastAPI`中, 所有中间件和路由函数的 `contextvars.Context` 上下文是共用当前线程而没有隔离的.

上面提到的中间件示例, 当存在并发时会有脏数据.
