# httpx

最近看到朋友在聊支持 h2 的 http 客户端, 因为之前用过这个库, 便打算看一下源代码实现.

httpx 本身并没有实现 h1 和 h2 的协议, 而是在 `HTTPTransport` 里调用了 `httpcore` 来完成网络通信层.

httpx 的`Request` 、`Response`的结构是借鉴`requests`的,  在`httpx/_status_codes` 源码内甚至有对`requests`的兼容性处理.

## 基于 httpx 的数据 mock

### WSGITransport 和 ASGITransport

httpx 设计了 BaseTransport 类来处理请求.

在看 httpx.Client 和 httpx.AsyncClient 的参数时, 意外发现了 app 参数.

阅读源码后发现, httpx 通过 `WSGITransport` 和 `ASGITransport` 分别实现了`wsgi`和`asgi`协议.

也就是说, httpx 是支持将请求发送到指定的 `WSGI` 或 `ASGI` 对象来获得响应结果, 而不是通过网络去发起真实的 HTTP 请求.

这个特性让我想到了可以用来实现数据的 mock.

### 如何处理注册事件

在以 `FastAPI` 作为框架写测试代码的时候, 遇到了一个问题, 就是本应在应用启动时的注册事件, 并没有执行.

而路由处理函数是依赖这些注册事件的, 那么该如何启动 FastApi 的注册事件?

通过阅读`uvicorn`的源码`uvicorn.lifespan.on.LifespanOn`发现, 协议服务器是通过将 `lifespan` 事件传递给`ASGI`,如`lifespan.startup`和`lifespan.shutdown`来管理 ASGI 对象的生命周期, 那么只要模拟这个行为就可以了.

### 代码示例

<details>
<summary>Example</summary>

```python
import asyncio
import logging

import httpx

from fastapi import APIRouter, Header

from core.app import create_app
from core.asgi import LifespanEvent
from core.router import CustomAPIRoute

logger = logging.getLogger()
router = APIRouter(route_class=CustomAPIRoute, tags=["mock"])


@router.get("/mock")
async def index(host: str = Header(None), ):
    return {"message": "ok", "code": 0, "data": {"host": host}}


def app():
    return create_app([router])


if __name__ == "__main__":
    loop = asyncio.get_event_loop()
    lifespan = LifespanEvent(app(), loop)

    loop.run_until_complete(lifespan.startup())
    client = httpx.AsyncClient(app=lifespan.app)
    url = f'http://host_or_address/mock'
    res: httpx.Response = asyncio.run(client.get(url))
    print(res.json())

    loop.run_until_complete(lifespan.shutdown())

```

</details>

<details>
<summary>Example</summary>

```python
import asyncio

from enum import Enum
from typing import Optional

from fastapi import FastAPI


class LifespanType(Enum):
    main: str = "lifespan"

    startup: str = "lifespan.startup"
    startup_complete: str = "lifespan.startup.complete"
    startup_failed: str = "lifespan.startup.failed"

    shutdown: str = "lifespan.shutdown"
    shutdown_complete: str = "lifespan.shutdown.complete"
    shutdown_failed: str = "lifespan.shutdown.failed"


class LifespanEvent:
    """通过 Lifespan 管理 ASGIApplication 的事件注册和注销

    为了让 ASGIApplication 能正确的提供服务,  httpx.ASGITransport 在使用ASGIApplication 之前,
    必须通过 startup 和 shutdown 进行事件注册和注销.
    """

    def __init__(self, app: FastAPI, loop: Optional[asyncio.events.AbstractEventLoop] = None):

        self.app = app
        self.loop = loop if loop is not None else asyncio.get_event_loop()
        self.receive_queue: asyncio.Queue = asyncio.Queue()
        self.startup_event = asyncio.Event()
        self.shutdown_event = asyncio.Event()
        self.main_task: Optional[asyncio.Task] = None

    async def receive(self):
        return await self.receive_queue.get()

    async def send(self, message: dict):
        body = message.get("message")
        assert message['type'] in (
            "lifespan.startup.complete",
            "lifespan.startup.failed",
            "lifespan.shutdown.complete",
            "lifespan.shutdown.failed",
        )
        startup_events = (LifespanType.startup_complete.value, LifespanType.startup_complete.value)
        if message['type'] in startup_events:
            assert not self.startup_event.is_set() and not self.shutdown_event.is_set()
            self.startup_event.set()

            if message['type'] == LifespanType.startup_failed:
                print(f"startup_failed: {body}")

        shutdown_events = (LifespanType.shutdown_complete.value, LifespanType.shutdown_failed.value)
        if message['type'] in shutdown_events:
            assert self.startup_event.is_set() and not self.shutdown_event.is_set()
            self.shutdown_event.set()

            if message['type'] == LifespanType.shutdown_failed:
                print(f"shutdown_failed: {body}")

    async def startup(self):
        self.main_task = self.loop.create_task(self.main())
        startup_event = {"type": LifespanType.startup.value}
        await self.receive_queue.put(startup_event)
        await self.startup_event.wait()

    async def shutdown(self):
        shutdown_event = {"type": LifespanType.shutdown.value}
        await self.receive_queue.put(shutdown_event)
        await self.shutdown_event.wait()

    async def main(self):
        scope = {
            "type": LifespanType.main.value,
            "asgi": {
                "version": "asgi3",
                "spec_version": "2.0"
            },
        }
        await self.app(scope, self.receive, self.send)

```

