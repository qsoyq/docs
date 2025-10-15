# migration

## 迁移 v2

### HttpUrl

#### 背景

在从 v1 迁移到 v2 的时候, 使用 `HttpUrl` 的模型遇到了异常

```bash
PydanticSerializationUnexpectedValue(Expected `<class 'pydantic.networks.HttpUrl'>` but got `<class 'str'>` with value `'https://github.com/NSRingo/WeatherKit/releases/tag/v1.8.6-rc3'` - serialized value may not be as expected.)
```

```bash
TypeError: Object of type HttpUrl is not JSON serializable
```

#### 分析

>In pydantic v1 urls inherited from str, so it can be easily passed to library codes, where they usually expects string representation of urls.

在某个版本, `pydantic` 对于 HttpUrl 的实现发生了改变。

原来 `HttpUrl` 是基于 `str` 的实现, 后续变成了一个自定义的 `Class`, 所以在传参和反序列化的时候都遇到了问题

#### 解决方案

HttpUrl

```python
from typing import Annotated
from pydantic import TypeAdapter, HttpUrl as _HttpUrl, BeforeValidator


HttpUrlTypeAdapter = TypeAdapter(_HttpUrl)
HttpUrl = Annotated[
    str,
    BeforeValidator(lambda value: HttpUrlTypeAdapter.validate_python(value) and value),
]
```

定义一个类型，作为 `str` 存储前以 `HttpUrl` 进行验证

#### 参考阅读

- [Work around for pydantic_core._pydantic_core.Url in V2 where string is expected](https://github.com/pydantic/pydantic/discussions/8211)
- [workaround](https://github.com/pydantic/pydantic/issues/7186#issuecomment-1874338146)
