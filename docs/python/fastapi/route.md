# 路由函数

## 路由实现

`starlette.routing.compile_path` 实现路由编译

```python
def compile_path(
    path: str,
) -> typing.Tuple[typing.Pattern, str, typing.Dict[str, Convertor]]:
    """
    Given a path string, like: "/{username:str}", return a three-tuple
    of (regex, format, {param_name:convertor}).

    regex:      "/(?P<username>[^/]+)"
    format:     "/{username}"
    convertors: {"username": StringConvertor()}
    """
```

## 函数注释

让函数文档注释的一部分出现在 openapi 的文档说明中，而不是全部。

### FastAPI 是如何从函数注释中提取文档部分的

`fastapi.openapi.utils.get_openapi_path` 读取了每个路由函数对应 openapi 的参数

从`fastapi.openapi.utils.get_openapi_operation_metadata`可知，API 的 `description` 对应 APIRoute.description。

而从`fastapi.routing.APIRoute` 源码可知， `OpenAPI` 默认会使用函数的`__doc__`的第一个`\f`字符的前缀部分, 并且使用了 `inspect.cleandoc` 格式化文档

<details>
<summary>查看完整代码</summary>

get_openapi_path

```python
operation = get_openapi_operation_metadata(
    route=route, method=method, operation_ids=operation_ids
)
```

get_openapi_operation_metadata

```python
def get_openapi_operation_metadata(
    *, route: routing.APIRoute, method: str, operation_ids: Set[str]
) -> Dict[str, Any]:
    operation: Dict[str, Any] = {}
    if route.tags:
        operation["tags"] = route.tags
    operation["summary"] = generate_operation_summary(route=route, method=method)
    if route.description:
        operation["description"] = route.description
    operation_id = route.operation_id or route.unique_id
    if operation_id in operation_ids:
        message = (
            f"Duplicate Operation ID {operation_id} for function "
            + f"{route.endpoint.__name__}"
        )
        file_name = getattr(route.endpoint, "__globals__", {}).get("__file__")
        if file_name:
            message += f" at {file_name}"
        warnings.warn(message, stacklevel=1)
    operation_ids.add(operation_id)
    operation["operationId"] = operation_id
    if route.deprecated:
        operation["deprecated"] = route.deprecated
    return operation
```

fastapi.routing.APIRoute.__init__

```python
self.description = description or inspect.cleandoc(self.endpoint.__doc__ or "")
# if a "form feed" character (page break) is found in the description text,
# truncate description text to the content preceding the first "form feed"
self.description = self.description.split("\f")[0].strip()
```

</details>

### 函数注释的正确姿势

```python
import uvicorn
from fastapi import FastAPI


app = FastAPI()


@app.get("/v1")
def v1():
    """应该出现在OpenAPI 内

    \f不应该出现在 OpenAPI 内
    """
    return ""

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

```

如代码所示，其中 v1 在文档中会看见不符合预期的内容

### 函数注释分段失效的原因

```python
import inspect


def v1():
    """应该出现在OpenAPI 内

    \f不应该出现在 OpenAPI 内
    """
    return ""


doc = v1.__doc__
assert doc
assert "\f" in doc
assert "\f" not in inspect.cleandoc(doc)
```

如上图所示参数代码, `inspect.cleandoc` 会导致行首的`\f`被清除

所以处理方式应该修改如下

```python
self.description = description or inspect.cleandoc(self.endpoint.__doc__.split("\f")[0]).strip() if self.endpoint.__doc__ else "" 
```
