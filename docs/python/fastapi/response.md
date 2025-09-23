# 关于FastAPI的响应类

## 定制

### 将JSON响应指定 UTF-8 编码

在 Safari 中发现一些中文字符会出现编码， 调试发现默认返回的 `JSONResponse` 的`Content-Type`是`application/json`, 没有通过`charset`指定编码。

#### 通过类继承指定字符编码

通过查看源码可知， `Response` 类使用类属性`media_type` 设置初始的`Content-Type`

所以定制一个继承`JSONResponse`的类, 并重写`media_type` 即可。

此方法优点是非常直观, 缺点是必须通过手动在业务里返回或者通过修改方法注册装饰器的`response_class`属性来修改.

也可以在中间件重新构造响应类的方式来实现.

<details>

<summary>查看代码</summary>

`init_headers` 设置响应头

```python
    def init_headers(self, headers: Mapping[str, str] | None = None) -> None:
        if headers is None:
            raw_headers: list[tuple[bytes, bytes]] = []
            populate_content_length = True
            populate_content_type = True
        else:
            raw_headers = [(k.lower().encode("latin-1"), v.encode("latin-1")) for k, v in headers.items()]
            keys = [h[0] for h in raw_headers]
            populate_content_length = b"content-length" not in keys
            populate_content_type = b"content-type" not in keys

        body = getattr(self, "body", None)
        if (
            body is not None
            and populate_content_length
            and not (self.status_code < 200 or self.status_code in (204, 304))
        ):
            content_length = str(len(body))
            raw_headers.append((b"content-length", content_length.encode("latin-1")))

        content_type = self.media_type
        if content_type is not None and populate_content_type:
            if content_type.startswith("text/") and "charset=" not in content_type.lower():
                content_type += "; charset=" + self.charset
            raw_headers.append((b"content-type", content_type.encode("latin-1")))

        self.raw_headers = raw_headers

```

继承类修改响应类型

```python
import json
from fastapi.responses import JSONResponse

class PrettyJSONResponse(JSONResponse):
    media_type = "application/json;charset=utf-8"

    def render(self, content: dict) -> bytes:
        return json.dumps(content, indent=4, ensure_ascii=False).encode("utf-8")
```

中间件修改响应类

```python
class UsePrettryJSONResponse(BaseHTTPMiddleware):
    async def dispatch(
        self, request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ) -> Response | JSONResponse:
        response = await call_next(request)
        ct = response.headers.get("content-type")
        if ct and ct.startswith("application/json"):
            response_body = b""
            async for chunk in response.body_iterator:  # type: ignore
                response_body += chunk
            body = json.loads(response_body)
            headers = dict(response.headers)
            headers.pop("content-length", None)
            return PrettyJSONResponse(body, status_code=response.status_code, headers=headers)
        return response

```

</details>

#### 通过中间件修改响应头

另外一种更直接的做法是在中间件里对所有响应重写，为响应头的`Content-Type`加上指定编码

<details>

<summary>查看代码</summary>

```python
class AddCharsetToJSONMiddleware(BaseHTTPMiddleware):
    content_type: str = "application/json;charset=utf-8"

    async def dispatch(
        self, request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ) -> Response | JSONResponse:
        response = await call_next(request)
        ct = response.headers.get("content-type")
        if ct and ct.startswith("application/json"):
            response_body = b""
            async for chunk in response.body_iterator:  # type: ignore
                response_body += chunk
            body = json.loads(response_body)
            headers = dict(response.headers)
            headers.pop("content-length", None)
            headers["content-type"] = self.__class__.content_type
            return JSONResponse(body, status_code=response.status_code, headers=headers)
        return response
```

</details>
