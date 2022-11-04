# Pep

## Key-Sharing Dictionary

[Key-Sharing Dictionary](https://peps.python.org/pep-0412/)

## Specifying Minimum Build System Requirements for Python Projects

[PyProject](https://www.python.org/dev/peps/pep-0518/)

通过一个`toml`格式的配置文件来描述项目的构建依赖.

包括包管理, 各种命令行工具依赖, 项目描述信息等.

## Context Variables

[Context Variables](https://peps.python.org/pep-0567/)

提供类似`Thread-Local`的能支持协程环境的上下文管理模块.

`Contextvars` 模块 提供了 `Context`、`ContextVar`、`Token` 来实现功能.

`ContextVar`实例化后的对象都会绑定当当前线程的 `Context`.

创建 `ContextVar` 之后, 会返回`Token`对象. `Token`对象保存了`ContextVar`的旧值和当前值. 每次对`ContextVar`实例进行`reset`, 会对比`ContextVar`实例中的值和`Token`中的值.

`Contextvars.copy_context` 会将当前线程绑定的`Context`进行浅拷贝返回.

以下四个方法都会在内部调用`Contextvars.copy_context`, 以便于继承当前线程的上下文, 并保证子线程的上下文之间是隔离的.

- `asyncio.Loop.call_at()`
- `asyncio.Loop.call_later()`
- `asyncio.Loop.call_soon()`
- `asyncio.Future.add_done_callback()`

`Context`提供了 `run`方法, 以方便手动在某个指定的上下文中进行函数调用.

### 注意事项

1. `Token`不能跨`Context`使用, 且每个`Token`.
2. `ContextVar` 在调用`reset`方法时, 只会检查`Token`的值会当前变量的值, 以及上下文是否一致, 并没有别的机制保障当前变量在`set`的时候所返回的`Toekn`一致.  所以可能存在使用错误的`Token`对象但恢复了预期的值.
3. `Context.run` 中指定的上下文不能是当前系统线程绑定的上下文.
4. 由于`Contextvars.copy_context`是将对象进行浅拷贝, 如果上下文对象中存在嵌套引用的对象, 需要额外的操作来保障上下文的隔离.
