# HTTP 重写

<https://stash.wiki/http-engine/rewrite>

## Body Rewrite

3.0.0(9121) 引入如下的 body-rewrite

- request-jq, request-replace-regex, request-json-replace, request-json-add, request-json-del
- response-jq, response-replace-regex, response-json-replace, response-json-add, response-json-del

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
