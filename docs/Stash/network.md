# 网络请求分流走向

- 系统代理模式
- Tunnel 模式

## 客户端请求流程

- 开启系统代理模式下，客户端如果遵循系统代理，则不需要进行 dns 解析，而且直接将请求交给HTTP 代理服务器进行处理

- 若客户端不遵循系统代理或者没有启用系统代理, 则客户端会考虑使用系统默认 DNS 或内置的 DNS服务器进行查询.
    - 如果系统 DNS 或者客户都内置 DNS 使用 udp 查询，网关模式下，Stash Tunnel 会拦截并返回Stash 内部的 DNS 查询结果
    - 如果系统 DNS 或者客户都内置 DNS 使用 doh 或 dot 加密请求, 默认情况下 Stash Tunnel 不会拦截

<details>

<summary>查看流程图</summary>

```mermaid
flowchart TB
    C1[客户端解析 DNS 失败]
    C2[客户端解析 DNS 成功]
    C3[客户端 real-ip 请求指向Stash Tunnel]
    C4[客户端请求 指向 Stash HTTP Proxy]
    C5[客户端 fake-ip 请求指向 Stash Tunnel]
    END[结束]

    A[客户端发起请求] --> A1{是否启用系统代理}
        A1 -->|YES| A1.1{客户端是否遵循系统代理}
            A1.1 --> |NO| A3
            A1.1 --> |YES| C4
        A1 -->|NO| A3{请求是否包含域名}
            A3 -->|YES| A4[本地 DNS 解析]
            A4 --> A4.1{本地域名解析是否使用 udp}
                A4.1 --> |YES| A4.2[Stash拦截 DNS 请求]
                    A4.2 --> A4.3{域名是否匹配fake-ip-filter 白名单}
                        A4.3 -->|YES| A4.4[Stash 内部解析DNS]
                        A4.4 --> A4.5{解析DNS是否成功}
                            A4.5 -->|NO| A4.6[Stash 返回 NXDOMAIN 错误]
                            A4.6 --> C1
                            C1 --> END

                            A4.5 -->|YES| A4.7[Stash 返回 DNS 解析真实 ip 结果]
                            A4.7 --> C2
                            C2 --> C3

                        A4.3 --> |NO| A4.8[返回 fake-ip]
                        A4.8 --> C5
                    A3 -->|NO| C3


```

</details>

## Stash 内部 DNS 解析流程

此流程为按照使用推测, 非明确的官方流程

按以下优先级返回IP, 若无 IP 则返回 NXDOMAIN

1. Hosts
2. Nameserver Policy
3. Nameserver
4. Fallback
5. NXDOMAIN

<details>

<summary>查看流程图</summary>

```mermaid
flowchart TB
    A[解析域名]
    E[返回 IP 结果]
    E1[返回 NXDOMAIN 错误]

    B1{Hosts是否能查找到对应的记录}
    B2{Nameserver Policy 是否有对应的 DNS 服务器}
    B3[使用 Nameserver Policy 查询 DNS]
    B4{Nameserver Policy DNS 是否有返回匹配的查询记录}

    C0[并发查询 nameserver 和 fallback]
    C1[并发使用 nameserver 查询 DNS]
    C2[并发使用 fallback 查询 DNS]

    D1{nameserver 是否有返回匹配的查询记录}
    D2{fallback 是否有返回匹配的查询记录}


    A --> B1
    B1 -->|YES| E
    B1 -->|NO| B2
    B2 -->|YES| B3
    B3 --> B4
    B4 -->|YES| E
    B4 -->|NO| C0
    C0 --> C1
    C0 --> C2

    C1 --> D1
    C2 --> D1
    D1 -->|YES| E
    D1 -->|NO| D2
    D2 -->|YES|E
    D2 -->|NO| E1
```

</details>

## Stash HTTP Proxy 处理请求

## Stash Tunnel 处理 IP 请求
