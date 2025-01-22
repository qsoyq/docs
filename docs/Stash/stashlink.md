# stashlink

配置示例

```yaml
name: StashLinkClaw
category: StashLink
icon: https://raw.githubusercontent.com/qsoyq/shell/main/assets/icon/debug.png

proxy-groups:
    - name: StashLink
      icon: "https://github.com/shindgewongxj/WHATSINStash/raw/main/icon/select.png"
      type: select
      proxies:
          - DIRECT
          - MacbookPro

      lazy: true
      ssid-policy:
          cellular: MacbookPro
          default: DIRECT

stashlink:
    underlying-proxy:
        # snell
        name: ""
        type: snell
        server: ""
        port: ""
        psk: ""
        udp: true # 需要 v3 以上服务端
        version: 3
        obfs-opts:
            mode: tls
            host: bing.com

proxies:
    - name: MacbookPro
      type: stashlink
      device-id: ""
```
