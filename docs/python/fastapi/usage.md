# 使用手册

## 请求/响应

### 为endpoint添加响应示例

在路由函数装饰器里指定`responses`参数

```python
responses: dict[int | str, dict[str, object]] = {
    200: {
        "description": "200 Successful Response",
        "content": {"application/json": {"example": {"msg": "ok"}}},
    }
}
@app.get("/", responses=responses)
```
