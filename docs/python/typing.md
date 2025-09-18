# 关于 Python 中的类型

## 泛型Generic

在 FastAPI 处理路由中的路径参数时，使用了泛型对路径参数的类型进行转换验证。

在这个例子中，使用泛型是为了要求所有继承`Convertor`的子类，在实现`convert`和`to_string`, 要求传入参数和返回值的符合规范

<details>

<summary>查看代码示例</summary>

```python
T = TypeVar("T")


class Convertor(Generic[T]):
    regex: ClassVar[str] = ""

    def convert(self, value: str) -> T:
        raise NotImplementedError()  # pragma: no cover

    def to_string(self, value: T) -> str:
        raise NotImplementedError()  # pragma: no cover


class StringConvertor(Convertor[str]):
    regex = "[^/]+"

    def convert(self, value: str) -> str:
        return value

    def to_string(self, value: str) -> str:
        value = str(value)
        assert "/" not in value, "May not contain path separators"
        assert value, "Must not be empty"
        return value

class IntegerConvertor(Convertor[int]):
    regex = "[0-9]+"

    def convert(self, value: str) -> int:
        return int(value)

    def to_string(self, value: int) -> str:
        value = int(value)
        assert value >= 0, "Negative integers are not supported"
        return str(value)        
```

</details>
