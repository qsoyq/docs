# FastAPI 调用链

因为 `FastAPI` 底层的`Starlette`也是基于 ASGI 协议，所以同样是传递`scope, receive, send`三元组进入到调用栈

## ASGI 三元组

```python
ASGIApp = Callable[[Scope, Receive, Send], Awaitable[None]]
Scope = MutableMapping[str, Any]
Message = MutableMapping[str, Any]
Receive = Callable[[], Awaitable[Message]]
Send = Callable[[Message], Awaitable[None]]
```

1. FastAPI.__call__
2. Starlette.__call__
    1. middleware_stack
        1. ServerErrorMiddleware
        2. user_middleware
            1. starlette.middleware.Middleware.__call__
        3. ExceptionMiddleware.__call__
        4. fastapi.routing.APIRouter.__call__
        5. fastapi.routing.APIRouter.middleware_stack.__call__
        6. starlette.routing.Router.app.__call__
            1. starlette.routing.Router.lifespan
                1. fastapi.startup
                2. fastapi.shutdown
            2. route match
            3. default(not_found)

### build_middleware_stack

```python
    def build_middleware_stack(self) -> ASGIApp:
        debug = self.debug
        error_handler = None
        exception_handlers: dict[Any, ExceptionHandler] = {}

        for key, value in self.exception_handlers.items():
            if key in (500, Exception):
                error_handler = value
            else:
                exception_handlers[key] = value

        middleware = (
            [Middleware(ServerErrorMiddleware, handler=error_handler, debug=debug)]
            + self.user_middleware
            + [Middleware(ExceptionMiddleware, handlers=exception_handlers, debug=debug)]
        )

        app = self.router
        for cls, args, kwargs in reversed(middleware):
            app = cls(app, *args, **kwargs)
        return app
```
