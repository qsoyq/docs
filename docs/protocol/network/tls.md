# SSL协议

1. 双方利用明文通信的方式确立使用的加密算法。
2. 利用非对称算法通信，交换一个密钥。
3. 该密钥用于对称加密算法，加密接下来的通信正文。

## 密钥协商

1. 客户端发送 Client hello, 包含客户端随机数、支持的加密套件、ALPN 协议进行协商
2. 服务端发送 Server Hello, 选定加密套件和协议
3. 服务端发送 Certificate 证书信息
4. 服务端发送 Server key exchange 公钥和随机数
5. 服务端发送 Server finished 结束握手
6. 客户端发送 Client key exchange 预主密钥
7. 客户端发送 Change cipher spec 启用对称密钥
8. 客户端发送 Finished 握手结束
9. 服务端发送 Change cipher spec 启用对称密钥
10. 服务端发送 Finished 握手结束

示例

```
* ALPN: curl offers h2,http/1.1
* (304) (OUT), TLS handshake, Client hello (1):
*  CAfile: /etc/ssl/cert.pem
*  CApath: none
* (304) (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Change cipher spec (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES128-GCM-SHA256 / [blank] / UNDEF
* ALPN: server accepted http/1.1
* Server certificate:
*  subject: C=CN; ST=beijing; L=beijing; O=Beijing Baidu Netcom Science Technology Co., Ltd; CN=baidu.com
*  start date: Jul  9 07:01:02 2025 GMT
*  expire date: Aug 10 07:01:01 2026 GMT
*  subjectAltName: host "www.baidu.com" matched cert's "*.baidu.com"
*  issuer: C=BE; O=GlobalSign nv-sa; CN=GlobalSign RSA OV SSL CA 2018
*  SSL certificate verify ok.
```

### 对称密钥如何协商

1. 双方互换随机数
2. 服务端发送证书
3. 客户端用证书随机生成并加密预主密钥
4. 服务端用私钥解密预主密钥
5. 双方用两个随机数和预主密钥生成对应的对称密钥
