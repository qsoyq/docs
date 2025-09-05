# PlerplexityPro

## 使用示例

```bash
export PlerplexityProApiKey=""
```

```bash
curl https://api.perplexity.ai/v1/chat/completions \
  -H "Authorization: Bearer $PlerplexityProApiKey" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-pro",
    "messages": [
      {
        "role": "user", 
        "content": "What are the major AI developments and announcements from today across the tech industry?"
      }
    ]
  }' | jq
```

## API接入 NextChat

### 请求路径适配

PerplexicyPro 使用的接口路径是 `https://api.perplexity.ai/chat/completions`

 而 `NextChat` 只能指定域名，路径只能是`/v1/chat/completions`(疑似)

需要在本地或者服务端反代，将请求从路径 `/v1/chat/completions` 转发到 `/chat/completions`

---

使用 Stash 本地重写即可

```yaml
- https://api.perplexity.ai/v1/chat/completions https://api.perplexity.ai/chat/completions transparent
```

### 模型适配

> <https://docs.perplexity.ai/guides/chat-completions-guide>

需要在 NextChat 里自定义模型为`sonar-pro`

![image](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/527aecc75ff4465680c759590178234c.png)
