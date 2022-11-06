# cloudflared

## Tunnel

[tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)

### 配置

在 [Zero Trust dashboard](https://dash.teams.cloudflare.com/) `Access->Tunnels` 面板配置.

[remote-management](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/remote/remote-management/)

通过 dashboard 配置的 tunnel在本地安装后会作为系统服务注册, 开机自启动.

编辑服务

```shell
sudo systemctl edit --full cloudflared.service
```

[arguments](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/local-management/arguments/#protocol)

### Faq

> tunnel protocol

cloudflared tunnel 默认使用quic协议连接 edge, 当连接异常时才会退回到 http2.

对于部分 quic 体验不佳的环境, 可以一开始就指定 http2 协议.

通过在启动命令指定 `--protocol http2` 参数.
