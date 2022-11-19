# traefik-forwardauth-oauth-middleware

基于 Traefik 的 forwardauth 特性, 为服务添加 OAuth 登陆授权认证.

以 GithubOAuth 为例.

[traefik forwardauth middleware](https://doc.traefik.io/traefik/middlewares/http/forwardauth/)

## 流程

1. traefik 接收客户端请求, 转发请求到 forwardauth 中间件.
2. forwardauth 中间件基于 HTTP Header 进行身份验证, 对于未授权的请求, 生成授权链接并重定向.
3. 授权中间件对接第三方授权服务, 用户授权成功后, 根据 forwardauth 中间件生成的信息, 再跳转回原始地址, 携带授权码`code`.
4. traefik 再次接收客户端请求, 并将请求转发到 forwardauth 中间件.
5. forwardauth中间件拿到授权码`code`, 并请求授权中间件, 拿到用户信息后, 生成携带用户标识的Cookie.
6. 客户端拿到 forwardauth 中间件返回的 Cookie 信息, 并重新跳转到原始地址.
7. 在之后的客户端请求中, 都会携带含有用户标识的 Cookie 信息, forwardauth中间件在验证 Cookie 后放行请求.

```` markdown title="基于 forwardauth 进行身份验证的 traefik 代理转发流程"
``` mermaid
sequenceDiagram
autonumber
client->>traefik proxy: 客户端请求
traefik proxy->> forwardauth service: 身份验证
alt if 身份验证失败
    forwardauth service->>traefik proxy: 身份验证失败, 返回重定向响应, 重定向到身份认证地址
    traefik proxy->>client: 返回重定向响应, 重定向到身份认证地址
    client->>OAuth Service: 客户端重定向到身份认证地址
    OAuth Service->>client: 身份认证成功, 重定向到客户端
    client->>traefik proxy: 客户端请求

    traefik proxy->> forwardauth service: 身份验证
end
forwardauth service->>traefik proxy: 身份验证成功
traefik proxy->>endpoint: 转发请求到目标服务
endpoint->>traefik proxy: 返回响应结果
traefik proxy->>client: 返回响应结果
```
````

``` mermaid
sequenceDiagram
autonumber
client->>traefik proxy: 客户端请求
traefik proxy->> forwardauth service: 身份验证
alt if 身份验证失败
    forwardauth service->>traefik proxy: 身份验证失败, 返回重定向响应, 重定向到身份认证地址
    traefik proxy->>client: 返回重定向响应, 重定向到身份认证地址
    client->>OAuth Service: 客户端重定向到身份认证地址
    OAuth Service->>client: 身份认证成功, 重定向到客户端
    client->>traefik proxy: 客户端请求

    traefik proxy->> forwardauth service: 身份验证
end
forwardauth service->>traefik proxy: 身份验证成功
traefik proxy->>endpoint: 转发请求到目标服务
endpoint->>traefik proxy: 返回响应结果
traefik proxy->>client: 返回响应结果
```

所以需要部署服务如下

- Traefik 代理服务: [traefik](https://github.com/traefik/traefik)
- oauth 授权中间件: [oauth-playground](https://github.com/qsoyq/oauth-playground)
- forwardauth 身份认证中间件: [forwardauth-middleware](https://github.com/qsoyq/forwardauth-middleware)
- whoami 测试用响应服务: [whoami](https://github.com/traefik/whoami)

## 准备

### Github OAuth App

1. 在 [github-settings-developers](https://github.com/settings/developers) 申请一个 OAuth App
2. 记下对应的 `ClientID`, `Client Secrets`
3. 填写`Authorization callback URL`, 要和访问的服务域名能匹配上. [规则](https://docs.github.com/cn/developers/apps/building-oauth-apps/authorizing-oauth-apps)

## 实施

实际部署时, 需要将实例中的`example.com`改为真实的域名.

### Traefik

traefik 服务负责处理连接并转发请求.

```yaml
services:
    traefik:
        container_name: traefik
        image: traefik:v2.8
        restart: unless-stopped
        command:
            - --providers.docker
            - --entrypoints.web.address=:80
            - --entryPoints.web.proxyProtocol.insecure
            - --entryPoints.web.forwardedHeaders.insecure
            - --entrypoints.websecure.address=:443
            - --entryPoints.websecure.proxyProtocol.insecure
            - --entryPoints.websecure.forwardedHeaders.insecure
        ports:
            - 80:80
            - 443:443
        volumes:
            # So that Traefik can listen to the Docker events
            - /var/run/docker.sock:/var/run/docker.sock
```

### GithubOAuthMiddleware

GithubOAuthMiddleware 服务功能如下:

1. 提供接口, 接受 redirect_url 并生成 github authorization url.
2. 提供接口, 接受授权码`code`获取并返回Github User Info

`github_client_id`和 `github_secret` 需要替换为真实参数.

```yaml
services:
    github-oauth-middleware:
        image: qsoyq/oauth-playground
        container_name: github-oauth-middleware
        restart: unless-stopped
        environment:
            github_client_id: github_client_id
            github_secret: github_secret
            github_redirect_uri: https://example.com/oauth-playground/github/callback
        labels:
            - traefik.enable=true
            - traefik.http.routers.oauth-playground.rule=Host(`example.com`) && PathPrefix(`/oauth-playground/`)
            - traefik.http.routers.oauth-playground.entrypoints=web

            - "traefik.http.middlewares.oauth-playground-path-replace.replacepathregex.regex=^/oauth-playground/(.*)"
            - "traefik.http.middlewares.oauth-playground-path-replace.replacepathregex.replacement=/$$1"
            - traefik.http.routers.oauth-playground.middlewares=oauth-playground-path-replace@docker
```

### ForwardauthMiddleware

ForwardauthMiddleware 服务功能如下:

1. 基于 Coookie, 放行通过验证的请求
2. 对于未通过验证的请求, 进入授权流程

```yaml
services:
    ForwardauthMiddleware:
        image: qsoyq/forwardauth-middleware
        container_name: ForwardauthMiddleware
        restart: unless-stopped
        environment:
        - github_oauth_authorize_url=https://example.com/oauth-playground/github/
        - github_oauth_userinfo_endpoint=https://example.com/oauth-playground/github/callback
```

### Whoami

Tiny Go webserver that prints OS information and HTTP request to output.

中间件 `http://ForwardauthMiddleware:8000/traefik/forwardauth/authentication/github?whitelist=qsoyq` 中通过`whitelise`字段授权白名单用户.

改为 `http://ForwardauthMiddleware:8000/traefik/forwardauth/authentication/github?use_whitelist=f` 表示不需要白名单.

```yaml
services:
    whoami:
        image: traefik/whoami
        container_name: whoami
        network_mode: my_bridge
        restart: always
        labels:
            - openapi.redoc.enable=true
            - traefik.enable=true
            - traefik.http.routers.whoami.rule=Host(`example.com`) && PathPrefix(`/whoami/`)
            - traefik.http.routers.whoami.entrypoints=web

            - "traefik.http.middlewares.github-oauth.forwardauth.address=http://ForwardauthMiddleware:8000/traefik/forwardauth/authentication/github?whitelist=qsoyq"
            - "traefik.http.middlewares.github-oauth.forwardauth.trustForwardHeader=true"
            - "traefik.http.middlewares.github-oauth.forwardauth.authResponseHeaders=Set-Cookie"

            - traefik.http.routers.whoami.middlewares=github-oauth@docker
```
