## 协议类型

## Vless

### Reality

1. flow 不能为空

<details>
<summary>Example</summary>

```yaml
proxies:
    - name: reality
      type: vless
      flow: xtls-rprx-vision
      udp: true
      tls: true
      server: 
      port: 
      uuid: 
      servername: www.amazon.com
      fingerprint: chrome # 可选
      reality-opts:
          public-key: 
          short-id: 
      benchmark-url: http://cp.cloudflare.com/
      benchmark-timeout: 1

```

</details>

## Hysteria2

1. 不支持混淆
2. 端口跳跃需要配置 `ports` 参数

<details>
<summary>Example</summary>

```yaml
proxies:
    - name: hysteria2
      type: hysteria2
      server:
      port:
      ports: ""
      hop-interval: 30
      auth:
      fast-open: true
      sni:
      skip-cert-verify: true
```

</details>
