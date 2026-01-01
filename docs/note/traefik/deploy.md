## 通过DockerCompose 部署

### 基础配置

`./docker-compose.yaml`

```yaml
services:
    traefik:
        image: traefik:latest
        container_name: traefik
        restart: unless-stopped
        command: |-
            --api.insecure=true
            --serversTransport.insecureSkipVerify=true

            --entryPoints.web.address=:80
            --entryPoints.websecure.address=:443
            --entryPoints.websecure.http3

            --log.level=DEBUG
            --log.filePath=/var/logs/traefik/traefik.log


            --accesslog=true
            --accesslog.fields.names.StartUTC=drop
            --accesslog.filepath=/var/logs/traefik/access.log

            --providers.docker
            --providers.docker.exposedByDefault=false
            --providers.file.watch=true
            --providers.file.directory=/etc/traefik/dynamic/conf
        environment:
            - TZ=Asia/Shanghai
        ports:
            - "80:80"
            - "443:443"
        volumes:
            # So that Traefik can listen to the Docker events
            - /var/run/docker.sock:/var/run/docker.sock
            - ./traefik/dynamic/conf:/etc/traefik/dynamic/conf
            - ./certs:/etc/traefik/certs
            - ./traefik/logs:/var/logs/traefik
        labels:
            - traefik.enable=true
            - traefik.http.routers.mydashboard.entrypoints=web
            - traefik.http.routers.mydashboard.rule=Host(`dashboard.docker.localhost`)
            - traefik.http.routers.mydashboard.service=api@internal
            - traefik.http.routers.mydashboard.middlewares=myauth
```

### 证书配置

需要挂载证书路径

- `./certs/fullchain.pem`
- `./certs/privkey.pem`

配置文件路径

- `./traefik/dynamic/conf/tls.toml`

```toml
[[tls.certificates]]
  certFile = "/etc/traefik/certs/fullchain.pem"
  keyFile = "/etc/traefik/certs/privkey.pem"
  stores = ["default"]

[tls.stores]
  [tls.stores.default]
```
