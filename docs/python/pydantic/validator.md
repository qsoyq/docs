# validator

## Field validators

### annotated pattern

### decorator pattern

通过指定字段的装饰器函数, 在 `pydantic` 验证字段前后对值进行处理.

对于自定义类的反序列化可以借助该功能实现.

<details>
<summary>Example</summary>

```python
from pydantic import BaseModel, model_serializer, ConfigDict, BeforeValidator, field_validator


class MyValue:
    def __init__(self, value):
        self.value = value


class Model(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    val: MyValue

    @model_serializer(mode="plain")
    def serializer(self) -> dict:
        val = self.val.value * 2 if isinstance(self.val.value, int) else self.val.value
        return {"val": val}

    @field_validator("val", mode="before")
    @classmethod
    def validator_val(cls, value: object) -> MyValue:
        if isinstance(value, MyValue):
            return value
        return MyValue(value)


print(Model(val=MyValue(10)).model_dump_json())
# > {"val":20}

print(Model(val=MyValue("v")).model_dump_json())
# > {"val":"v"}

print(Model.model_validate({"val": 100}).model_dump())
# > {"val": 200}

```

</details>