</details>

## 基于猴子补丁修改内部行为

<details>
<summary>关闭证书验证</summary>

```python
import asyncio
from typing import Callable
from functools import wraps

import httpx


class _PatchClient(httpx.Client):
    def __init__(self, *args, **kwargs):
        kwargs["verify"] = False
        super().__init__(*args, **kwargs)


class _PatchAsyncClient(httpx.AsyncClient):
    def __init__(self, *args, **kwargs):
        kwargs["verify"] = False
        super().__init__(*args, **kwargs)


def _patch_request(func: Callable):
    @wraps(func)
    def request(*args, **kwargs):
        kwargs["verify"] = False
        return func(*args, **kwargs)

    return request


def patch():
    httpx._api.request = _patch_request(httpx._api.request)
    httpx.Client = _PatchClient
    httpx.AsyncClient = _PatchAsyncClient


def main():
    patch()
    url = "https://httpbin.org/get"
    httpx.get(url)
    httpx.Client().get(url)
    asyncio.run(httpx.AsyncClient().get(url))


if __name__ == "__main__":
    main()
```

</details>

### 使用 pth 文件注入插件

- <https://github.com/qsoyq/httpx-disable-verify>

```bash
pip install git+https://github.com/qsoyq/httpx-disable-verify.git
python -m httpx_disable_verify install
```

## 重试装饰器

对特定的状态码和 httpx 内部的网络异常进行重试。

<details>
<summary>查看代码示例</summary>

```python
import logging
import time
from collections.abc import Callable
from functools import wraps
from typing import Any

import httpx

logger = logging.getLogger(__file__)


def retry_http(
    *,
    max_attempts: int = 3,
    retry_backoff_seconds: float = 0,
    retry_on_status: Callable[[int], bool] | None = None,
    log_prefix: str = "[ retry_http ]",
) -> Callable[[Callable[..., httpx.Response]], Callable[..., httpx.Response]]:
    """内部捕获 HTTPX 请求导致的网络或状态码异常

    重试最多 max_attempts 次
    重试等待间隔根据 retry_backoff_seconds 计算, 每次等待时间 = retry_backoff_seconds * attempt
    如果 retry_on_status 返回 True, 则重试, 默认对于状态码大于等于 500 的进行重试
    内部不会因为状态码而抛出异常, 仅会抛出因为重试达到上限后遇到的 httpx 内部网络异常
    """
    max_attempts = max(1, max_attempts)

    def _default_retry_on_status(status_code: int) -> bool:
        return 500 <= status_code

    if retry_on_status is None:
        retry_on_status = _default_retry_on_status

    def decorator(func: Callable[..., httpx.Response]) -> Callable[..., httpx.Response]:
        @wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> httpx.Response:
            for attempt in range(1, max_attempts + 1):
                wait_seconds = retry_backoff_seconds * attempt
                try:
                    resp = func(*args, **kwargs)
                    if retry_on_status(resp.status_code):
                        if attempt < max_attempts:
                            logger.warning(f"{log_prefix} HTTP {resp.status_code}，准备重试 {attempt}/{max_attempts}")
                            if retry_backoff_seconds:
                                time.sleep(wait_seconds)
                            continue
                        else:
                            logger.warning(f"{log_prefix} 请求失败 {resp.status_code} {resp.text}")
                            return resp
                    return resp
                except httpx.HTTPError as exc:
                    if attempt < max_attempts:
                        logger.warning(f"{log_prefix} 请求异常，准备重试 {attempt}/{max_attempts}: {exc}")
                        if retry_backoff_seconds:
                            time.sleep(wait_seconds)
                        continue
                    raise exc
            raise RuntimeError(f"{log_prefix} 未预期执行到重试逻辑末尾")

        return wrapper

    return decorator

```

</details>
