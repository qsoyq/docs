# FastAPI

在五花八门的 Web HTTP 框架中，FastAPI 能脱颖而出，其实主要是集成了 `Pydantic`后带来的众多优势.

pydantic 是一个借助于类型注解，丰富了 Python 的类型功能, 对于 IDE 提示有了极为强大的提升.

而`FastAPI` 更是借助了 pydantic 做了很多依赖注入的功能，通过注解的类型，对参数进行类型转换和约束检查，在一众 Web 框架里都是极为突出方便的特性。

## FastAPI的优点

1. 集成了 `OpenAPI`, API 文档和运行时代码进行绑定，极大方便了开发过程中对于文档的维护.
2. 兼容同步阻塞的普通路由函数和异步协程函数, 对于不完善的协程生态，有了极大的兼容性.
3. 100% 类型注解的代码实现，对于用户，阅读源码实现，查找功能进行 diy 极为方便.

## FastAPI 的缺点

1. 底层 ASGI 协议实现是基于 [starlette](https://www.starlette.io/)
2. 因为 ASGI 协议导致的请求/响应对象处理方式，对于用户使用中间件等需要在路由函数外部消费请求/响应的场景, 容易有困惑

## 参考阅读

- [fastapi](https://fastapi.tiangolo.com/)
