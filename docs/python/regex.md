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

## 非捕获组

<details>
<summary>Example</summary>

```python
import re

pattern = r"(\d+(?:.\d+)?)"
result = re.match(pattern, "3.5")
assert result and result.groups()[0] == "3.5"


result = re.match(pattern, "3")
assert result and result.groups()[0] == "3"
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

## 元字符转义

通过 `re.escape`, 对正则中的所有元字符串加上反斜杠`\`, 避免错误的处理

</details>

## 一些特殊的匹配规则

- `(?=)` 前瞻
- `(?!)` 否定前瞻
- `(?<=)` 后顾
- `(?<!)` 否定后顾

需要注意的是, 后顾模式仅匹配当前位置前面的字符，本身不消耗字符

<details>

<summary>查看代码示例</summary>

```python
import re

# 前瞻

r = re.match(r"hello(?=,world)", "hello,world")
assert r and r.group() == "hello"

# 否定前瞻

r = re.match(r"hello(?!,world)", "hello,world")
assert r is None

r = re.match(r"hello(?!，world)", "hello,world")
assert r and r.group() == "hello"

# 后顾

r = re.match(r"hello,(?<=,)world", "hello,world")
assert r and r.group() == "hello,world"

r = re.match(r".*(?<=hello,)world", "hello,world")
assert r and r.group() == "hello,world"

# 否定后顾

r = re.match(r"hello,(?<!,)world", "hello,world")
assert r is None

r = re.match(r"hello，(?<!,)world", "hello，world")
assert r and r.group() == "hello，world"

r = re.match(r".*(?<!hello,)world", "hello,world")
assert r is None

r = re.match(r".*(?<!hello，)world", "hello,world")
assert r and r.group() == "hello,world"

```

</details>
