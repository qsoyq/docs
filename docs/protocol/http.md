## http2

### 如何切换到http2

对于 https 下的请求, 如果客户端支持 http2 和 ALPN 协议, 那么在 tls 握手的时候, 双方就会进行协商, 切换到 http2 协议.

```shell
curl --http2 https://httpbin.org -v

* Connected to httpbin.org (54.221.78.73) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*  CAfile: /etc/ssl/cert.pem
*  CApath: none
* (304) (OUT), TLS handshake, Client hello (1):
* (304) (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES128-GCM-SHA256
* ALPN, server accepted to use h2
* Server certificate:
*  subject: CN=httpbin.org
*  start date: Nov 21 00:00:00 2021 GMT
*  expire date: Dec 19 23:59:59 2022 GMT
*  subjectAltName: host "httpbin.org" matched cert's "httpbin.org"
*  issuer: C=US; O=Amazon; OU=Server CA 1B; CN=Amazon
*  SSL certificate verify ok.
* Using HTTP2, server supports multiplexing
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* Using Stream ID: 1 (easy handle 0x135812200)
> GET / HTTP/2
> Host: httpbin.org
> user-agent: curl/7.79.1
> accept: */*
>
* Connection state changed (MAX_CONCURRENT_STREAMS == 128)!
< HTTP/2 200
< date: Sun, 20 Feb 2022 10:16:01 GMT
< content-type: text/html; charset=utf-8
< content-length: 9593
< server: gunicorn/19.9.0
< access-control-allow-origin: *
< access-control-allow-credentials: true
```

对于非 https 下的或不支持 ALPN 协议的客户端和服务端, 客户端会先发送一个携带 Upgrade 标头的 http1.1请求, 如果服务端支持 http2, 会返回 101 响应与对应的数据. 这种协议切换也是 WebSocket 协议在使用的.

如果服务端不支持协议切换, 换返回 400 响应.

```shell
curl http://127.0.0.1:8000/

> Connection: Upgrade, HTTP2-Settings
> Upgrade: h2c
> HTTP2-Settings: AAMAAABkAAQCAAAAAAIAAAAA
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 101
< date: Sun, 20 Feb 2022 10:25:22 GMT
< server: hypercorn-h11
< connection: upgrade
< upgrade: h2c
* Received 101
* Using HTTP2, server supports multiplexing
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
< HTTP/2 200
< content-length: 16
< content-type: application/json
< x-process-time: 5.1021575927734375e-05
< date: Sun, 20 Feb 2022 10:25:22 GMT
< server: hypercorn-h2
```

```shell
curl http://127.0.0.1:8000/

*   Trying 127.0.0.1:8000...
* Connected to 127.0.0.1 (127.0.0.1) port 8000 (#0)
> GET / HTTP/1.1
> Host: 127.0.0.1:8000
> User-Agent: curl/7.79.1
> Accept: */*
> Connection: Upgrade, HTTP2-Settings
> Upgrade: h2c
> HTTP2-Settings: AAMAAABkAAQCAAAAAAIAAAAA
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 400 Bad Request
< content-type: text/plain; charset=utf-8
< connection: close
< Transfer-Encoding: chunked
```
