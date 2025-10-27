# Cloudflare Tunnel 内网穿透

## 需求

基于 Cloudflare 网络暴露内网 HTTP  服务

## 前期准备

1. 一个域名，托管到cloudflare
2. 本地 Docker 环境, 用于部署`cloudflared`应用

## 步骤

1. 登录[dash](https://dash.cloudflare.com/)后台 -> `Zero Trust` -> `网络` -> `Tunnels`
2. `创建隧道` -> 选择`Cloudflared` -> `为隧道命名` -> 下一步 -> 返回 `Tunnels`
3. 选择隧道编辑配置 -> 已发布应用程序路由 -> 添加已发布应用程序路由
    1. 配置子域和域
    2. 服务选择`HTTP`, 其他类型自行研究
    3. url 填写内网服务地址, 需要在 docker 环境内能访问的地址
    4. 其他应用程序设置 -> HTTP 设置 -> `HTTP 主机头` 按需设置(可选, 部分反代规则需要)
    5. 保存
4. 查看隧道配置 -> 概述, 按页面说明找到 `token`
5. 本地部署 Docker 服务, 并替换 `token`

```yaml
services:
  cloudflared-tunnel:
    restart: unless-stopped
    platform: linux/amd64
    container_name: cloudflared-tunnel
    image: qsoyq/cloudflared-tunnel:amd64
    environment:
      - TUNNEL_TOKEN={TOKEN}
    command: cloudflared tunnel run --protocol http2
```

## 思考

### 为什么使用 Docker 部署 cloudflared

在官网上, 提供了 macOS、linux、Windows 的应用安装方式，以启动 cloudflared 工具，提供 tunnel.

但经过实际体验，macOS 的程序有诸多不便，且存在稳定性问题.

所以打包了一个基于 Linux 的环境，仅需要填入对应的密钥和启动命令，即可稳定在后台运行.

### 使用 HTTP2

cloudflared tunnel 默认使用quic协议连接 edge, 当连接异常时才会退回到 http2.

对于大陆大部分地区 quic 体验不佳的情况, 可以一开始就指定 http2 协议.

通过在启动命令指定 --protocol http2 参数.
