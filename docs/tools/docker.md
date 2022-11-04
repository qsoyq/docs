# Docker

## Control Docker with systemd

为 docker daemon 设置 http/https 代理

```shell
sudo mkdir -p /etc/systemd/system/docker.service.d
```

```shell
cat > /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=http://192.168.1.79:7890"
Environment="HTTPS_PROXY=http://192.168.1.79:7890"
EOF
```

```shell
sudo systemctl daemon-reload
```

```shell
sudo systemctl restart docker
```

参考文档

[httphttps-proxy](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy)

## Docker Compose

配置模板

```yaml
version: '3'

services:
    proxy-tool:
        image: image
        container_name: name
        restart: unless-stopped
        ports:
          - 8000:8000
        logging:
            driver: json-file
            options:
                max-size: 1m            
```
