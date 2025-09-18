# 正则表达式二三事

## 命名捕获

`(?P<username>[^/]+)` 为捕获组指定名称，在提取时可以基于名称

<details>

<summary>查看代码示例</summary>

```python
import re

pattern = re.compile(r"(?P<username>[^/]+)")
test_str = "alice123/some/other/text"
match = pattern.match(test_str)
if match:
    username = match.group("username")
    print("提取的 username:", username)
else:
    print("未匹配到 username")
```

</details>

## 在正则表达式中忽略大小写

- 使用 `re.I`
- 在匹配模式前缀使用`(?i)`

<details>

<summary>查看代码示例</summary>

```python
import re

text = "HostDZire"
assert re.match(r"(?i)hostdzire", text)
assert not re.match(r"hostdzire", text)

assert re.match(r"(?i)hostdzire", text, re.I)
assert re.match(r"hostdzire", text, re.I)
```

</details>
