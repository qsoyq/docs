## 常用场景

### 反代转发HTTP 请求到宿主机端口

```yaml
labels:
    - traefik.enable=true

    # openclaw 反代
    - traefik.http.routers.openclaw.entrypoints=web
    - traefik.http.routers.openclaw.rule=Host(`openclaw.docker.localhost`)
    - traefik.http.routers.openclaw.service=openclaw
    - traefik.http.services.openclaw.loadbalancer.server.url=http://host.docker.internal:18789
```
