# 中间件使用手册

## 修改返回内容

由于 ASGI 的处理流程, 推荐的方式是从响应流构造一个新的响应实例。

```python
async for chunk in response.body_iterator:  # type: ignore
    response_body += chunk
```

在同步响应头时，需要注意要丢弃`content-length`字段，避免修改后的响应内容长度变化。

```python
headers.pop("content-length", None)
```

<details>

<summary>点击查看代码示例</summary>

```python
class UpdateTelegraphHTMLFeedMiddleware(BaseHTTPMiddleware):
    @cached(FIFOCache(maxsize=1024))
    def make_html_by_url(self, url: str) -> str:
        res = httpx.get(url)
        doc = Soup(res.text)
        return "<br/>".join([str(img) for img in doc.find_all("img")])

    def fixupx_match(self, item: dict):
        feed = JSONFeedItem(**item)

        if feed.content_html:
            document = Soup(feed.content_html, "lxml")
            for tag in document.find_all("a"):
                tag = cast(Tag, tag)
                href = (tag and tag.attrs and tag.attrs["href"]) or None
                if isinstance(href, str) and href.startswith("https://telegra.ph"):
                    extend_img_content = self.make_html_by_url(href)
                    feed.content_html = f"{feed.content_html}{extend_img_content}"
                    logger.debug(f"[UpdateTelegraphHTMLFeedMiddleware] Added img for {href}")
        return feed.model_dump()

    async def dispatch(
        self, request: Request, call_next: Callable[[Request], Awaitable[Response]]
    ) -> Response | PrettyJSONResponse:
        response = await call_next(request)
        path = request.url.path
        ct = response.headers.get("content-type")
        if ct and ct.startswith("application/json") and path.startswith("/api/rss/"):
            response_body = b""
            async for chunk in response.body_iterator:  # type: ignore
                response_body += chunk
            body = json.loads(response_body)
            headers = dict(response.headers)
            headers.pop("content-length", None)
            if body.get("version") == "https://jsonfeed.org/version/1":
                body["items"] = list(map(self.fixupx_match, body["items"]))
            return PrettyJSONResponse(body, status_code=response.status_code, headers=headers)
        return response
```

</details>

## 捕获异常并记录

1. 在 `call_next` 附近使用 `try-catch` 捕获异常, 并在记录异常信息后抛出。
2. 使用 `request.scope.get("route")` 查询路由信息
3. 使用 `asyncio.Lock` 保护写入操作
      - 在本例中，合适的代码逻辑在协程下是不会产生数据竞态条件的
      - 纵使如此，使用`asyncio.Lock`仍然可以减少开发者的`心智负担`, 保持一个良好的开发习惯

<details>

<summary>点击查看代码示例</summary>

```python
class CachedItem(BaseModel):
    timestamp: float | None = Field(None, description="秒级时间戳")
    name: str
    path: str
    methods: list[str]
    error: str

    @model_validator(mode="after")
    def set_timestamp(cls, values):
        if values.timestamp is None:
            values.timestamp = time.time()

        return values


class SentryCacheMiddleware(BaseHTTPMiddleware):
    TTL = 3600 * 12
    LOCK = Lock()
    collections: dict[str, list[CachedItem]] = defaultdict(list)

    @staticmethod
    async def expire_all():
        for k in SentryCacheMiddleware.collections.keys():
            await SentryCacheMiddleware.expire_key(k)

    @staticmethod
    async def expire_key(key: str):
        async with SentryCacheMiddleware.LOCK:
            deadline = time.time() - SentryCacheMiddleware.TTL
            SentryCacheMiddleware.collections[key] = [
                x for x in SentryCacheMiddleware.collections[key] if x.timestamp and x.timestamp >= deadline
            ]

    @staticmethod
    async def get_errors():
        await SentryCacheMiddleware.expire_all()
        async with SentryCacheMiddleware.LOCK:
            return SentryCacheMiddleware.collections

    @staticmethod
    async def add_error(route: APIRoute, exc: Exception):
        async with SentryCacheMiddleware.LOCK:
            error = "".join(traceback.format_exception(exc))
            payload: dict[str, Any] = {
                "name": route.name,
                "path": route.path,
                "methods": route.methods,
                "error": f"{type(exc)} - {error}",
            }
            item = CachedItem(**payload)
            SentryCacheMiddleware.collections[route.name].insert(0, item)

    async def dispatch(self, request: Request, call_next: Callable[[Request], Awaitable[Response]]) -> Response:
        try:
            response = await call_next(request)
        except httpx.HTTPStatusError as e:
            logging.warning(f"[httpx.HTTPStatusError]: {e}")
            return Response(content=e.response.text, status_code=e.response.status_code)
        except Exception as e:
            route = request.scope.get("route")
            if route:
                await SentryCacheMiddleware.add_error(route, e)
            raise e
        return response

```

</details>
