# Docker Compose

- <https://docs.docker.com/reference/compose-file/services/>

## 资源限制

- <https://docs.docker.com/reference/compose-file/deploy/#resources>

```yaml
services:
  frontend:
    image: example/webapp
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 50M
          pids: 100
        reservations:
          cpus: '0.25'
          memory: 20M
```
