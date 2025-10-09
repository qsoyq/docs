# functools

## singledispatch

根据首个参数类型进行重载分发

```python
from functools import singledispatch

@singledispatch
def process(data):
    return f"object: {data}"

@process.register(int)
def _(data):
    return f"int: {data}"

@process.register(str)
def _(data):
    return f"str: {data}"

print(process(1))
print(process("hello,world"))
print(process([1,2,3]))
```
