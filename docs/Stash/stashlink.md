# StashLink

1. 在配置文件中添加`stashlink`字段
2. 添加一个`stashlink`类型的代理
3. 添加规则, 分流到上一步添加的代理

<details>
<summary>查看 Reality 配置示例</summary>
```yaml
stashlink:
    underlying-proxy:
        name: reality
        type: vless
        flow: xtls-rprx-vision
        udp: true
        tls: true
        server: 1.1.1.1
        port: 443
        uuid: xxxxxxxxxxxxxxx
        servername: www.amazon.com
        fingerprint: chrome # 可选
        reality-opts:
            public-key: xxxxxxxxxxxxxxxx
            short-id: xx
        benchmark-url: http://cp.cloudflare.com/
        benchmark-timeout: 1

proxies:
    - name: StashLink｜Macbook
      type: stashlink
      device-id: xxxxxxxxxxxxxxxxxx

rules:
    - IP-CIDR,192.168.0.1/24,StashLink｜Macbook,no-resolve

```
</details>
