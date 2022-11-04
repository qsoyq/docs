# EntryPoint

traefik 服务实例会绑定 `tcpEntryPoints` 和 `udpEntryPoints`对象.

TCPEntryPoint 是 Tcp 服务器实现.

UDPEntryPoint 是 Udp 服务器实现.

```go
type TCPEntryPoints map[string]*TCPEntryPoint
type UDPEntryPoints map[string]*UDPEntryPoint

type TCPEntryPoint struct {
	listener               net.Listener
	switcher               *tcp.HandlerSwitcher
	transportConfiguration *static.EntryPointsTransport
	tracker                *connectionTracker
	httpServer             *httpServer
	httpsServer            *httpServer

	http3Server *http3server
}

type UDPEntryPoint struct {
	listener               *udp.Listener
	switcher               *udp.HandlerSwitcher
	transportConfiguration *static.EntryPointsTransport
}

type httpServer struct {
	Server    stoppableServer
	Forwarder *httpForwarder
	Switcher  *middlewares.HTTPHandlerSwitcher
}

type connectionTracker struct {
	conns map[net.Conn]struct{}
	lock  sync.RWMutex
}
```

## TCPEntryPoint

### NewTCPEntryPoint

1. 实例化连接跟踪器`connectionTracker`, 维护来自客户端的连接对象
2. 根据静态配置`EntryPoint`, 实例化 TCP 对象, 监听配置指定的端口
3. 实例化 TCP router
4. 实例化 DNS 解析配置
5. 使用 `createHTTPServer` 实例化 HTTP、HTTP2服务器
6. 使用 `newHTTP3Server` 实例化 HTTP3 服务器
7. 将 HTTP 服务器的 handler 绑定到 TCP router 的 handler
8. 根据 `hostHTTPTLSConfig`配置, 为 tcp router 添加 h2c 协议下的 `routingTable`, 记录对应 sniHost 和 handler
9. 实例化 tcp switcher

### createHTTPServer

1. 实例化 `HTTPHandlerSwitcher`, 配置 404 响应
2. 使用 `Alice` 实例化 http chain handler, 并绑定 http handler switcher
3. 实例化并绑定 `XForwarded` handler
	1. 检查当前 ip 是否允许, 若 ip 不被接受, 清空请求头中`xHeaders`部分的字段
	2. `rewrite` 写入 `xHeaders` 中不存在的请求头
4. 根据`withH2c` 选择性实例化 `h2` 中间件 支持 http2 协议
5. 实例化 `httpForwarder`, 绑定 tcp listener, 负责处理连接
6. 后台启动 http 服务

### Start

1. 选择性启动 http3 server
2. 循环处理连接
	1. 根据静态配置的读写超时参数, 配置连接对象
	2. 连接绑定到`tracker`
	3. `HandlerSwitcher` 处理请求
		1. tcp router `Router` 处理请求
			1. 根据报文判断是否为`tls`协议并尝试读取 `serverName`
			2. 超时参数设置
			3. 非 tls 协议转发请求匹配 `catchAllNoTLS` 或 `httpForwarder`
			4. tls 协议从路由表寻找 `serverName` 或 `*` 对应的handler进行转发, 或转发到`httpsForwarder`

## UDPEntryPoint

## XForwarded

HTTP Middleware, 按策略重写`X-Forward-*`相关的请求头.

```go
type XForwarded struct {
	insecure   bool
	trustedIps []string
	ipChecker  *ip.Checker
	next       http.Handler
	hostname   string
}
```

## 注意事项

### HTTPSForwarder

在实例化TCPEntryPoint 对象的时候, tcp router 会通过`HTTPSForwarder` 为路由添加 sniHost、handler、tlsConf 的绑定.

但是在这里实例化的 tcp router, 并未配置任何`hostHTTPTLSConfig`信息, 即上述步骤实际上不会发生.

这是为什么呢? 目前猜测是动态配置中加载了对应 tls 相关的 router 后会更新.

### XForwarded Rewrite X Forward Headers Rule

XForwarded 中间件会根据  `insecure` 和 `trustedIps` 来确定是否信任当前请求锁携带的`X-Forwarded-*` 部分请求.
即如果 ip 受信, 则 rewrite 会跳过已存在的部分头字段.

### HttpForwarder 如何处理 HTTP 请求

`createHTTPServer` 时会实例化一个 `net/http.Server` 对象, 并在后台启动协程等待连接.

Server 对象所持有的 listener 并不直接监听端口, 而是由 `HandlerSwitcher` -> `Router` ->`httpForwarder` 的流程传递到对应连接的Channel.

进入 httpFrowarder 后的请求, 会先进入 `XForwarded` 对应的中间件, 再进入`httpSwitcher`对应的handler chain.

在未配置路由的情况下, `httpSwitcher` 绑定了 404 的 handler.

当动态配置更新, httpSwitcher 会重新绑定构建的 handler.

## 一些想法

### Switcher

TCPEntryPoint 需要支持热更新, 即根据动态配置来构建对应的 HTTP Handler, 所以增加了一层 switcher.

TCP Router 访问 switcher 绑定的 handler, 而这个 handler 在运行中可能会被修改.

所以 Switcher 是通过读写共享锁来维护 handler 对象.

### HTTP Handler Chain Using Alice

traefik 使用 `alice` 将多个 HTTP Handler 串联在一起.

其中, TCPEntryPoint 的 Handler Chain 如下.

- `NotFoundHandler`
    - `XForwarded`

如果想定制 traefik 转发相关的行为, 那么 fork 分支并在此处往 chain 里添加中间件, 也是一种方案.

### Router catchAllNoTLS

tcp router 有一个`catchAllNoTLS` handler, 当 router 处理请求的时候, 如果该值不为空且路由表为空的情况下, 所有请求都会被该 handler 接管.

在内部测试以及处理域名为"*"的情况下会添加该 handler.
