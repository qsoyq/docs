# Stash API

## 修改出站模式

### 规则

```bash
curl -X PATCH "http://127.0.0.1:9090/configs" -d'{"mode": "rule"}'
```

### 全局

```bash
curl -X PATCH "http://127.0.0.1:9090/configs" -d'{"mode": "global"}'
```

### 直连

```bash
curl -X PATCH "http://127.0.0.1:9090/configs" -d'{"mode": "direct"}'
```
