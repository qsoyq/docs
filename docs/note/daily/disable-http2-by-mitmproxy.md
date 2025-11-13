# 使用 mitmproxy 降级 http2

## 背景

最近一次 `Stash` 使用中发现被 `mitm` 的域名, 大部分 http2 的请求都会出错.

其中 `curl` 的错误提示如下

```bash
curl https://www.google.com
>> curl: (16) Error in the HTTP2 framing layer
```

经过调试, 发现 `http1.1` 的请求都正常.

所以考虑将 `mitmproxy` 作为系统代理在 `ALPN` 协商时强行降级到 `http1.1`, 以避免这种问题

## 操作步骤

1. 下载安装并运行 mitmproxy

    ```bash
    brew install mitmproxy
    mitmproxy --set http2=false --set ssl_insecure=true
    ```

2. 启动 mitmproxy 后 导出 mitm 根证书并安装信任

    ```bash
    curl -o ./mitm.pem  "http://mitm.it/cert/pem"
    ```

3. 导出环境变量

    ```bash
    export https_proxy=http://127.0.0.1:8080 http_proxy=http://127.0.0.1:8080 all_proxy=socks5://127.0.0.1:8080
    ```

4. 系统 Wi-Fi 设置 Web 代理
