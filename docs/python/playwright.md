# Playwright

## 示例

### 从抖音主页获取用户作品

抖音未登录用户无法看到最新作品, 可以传递已登录用户的 `cookie` 来避免此问题

<details>

<summary>查看完整代码</summary>

```python
import asyncio
from datetime import datetime
from playwright.async_api import async_playwright, Response
from playwright._impl._errors import TargetClosedError

cookie = ""
user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36"

class Playwright:
    def __init__(self):
        self.fut: asyncio.Future[Response] | None = None

    async def run(self):
        global cookie, user_agent
        self.fut = asyncio.Future()
        cookies = []
        url = "https://www.douyin.com/user/MS4wLjABAAAAv4fFOLeoSQ9g8Mnc0mfPq0P6Gm14KBm2-p5sNVsdXhM"
        if cookie:
            _cookies = dict([x.strip().split("=") for x in cookie.split(";") if x != ""])
            cookies = [{"name": k, "value": v, "url": "https://www.douyin.com"} for k, v in _cookies.items()]

        async with async_playwright() as playwright:
            chromium = playwright.chromium
            browser = await chromium.launch(headless=True)
            browser = await browser.new_context(user_agent=user_agent)
            if cookies:
                await browser.add_cookies(cookies)  # type: ignore

            page = await browser.new_page()
            page.on("response", self.on_response)
            await page.goto(url)
            try:
                await asyncio.wait_for(self.fut, 10)
            except asyncio.TimeoutError as e:
                raise e
            finally:
                await browser.close()

    async def to_feeds(self, response: Response):
        print(response.url)
        body = await response.json()
        if "aweme_list" not in body:
            return
        items = []
        for aweme in body["aweme_list"][:]:
            title = aweme["item_title"]
            create_time = aweme["create_time"]
            create_datetime = datetime.fromtimestamp(create_time)
            items.append((create_datetime, title))

        items.sort(key=lambda x: -x[0].timestamp())
        for create_datetime, title in items:
            print(f"{create_datetime} - {title}")

    async def on_response(self, response: Response):
        try:
            if "/web/aweme/post" in response.url:
                await self.to_feeds(response)
                if self.fut and not self.fut.done():
                    self.fut.set_result(response)
        except TargetClosedError:
            pass

if __name__ == "__main__":
    obj = Playwright()
    asyncio.run(obj.run())

```

</details>

## 回顾

1. 通过对`page`对象监听`response`事件，在网络请求中捕获需要的内容，进行下一步处理
2. `on_response`回调事件中, 依赖的`page`上下文可能出现已销毁导致`TargetClosedError`异常, 需要注意
