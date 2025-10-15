# serialization

## Field serializers

可以通过`PlainSerializer` 和 `WrapSerializer` 对字段层面进行自定义序列化

`WrapSerializer` 支持在自定义函数中使用 `pydantic` 内置的序列化行为

### PlainSerializer

<details>
<summary>Example</summary>

```python
from typing import Annotated, Any

from pydantic import BaseModel, PlainSerializer, ConfigDict


def ser_number(value: Any) -> Any:
    if isinstance(value, MyValue):
        value = value.value

    if isinstance(value, int):
        return value * 2
    else:
        return value


class MyValue:
    def __init__(self, value):
        self.value = value


class Model(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    val: Annotated[MyValue, PlainSerializer(ser_number)]


print(Model(val=MyValue(10)).model_dump_json())
# > {"val":20}

print(Model(val=MyValue("v")).model_dump_json())
# > {"val":"v"}

```

</details>

### WrapSerializer

使用 `Annotated` 在注解时添加自定义序列化行为.

可以选择把序列化行为委托给 `SerializerFunctionWrapHandler` 参数获得序列化后的值

<details>
<summary>Example</summary>

```python
from typing import Annotated, Any

from pydantic import BaseModel, SerializerFunctionWrapHandler, WrapSerializer, ConfigDict


def ser_number(value: Any, handler: SerializerFunctionWrapHandler) -> Any:
    if isinstance(value, MyValue):
        value = value.value

    if isinstance(value, int):
        return value * 2
    else:
        return value


class MyValue:
    def __init__(self, value):
        self.value = value


class Model(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    val: Annotated[MyValue, WrapSerializer(ser_number)]


print(Model(val=MyValue(10)).model_dump_json())
# > {"val":20}

print(Model(val=MyValue("v")).model_dump_json())
# > {"val":"v"}
```

</details>

## Model serializers

使用 `model_serializer` 装饰器注册一个实现模型层面的序列化函数

### PlainSerializer

<details>
<summary>Example</summary>

```python
from pydantic import BaseModel, model_serializer, ConfigDict


class MyValue:
    def __init__(self, value):
        self.value = value


class Model(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    val: MyValue

    @model_serializer(mode="plain")
    def serializer(self) -> dict:
        val = self.val.value * 2 if isinstance(self.val.value, int) else self.val.value
        return {"value": val}


print(Model(val=MyValue(10)).model_dump_json())
# > {"val":20}

print(Model(val=MyValue("v")).model_dump_json())
# > {"val":"v"}

```

</details>

### WarpSerializer

<details>
<summary>Example</summary>

```python
from pydantic import BaseModel, model_serializer, ConfigDict, SerializerFunctionWrapHandler
from datetime import datetime


class MyValue:
    def __init__(self, value):
        self.value = value


class Model(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True)
    val: MyValue

    @model_serializer(mode="wrap")
    def serializer(self, handler: SerializerFunctionWrapHandler) -> dict:
        if isinstance(self.val.value, datetime):
            return {"value": handler(self.val.value)}
        val = self.val.value * 2 if isinstance(self.val.value, int) else self.val.value
        return {"value": val}


print(Model(val=MyValue(10)).model_dump_json())
# > {"val":20}

print(Model(val=MyValue("v")).model_dump_json())
# > {"val":"v"}

print(Model(val=MyValue(datetime.fromisoformat("2025-01-01T12:00:00+0800"))).model_dump_json())
# > {"value":"2025-01-01T12:00:00+08:00"}

```

</details>
