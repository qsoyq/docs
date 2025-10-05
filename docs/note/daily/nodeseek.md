# Nodeseek

## 请求分析

1. Nodeseek 大部分板块不需要登录
2. 个别需要登录的板块, 如`inside`, 需要在 cookie 里校验`session`和`smac`
3. 针对部分请求, 会启用 Cloudflare WAF Bot, 难以绕过

<details>
<summary>查看代码示例</summary>

```bash
curl 'https://www.nodeseek.com/categories/life' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36'
```

```bash
curl 'https://www.nodeseek.com/categories/inside' \
  -b 'session=session; smac=smac' \
  -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36'
```

</details>
