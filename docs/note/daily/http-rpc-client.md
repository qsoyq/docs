# http-rpc-client

对以 RESTful 风格设计的 API, 要提供 RPC 调用, 比较明显的缺点就是在 HTTP 请求/响应模式下, 服务器无法主动向客户端推送的尴尬问题.

将推送场景通过订阅模式, 单独提供 WebSocket 服务, 让用户端进行订阅.

而服务之间, 通过消息队列, 来订阅关注的数据流以达成异步的消息处理.

那么大多数的微服务 RPC 调用场景, 都不再强依赖服务器的主动推送功能.

而 grpc 基于 ProtoBuf 的格式定义, 也可以被 openapi.json 取代.

这种情况下, 基于 HTTP 的 RPC 调用, 需要解决的, 基本就是服务直接该如何发现和互相访问.

而基于 Traefik@docker 的微服务架构中, 所有服务注册到 Docker Engine, 通过暴露 Host 和 Path 等规则来提供反向代理.

那么对于 HTTP 客户端而言, 只需要能知晓 `traefik` 的访问地址, 以及 RPC 资源的 Host 和 Path.

至于params、body 等参数, 在业务代码里进行调用的时候传递即可.

以 HTTPX 的客户端封装为例

```python
from functools import partial
from typing import Any, Optional

from httpx import AsyncClient, Client

HTTP_METHODS = {'get', 'post', 'put', 'delete', 'options', 'head', 'patch'}


class BaseHTTPResource:
    SCHEME: str = 'http'
    HOST: str = 'localhost'
    PORT: Optional[int] = None
    SERVICE_NAME: str = ''
    PATH: str = ''

    def __init__(self, *args, **kwargs):
        headers = kwargs.get('headers')
        if headers is None:
            headers = {}
            kwargs['headers'] = headers

        headers['host'] = self.SERVICE_NAME if self.SERVICE_NAME else self.HOST
        super().__init__(*args, **kwargs)

    def __getattribute__(self, name: str) -> Any:
        result = super().__getattribute__(name)
        if name in HTTP_METHODS:
            port = self.PORT
            if port is None:
                port = 443 if self.SCHEME == 'https' else 80
            url = f'{self.SCHEME}://{self.HOST}:{port}{self.PATH}'
            result = partial(result, url=url)
        return result


class HTTPResource(BaseHTTPResource, Client):
    pass


class AsyncHTTPResource(BaseHTTPResource, AsyncClient):
    pass

```

核心思路是在实例化的时候根据`SERVICE_NAME` 注入 `host` 请求头, 作为`traefik` 反向代理的依据.

在实际调用请求的时候, 根据类属性, 注入 `url`.

那么在定义好表示 HTTP资源的类对象后, 对于实际调用者而言, 仅仅需要关心具体的请求参数和响应结果, 而不需要关心资源所在的目标地址.
