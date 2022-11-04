# Traefik

## 支持 Grpc

[grpc-Examples](https://doc.traefik.io/traefik/user-guides/grpc/)

grpc 基于 h2 协议实现, 为了让 traefik 能正确的转发 grpc 请求到服务, 需要让 traefik 与服务建立 h2 通信.

一种方法是通过自签名证书, 提供 HTTPS 访问能力, 基于 ALPN 协议, grpc server 会与traefik 协商切换到 h2 协议.

另外一种更直观的方式, 就是通过 `docker label` 或其他配置文件的方式, 自述仅支持 h2 协议.

```shell
traefik.http.services.<my-service-name>.loadbalancer.server.scheme=h2c
```

grpc客户端 通过 `/${包名}.${服务名}/${接口名}` 的路径向服务端发起 HTTP/2 请求.

所以基于 Traefik, 可以使用 `Host` 和 `PathPrefix` 的路由规则结合, 进行反向代理和负载均衡.
