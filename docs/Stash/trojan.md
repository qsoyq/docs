# trojan

## 部署

### 配置目录

```bash
mkdir -p /etc/trojan-go
```

### 自签名证书

```bash
openssl genrsa -out /etc/trojan-go/server.key 1024
openssl req -new -x509 -days 3650 -key /etc/trojan-go/server.key -out /etc/trojan-go/server.crt -subj "/C=XX/L=Default City/O=Default Company Ltd/CN=*.example.org"

# openssl req -new -key server.key -out server.csr
# openssl x509 -req -in server.csr -out server.crt -signkey server.key -days 3650

```

### 服务配置

```bash
# password 修改密码

cat > /etc/trojan-go/config.json <<EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "trojan.example.org",
    "remote_port": 443,
    "password": [
        ""
    ],
    "websocket": {
        "enabled": true,
        "path": "/ws"
    },
    "mux": {
        "enabled": true,
        "concurrency": 8,
        "idle_timeout": 60
    },
    "ssl": {
        "cert": "/etc/trojan-go/server.crt",
        "key": "/etc/trojan-go/server.key"
    }
}
EOF
```

### 安装 docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
```

### 运行容器

```bash
# 修改需要映射的端口
docker run -d --name trojan-go -p 443:443 --restart=unless-stopped -v /etc/trojan-go:/etc/trojan-go teddysun/trojan-go
```
