# openai

## 应用场景

### 图片内容提取

```python
import json
import time
from openai import OpenAI

t0 = time.monotonic()

pic_url = ""
api_key = ""
base_url = ""
model = ""

client = OpenAI(
    base_url=base_url,
    api_key=api_key,
)

sys_prompt = (
    "你是一个结构化信息抽取助手，负责从xxxx中提取项目清单。"
    "只输出JSON，不要解释或添加额外文字。字段类型要合理"
    "如果缺失字段可置为 null 或空字符串。"
)
user_text = (
    "请从图片中识别并提取清单，严格输出JSON，字段要求如下：\n"
    "- no: 编号（若无法确定为 null）\n"
    "- weight: 图纸显示重量(kg, 数字，无法确定为 null)\n"
    "- items: 数组，每个元素包含键：\n"
    "  ['A', 'B', 'C']\n"
    "对于不存在的列请使用 null 或空字符串。务必保证返回是一个合法 JSON 对象。"
)

response = client.chat.completions.create(
    model=model,
    messages=[
        {"role": "system", "content": sys_prompt},
        {
            "role": "user",
            "content": [
                {"type": "image_url", "image_url": {"url": pic_url}},
                {"type": "text", "text": user_text},
            ],
        },
    ],
    temperature=0,
)

t1 = time.monotonic()
print(f"{t1 - t0:.2f}")
content = response.choices[0].message.content  # type: ignore[attr-defined]
data_json = content
print(data_json)
# 简单截取：如果模型返回多余文本，尝试找第一个'{'到最后一个'}'
if not data_json.strip().startswith("{"):
    start = data_json.find("{")
    end = data_json.rfind("}")
    if start != -1 and end != -1 and end > start:
        data_json = data_json[start : end + 1]
data = json.loads(data_json)
print(data)
```
