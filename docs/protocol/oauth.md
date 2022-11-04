# OAuth2.0

[oauth-net](https://oauth.net/)

## Scope

客户端在请求授权时, 需要通过 `scope` 来指定需要访问的用户信息. 授权方在授权认证时会将对应的权限信息展示给用户, 以便用户决定是否将相应信息授权给客户端.

客户端可以请求多个`scope`, 每个表示`scope`的字符串以空格进行分割.

`scope`的定义由授权方决定.

[github-oauth2-scopes](https://docs.github.com/cn/developers/apps/building-oauth-apps/scopes-for-oauth-apps)

[google-oauth2-scopes](https://developers.google.com/identity/protocols/oauth2/scopes)

## OAuth Grant Types

### Authorization Code Grant

客户端通过 `client_id` 构造授权链接, 用户在访问授权链接进行授权后, 通过授权链接传递的 `redirect_uri`, 携带一个 `code` 重定向回客户端. 客户端可通过 `code`和`client_secret` 向授权方获取 `AccessToken`, 再通过`AccessToken`来获取用户信息.

除了需要在授权链接中指定 `scope`来限制应用程序访问用户信息的权限外, 多数授权方允许在链接中传递`state`等参数, 在重定向跳转回客户端时, 透传回给客户端, 以便于客户端进行一些功能上的定制.

多数情况下, 授权方会对 `redirect_uri`指向的地址做校验或约束, 如限制域名和路径, 避免重定向 URI 被恶意篡改导致的授权码失窃.

这种授权方式常见于各种 Web 网站的第三方登录.

## Proof Key for Code Exchange(PKCE)

[rfc7636](https://datatracker.ietf.org/doc/html/rfc7636)

`PKCE` 流程是对`Authorization Code Grant`的一种补充, 旨在避免 `CSRF` 和 `授权码注入攻击`.

### Client Creates a Code Verifier

第一步, 客户端需要构造一个从`[A-Z], [a-z], [0-9], "-", ".", "_", "~"` 中随机至少 43 位的字符串. 该字符串必须无法猜测以保证安全.

### Client Creates the Code Challenge

第二步, 客户端需要基于 `Code Verifier`的 `Code Challenge`.

虽然规范允许 `Code Verifier`直接按明文作为`Code Challenge`, 但一般不推荐.

推荐先对`Code Verifier`进行 SHA256 算法进行摘要, 再进行 URL-Safe 的 Base64编码值作为`Code Challenge`.

### Client Sends the Code Challenge with the Authorization Request

第三步, 客户端在构造授权请求时, 携带 `Code Challenge` 和一个可选的 `code_challenge_method`.

### Server Returns the Code

第四步, 授权方在返回授权码前, 必须将授权码和`Code Challenge`以及`code_challenge_method`进行关联.

如果授权方要求使用 `PKCE`而客户端未提供参数时, 授权方在响应时必须在 `error` 中明确是`invalid_request`, 并且在`error_description`或`error_uri`中解释是`code challenge required.`导致的错误.

### Client Sends the Authorization Code and the Code Verifier to the

第五步, 客户端在拿到授权码后, 向授权方换取 `AccessToken`时, 除了需要传递授权码, 还需要传递`Code Verifier`参数.

### Server Verifies code_verifier before Returning the Tokens

第六步, 授权方根据 `code` 以及关联的`Code Challenge`和`code_challenge_method`, 比对接受到的`code_verifier`进行计算, 来验证请求.

## Client Credentials Grant

[client-credentials](https://oauth.net/2/grant-types/client-credentials/)

[rfc6749](https://www.rfc-editor.org/rfc/rfc6749#section-4.4)
