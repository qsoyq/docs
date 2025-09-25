# Docker Compose

- <https://docs.docker.com/reference/compose-file/services/>

## 健康检查

- <https://docs.docker.com/reference/compose-file/services/#healthcheck>
- <https://docs.docker.com/reference/dockerfile/#healthcheck>

<details>

<summary>查看流程图示例</summary>
```mermaid
flowchart TB
    A[容器启动] --> A1{是否处在启动周期时间内}
    A1 --> |YES| A2[启动周期健康检查流程]
    A2 --> A3{是否通过健康检查}
    A3 --> |NO| A4[健康检查失败，不计入重试次数]
    A4 --> A1
    A7[服务标记为健康]
    A3 --> |YES| A7
    A7 --> A5[常态健康检查流程]
    A1 --> |NO| A5
    A5 --> |等待间隔interval| B[健康检查]
    B --> B1{健康检查是否成功}
    B1 --> |YES| A7
    A7 --> A5
    B1 --> |NO| B2{是否达到最大重试次数}
    B2 --> |YES| B3[重启容器]
    B3 --> A
    B2 --> |NO| A5
```
</details>

<details>

<summary>查看配置示例</summary>

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"]
  interval: 1m30s
  timeout: 10s
  retries: 3
  start_period: 40s
  start_interval: 5s
```

</details>

## 资源限制

- <https://docs.docker.com/reference/compose-file/deploy/#resources>

<details>

<summary>查看配置示例</summary>

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

</details>
