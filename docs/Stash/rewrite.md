# HTTP 重写

<https://stash.wiki/http-engine/rewrite>

## Body Rewrite

3.0.0(971) 引入如下的 body-rewrite

- request-body
    - request-jq
    - request-replace-regex
    - request-json-replace
    - request-json-add
    - request-json-del
- response-body
    - response-jq
    - response-replace-regex
    - response-json-replace
    - response-json-add
    - response-json-del

### Request/Response

#### 示例

```yaml
http:
    mitm:
        - "p.19940731.xyz"
    body-rewrite:
        # Request
        - https://p.19940731.xyz/api/basic/whoami request-replace-regex reqv1 request-replace-regex
        - https://p.19940731.xyz/api/basic/whoami request-json-replace req.req2 "request-json-replace"
        - https://p.19940731.xyz/api/basic/whoami request-json-add req.req3 "request-json-add"
        - https://p.19940731.xyz/api/basic/whoami request-json-del req.req4
        - https://p.19940731.xyz/api/basic/whoami request-jq del(.req.req5)

        # Response
        - https://p.19940731.xyz/api/basic/whoami response-replace-regex resv6 response-replace-regex
        - https://p.19940731.xyz/api/basic/whoami response-json-replace json.res.res7 "response-json-replace"
        - https://p.19940731.xyz/api/basic/whoami response-json-add json.res.res8 "response-json-add"
        - https://p.19940731.xyz/api/basic/whoami response-json-del json.res.res9
        - https://p.19940731.xyz/api/basic/whoami response-jq del(.json.res.res10)
```

#### 模拟请求

```bash
curl -X GET https://p.19940731.xyz/api/basic/whoami  \
    -H "Content-Type: application/json" \
    -d'{
        "req": {
            "req1": "reqv1",
            "req2": "reqv2",
            "req4": "reqv4",
            "req5": "reqv5"
        },
        "res": {
            "res6": "resv6",
            "res7": "resv7",
            "res9": "resv9",
            "res10": "resv10"        
        }
    }'
```

### Mock

### Bug

以 `Stash fof mac` 4.0.0(405) 作为测试依据

1. 对于一个请求的多个(五种类型)`request-body` 重写, 仅生效匹配到的第一个。
2. 未知该如何在正则重写里使用带空格的表达式

## 实际场景描述

### RSSHub 抖音用户订阅补丁

已知, rsshub 的抖音用户拉取使用未登录浏览器伪装爬取数据.

而抖音的用户主页对于未登录用户, 不包含最新的作品, 且数量有限

因此需要以某种方式解决此问题。

#### 重定向到支持 Cookie 的新 API 并且重写 Cookie

首先，需要一个支持以 `query` 或者 `header` 传递 `cookie` 的 API, 比如[抖音用户作品 RSS 订阅 API](https://p.19940731.xyz/redoc#tag/RSS/operation/user_api_rss_douyin_user__username__get)

1. 使用`url-rewrite`将本地的`rsshub`请求重定向到新接口
2. 使用`header-rewrite` `request-add` 将 Cookie 写到请求头 `X-User-Cookie`
3. 刷新 RSS 客户端订阅, 完成验证

```yaml
http:
    mitm:
    url-rewrite:
        - http://rsshub.docker.localhost/douyin/user/(.*) http://p.docker.localhost/api/rss/douyin/user/$1 307
    header-rewrite:
        - http://p.docker.localhost/api/rss/douyin/user/ request-add X-User-Cookie Cookies
```

之所以重定向而不是直接使用新的 API 在 RSS 客户端导入订阅，是为了尽可能避免在用户侧的修改动作。

如果后续 RSSHub 支持以某种方式传递 cookie, 可以很方便再次修改

---

经测试， 只需携带 `sessionid_ss` 这个 Cookie 即可
