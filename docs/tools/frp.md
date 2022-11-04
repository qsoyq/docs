# Frp

[frp](https://github.com/fatedier/frp)

## 基于 frp 和 traefik 的内网Web服务代理

参考

[vhost-http](https://gofrp.org/docs/examples/vhost-http/)

[traefik.routers](https://doc.traefik.io/traefik/routing/routers/)

为了方便平日写代码, 基于 frp 和 traefik 部署了一个内网穿透工具.

目标是通过一个三级子域名, 将 web 请求转发到本地服务上.

因为本地有多个服务, 希望通过一个三级子域名可以同时访问.

同时不影响服务器上的其他服务.

所以按照 `服务器traefik->服务器frps->本地frpc->本地traefik->本地服务`的转发流程, 将公网的 web 请求, 转发到本地服务.

### 准备工作

首先需要一个域名和云服务器, 将域名映射到云服务器上的 80 端口.

需要在云服务上暴露 80、443、7000端口, 其中 80 和 443 端口用于监听 http、https请求, 7000 端口让 `frps` 监听来自 `frpc` 的连接.

因为[fatedier/frp](https://hub.docker.com/r/fatedier/frp)上的镜像未同步, 需要基于源码自行构建.

为避免 docker 网络联通的问题, 在本地和服务器上创建自定义网络, 在后续服务部署时使用.

`docker network create my_bridge`

#### frp 镜像构建

```shell
git clone https://github.com/fatedier/frp.git

export FRPC_IMAGE_NAME=your_frpc_image_name
export FRPS_IMAGE_NAME=your_frps_image_name

docker build  -f ./frp/dockerfiles/Dockerfile-for-frpc --platform linux/amd64 -t $FRPC_IMAGE_NAME ./frp

docker build  -f ./frp/dockerfiles/Dockerfile-for-frps --platform linux/amd64 -t $FRPS_IMAGE_NAME ./frp

docker push $FRPC_IMAGE_NAME
docker push $FRPS_IMAGE_NAME
```

### 部署 traefik

`服务器 traefik` 和`本地 traefik` 可以按相同的配置部署.

```yaml
version: '3'

networks:
  default:
    name: my_bridge
    external: true

services:

    traefik:
        network_mode: my_bridge
        container_name: traefik
        image: traefik:v2.5
        restart: always
        command:
            - --log.level=debug
            - --providers.docker
            - --providers.docker.exposedbydefault=false

            - --entrypoints.web.address=:80
            - --entryPoints.web.proxyProtocol.insecure
            - --entryPoints.web.forwardedHeaders.insecure

            - --entrypoints.websecure.address=:443
            - --entryPoints.websecure.proxyProtocol.insecure
            - --entryPoints.websecure.forwardedHeaders.insecure

            - --accesslog.filepath=/logs/access.log
            - --accesslog.format=common
            - --accesslog.fields.defaultmode=keep
            - --accesslog.fields.headers.names.User-Agent=keep
            - --accesslog.fields.headers.names.Host=keep

        ports:
            - 80:80
            - 443:443
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
            - ./logs/traefik:/logs
```

### 部署 frps

```ini
#frps.ini
[common]
bind_port = 7000
vhost_http_port = 8080
dashboard_port = 7500

dashboard_user = {{ .Envs.FRP_DASHBOARD_USER }}
dashboard_password = {{ .Envs.FRP_DASHBOARD_PWD }}

authentication_method = token
token = {{ .Envs.FRP_AUTH_TOKEN }}
```

```yaml
# docker-compose.yml
version: '3'

networks:
  default:
    name: my_bridge
    external: true

services:
    frps:
        image: clpy9793/frps
        container_name: frps
        entrypoint: frps -c /app/frps.ini
        restart: always
        volumes:
            - ./frps.ini:/app/frps.ini:ro

        environment:
            FRP_AUTH_TOKEN: example
            FRP_DASHBOARD_USER: example
            FRP_DASHBOARD_PWD: example

        ports:
            - 7000:7000

        labels:
            - traefik.enable=true

            # dashboard
            - traefik.http.routers.frp-dashboard.rule=Host(`youhostname`)&&PathPrefix(`/frp-dashboard/`)
            - traefik.http.routers.frp-dashboard.entrypoints=websecure
            - traefik.http.routers.frp-dashboard.tls=true
            - traefik.http.routers.frp-dashboard.service=frp-dashboard
            - traefik.http.services.frp-dashboard.loadbalancer.server.port=7500

            - "traefik.http.middlewares.frp-dashboard-path-replace.replacepathregex.regex=^/frp-dashboard/(.*)"
            - "traefik.http.middlewares.frp-dashboard-path-replace.replacepathregex.replacement=/$$1"
            - traefik.http.routers.frp-dashboard.middlewares=frp-dashboard-path-replace@docker

            # Web HTTP Proxy
            - traefik.http.routers.frp-http.entrypoints=web
            - traefik.http.routers.frp-http.rule=Host(`youhostname`)

            - traefik.http.routers.frp-secure.entrypoints=websecure
            - traefik.http.routers.frp-secure.rule=Host(`youhostname`)
            - traefik.http.routers.frp-secure.tls=true


            - traefik.http.routers.frp-http.service=frp-proxy
            - traefik.http.routers.frp-secure.service=frp-proxy
            - traefik.http.services.frp-proxy.loadbalancer.server.port=8080
```

`frps` 通过 `docker label` 注册到 `traefik`, 监听来自`youhostname`域名的http请求, 并进行转发. 其中, 路径前缀为`/frp-dashboard/`的请求, 将去除该部分后路径后转发到内部的`7500`端口. 剩余的请求将转发到内部的`8080`端口

同时, `frps`对外暴露 `7000`端口, 监听来自 `frpc` 的连接.

### 部署 frpc

```ini
# frpc.ini
[common]
server_addr = {{ .Envs.FRP_SERVER_ADDR }}
server_port = {{ .Envs.FRP_SERVER_PORT }}

tls_enable = true
authentication_method = token
token = {{ .Envs.FRP_AUTH_TOKEN }}

[web]
type = http
local_ip = {{ .Envs.FRP_LOCAL_IP }}
local_port = {{ .Envs.FRP_LOCAL_PORT }}
custom_domains = {{ .Envs.FRP_CUSTOM_DOMAINS }}
```

```yaml
version: '3'

networks:
  default:
    name: my_bridge
    external: true

services:

    frpc:
        image: clpy9793/frpc
        container_name: frpc
        entrypoint: frpc -c /app/frpc.ini
        restart: always
        volumes:
            - ./frpc.ini:/app/frpc.ini:ro
        environment:
          FRP_SERVER_ADDR: youhostname
          FRP_SERVER_PORT: 7700
          FRP_AUTH_TOKEN: example
          FRP_LOCAL_IP: traefik
          FRP_LOCAL_PORT: 80
          FRP_CUSTOM_DOMAINS: youhostname
```

### 验证

```yaml
version: '3'

networks:
  default:
    name: my_bridge
    external: true

services:
    whoami:
        image: traefik/whoami
        container_name: whoami
        network_mode: my_bridge
        restart: always
        labels:
            - openapi.redoc.enable=true

            - traefik.enable=true
            - traefik.http.routers.whoami.rule=Host(`local.wangqs.work`) && PathPrefix(`/whoami/`)
            - traefik.http.routers.whoami.entrypoints=web

            - traefik.http.routers.whoami-https.rule=Host(`local.wangqs.work`) && PathPrefix(`/whoami/`)
            - traefik.http.routers.whoami-https.entrypoints=websecure
            - traefik.http.routers.whoami-https.tls=true

            - "traefik.http.middlewares.whoami-path-replace.replacepathregex.regex=^/whoami/(.*)"
            - "traefik.http.middlewares.whoami-path-replace.replacepathregex.replacement=/$$1"

            - traefik.http.routers.whoami.middlewares=whoami-path-replace@docker
            - traefik.http.routers.whoami-https.middlewares=whoami-path-replace@docker
```

部署本地服务后, 通过`http://youhostname/whoami/` 可以正常访问, 则部署成功.

### 注意

- `traefik`可以改为其他代理服务器, 如 `Nginx`
- 本地`traefik`部署时, 因为请求来自本地 `frpc`, 所以需要设置为信任来自本地 `frpc` 的 `X-Forward-*`的请求头, 方便本地服务获取用户的真实 ip
- 为了安全考虑, `frp` 上的代理尽量启用`authentication_method`, 如`token`
- 部署 https 较为复杂, 可考虑参考`traefik`或其他代理官网文档进行.
