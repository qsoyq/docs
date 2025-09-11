# 正则表达式二三事

## 在正则表达式中忽略大小写

- 使用 `re.I`
- 在匹配模式前缀使用`(?i)`

```python
import re

text = "HostDZire"
assert re.match(r"(?i)hostdzire", text)
assert not re.match(r"hostdzire", text)

assert re.match(r"(?i)hostdzire", text, re.I)
assert re.match(r"hostdzire", text, re.I)
```
