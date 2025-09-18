# 路由函数

## 路由实现

### 编译

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

### 匹配

1. 首轮匹配
2. 次轮匹配
3. not_found

#### 首轮匹配

`starlette.routing.Router.app` 内触发路由匹配，根据匹配结果分为 `FULL`和`PARTIAL`

对于第一个全匹配的路由，则直接进入处理流程

遍历完路由后，如果没有全匹配的路由，则进入对一个部分匹配的路由函数

<details>

<summary>查看代码</summary>

```python
for route in self.routes:
    # Determine if any route matches the incoming scope,
    # and hand over to the matching route if found.
    match, child_scope = route.matches(scope)
    if match == Match.FULL:
        scope.update(child_scope)
        await route.handle(scope, receive, send)
        return
    elif match == Match.PARTIAL and partial is None:
        partial = route
        partial_scope = child_scope
```

</details>

#### 次轮匹配

如果在首轮遍历未能找到全匹配或部分匹配的路由函数, 则会根据设置，添加或移除尾斜杠`/`再进行第二轮匹配

次轮匹配对于第一个有效的匹配结果, 无论是完全匹配还是部分匹配, 都会以此返回重定向响应结果

<details>

<summary>查看代码</summary>

```python
route_path = get_route_path(scope)
if scope["type"] == "http" and self.redirect_slashes and route_path != "/":
    redirect_scope = dict(scope)
    if route_path.endswith("/"):
        redirect_scope["path"] = redirect_scope["path"].rstrip("/")
    else:
        redirect_scope["path"] = redirect_scope["path"] + "/"

    for route in self.routes:
        match, child_scope = route.matches(redirect_scope)
        if match != Match.NONE:
            redirect_url = URL(scope=redirect_scope)
            response = RedirectResponse(url=str(redirect_url))
            await response(scope, receive, send)
            return

await self.default(scope, receive, send)
```

</details>

#### 匹配失败

对于两轮匹配失败后，进入`not_found`

返回 404

<details>

<summary>查看代码</summary>

```python
async def not_found(self, scope: Scope, receive: Receive, send: Send) -> None:
    if scope["type"] == "websocket":
        websocket_close = WebSocketClose()
        await websocket_close(scope, receive, send)
        return

    # If we're running inside a starlette application then raise an
    # exception, so that the configurable exception handler can deal with
    # returning the response. For plain ASGI apps, just return the response.
    if "app" in scope:
        raise HTTPException(status_code=404)
    else:
        response = PlainTextResponse("Not Found", status_code=404)
    await response(scope, receive, send)
```

</details>

#### 匹配规则

匹配的具体行为由 `starlette.routing.Route.matches` 进行

<details>

<summary>查看代码</summary>

```python
def matches(self, scope: Scope) -> tuple[Match, Scope]:
    path_params: dict[str, Any]
    if scope["type"] == "http":
        route_path = get_route_path(scope)
        match = self.path_regex.match(route_path)
        if match:
            matched_params = match.groupdict()
            for key, value in matched_params.items():
                matched_params[key] = self.param_convertors[key].convert(value)
            path_params = dict(scope.get("path_params", {}))
            path_params.update(matched_params)
            child_scope = {"endpoint": self.endpoint, "path_params": path_params}
            if self.methods and scope["method"] not in self.methods:
                return Match.PARTIAL, child_scope
            else:
                return Match.FULL, child_scope
    return Match.NONE, {}
```

</details>

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

## 回顾

1. 路由根据添加顺序存储在列表，匹配时在第一个全匹配路由函数停止，否则会遍历.
