# httpx

最近看到朋友在聊支持 h2 的 http 客户端, 因为之前用过这个库, 便打算看一下源代码实现.

httpx 本身并没有实现 h1 和 h2 的协议, 而是在 `HTTPTransport` 里调用了 `httpcore` 来完成网络通信层.

httpx 的`Request` 、`Response`的结构是借鉴`requests`的,  在`httpx/_status_codes` 源码内甚至有对`requests`的兼容性处理.

## WSGITransport 和 ASGITransport

httpx 设计了 BaseTransport 类来处理请求.

在看 httpx.Client 和 httpx.AsyncClient 的参数时, 意外发现了 app 参数.

阅读源码后发现, httpx 通过 `WSGITransport` 和 `ASGITransport` 分别实现了`wsgi`和`asgi`协议.

也就是说, httpx 是支持将请求发送到指定的 `WSGI` 或 `ASGI` 对象来获得响应结果, 而不是通过网络去发起真实的 HTTP 请求.

这个特性让我想到了可以用来实现数据的 mock.

## 基于 httpx 的数据 mock

#### 如何处理注册事件

在以 FastApi作为框架写测试代码的时候, 遇到了一个问题, 就是本应在应用启动时的注册事件, 并没有执行.

而路由处理函数是依赖这些注册事件的, 那么该如何启动 FastApi 的注册事件?

通过阅读`uvicorn`的源码`uvicorn.lifespan.on.LifespanOn`发现, 协议服务器是通过将 `lifespan` 事件传递给`ASGI`,如`lifespan.startup`和`lifespan.shutdown`来管理 ASGI 对象的生命周期, 那么只要模拟这个行为就可以了.

#### 代码示例

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
