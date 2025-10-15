# Model

内容基于`2.12`

通过定义 Scheme, pydantic 将输入转换为对应的实例

## 基础

### validation

pydantic 对输入数据解析后验证是否可输出为注解要求的类型和行为.

验证是对于输出的结果, 而不是输入的数据

- `model_validate()`, 实例化并验证
- `model_validate_json()`, 通过 json 数据进行实例化并验证
- `model_construct()`, 实例化但不进行验证

### dump

> Calling dict on the instance will also provide a dictionary, but nested fields will not be recursively converted into dictionaries. model_dump() also provides numerous arguments to customize the serialization result.

使用`dict`实例化对象不会递归处理嵌套子字段, 但是调用对象的`dict`、`model_dump`方法, 可以递归将子字段转换为字典

<details>
<summary>Example</summary>

```python
from pydantic import BaseModel, ConfigDict


class Attribute(BaseModel):
    value: str


class User(BaseModel):
    id: int
    name: str = "Jane Doe"
    attributes: list[Attribute]
    model_config = ConfigDict(str_max_length=10)


u = User(id=1, attributes=[Attribute(value="1"), Attribute(value="1"), Attribute(value="1")], bar={"whatever": 123})
print(u.attributes)
# [Attribute(value='1'), Attribute(value='1'), Attribute(value='1')]
print(u.model_dump())
# {'id': 1, 'name': 'Jane Doe', 'attributes': [{'value': '1'}, {'value': '1'}, {'value': '1'}]}
print(u.dict())
# {'id': 1, 'name': 'Jane Doe', 'attributes': [{'value': '1'}, {'value': '1'}, {'value': '1'}]}
print(dict(u))
# {'id': 1, 'name': 'Jane Doe', 'attributes': [Attribute(value='1'), Attribute(value='1'), Attribute(value='1')]}

```

</details>

### BaseModel Vs Dataclass

基于 `https://github.com/pydantic/pydantic/issues/710` 上的讨论, `Dataclass` 提供的是带验证的`dataclasses.dataclass`, 对于使用上的行为是接近于`dataclasses.dataclass` 而不是 `BaseModel`

`pydantic.dataclasses` 适合那些需要维护 `dataclasses.dataclass` 的用户群体, 并在此基础上享受 `pydantic` 带来的一些便利性

从最终目标看, 提供的是一个迁移的桥梁, 一个过渡.

详细的使用细节见`https://docs.pydantic.dev/2.12/concepts/dataclasses/`

### Generic models

泛型在实例化、转换、序列化时，都可能因为泛型绑定的类型而丢失数据， 需要警惕使用

- <https://docs.pydantic.dev/2.12/concepts/models/#generic-models>

#### type parameter syntax

`3.12` 以上的版本直接在语法层面支持泛型

<details>
<summary>Example</summary>

```python
from pydantic import BaseModel, ValidationError


class DataModel(BaseModel):
    number: int


class Response[DataT](BaseModel):  
    data: DataT  


print(Response[int](data=1))
#> data=1
print(Response[str](data='value'))
#> data='value'
print(Response[str](data='value').model_dump())
#> {'data': 'value'}

data = DataModel(number=1)
print(Response[DataModel](data=data).model_dump())
#> {'data': {'number': 1}}
try:
    Response[int](data='value')
except ValidationError as e:
    print(e)
    """
    1 validation error for Response[int]
    data
      Input should be a valid integer, unable to parse string as an integer [type=int_parsing, input_value='value', input_type=str]
    """
```

</details>

### Dynamic Model Creation

动态创建模型类

<details>
<summary>Example</summary>

```python
from pydantic import BaseModel, create_model

DynamicFoobarModel = create_model('DynamicFoobarModel', foo=str, bar=(int, 123))

# Equivalent to:


class StaticFoobarModel(BaseModel):
    foo: str
    bar: int = 123
```

</details>

### RootModel

对于一些单一值, 适合使用`RootModel`来进行封装, 以执行参数的验证

<details>
<summary>Example</summary>

```python
from pydantic import RootModel


class Pets(RootModel):
    root: list[str]

    def __iter__(self):
        return iter(self.root)

    def __getitem__(self, item):
        return self.root[item]



pets = Pets.model_validate(['dog', "cat"])
print(pets[0])
#> dog
print([pet for pet in pets])
#> ['dog', 'cat']

Pet = RootModel[str]
print(Pet("dog").model_dump())
#> dog
```

</details>

### Automatically excluded attributes

#### Class variables

通过 `typing.ClassVar` 注释字段为类变量, 以避免作为实例属性使用

<details>
<summary>Example</summary>

```python
from typing import ClassVar

from pydantic import BaseModel


class Model(BaseModel):
    x: ClassVar[int] = 1

    y: int = 2


m = Model()
print(m)
#> y=2
print(Model.x)
#> 1
print(m.model_dump())
#> {'y': 2}
```

</details>

#### Private model attributes

使用`_`开头并使用`pydantic.PrivateAttr` 作为注解的字段, 不会被视为模型的实例属性, 而是作为私有属性保留

<details>
<summary>Example</summary>

```python
from datetime import datetime
from random import randint
from typing import Any

from pydantic import BaseModel, PrivateAttr


class TimeAwareModel(BaseModel):
    _processed_at: datetime = PrivateAttr(default_factory=datetime.now)
    _secret_value: str

    def model_post_init(self, context: Any) -> None:
        # this could also be done with `default_factory`:
        self._secret_value = randint(1, 5)


m = TimeAwareModel()
print(m._processed_at)
#> 2032-01-02 03:04:05.000006
print(m._secret_value)
#> 3
```

</details>

### rebuild scheme

pydantic 支持在任意时刻为 model 执行 rebuild 以搜集依赖的引用

<details>
<summary>Example</summary>

```python
from pydantic import BaseModel, PydanticUserError


class Foo(BaseModel):
    x: 'Bar'  


try:
    Foo.model_json_schema()
except PydanticUserError as e:
    print(e)
    """
    `Foo` is not fully defined; you should define `Bar`, then call `Foo.model_rebuild()`.

    For further information visit https://errors.pydantic.dev/2/u/class-not-fully-defined
    """


class Bar(BaseModel):
    pass


Foo.model_rebuild()
print(Foo.model_json_schema())
"""
{
    '$defs': {'Bar': {'properties': {}, 'title': 'Bar', 'type': 'object'}},
    'properties': {'x': {'$ref': '#/$defs/Bar'}},
    'required': ['x'],
    'title': 'Foo',
    'type': 'object',
}
"""
```

</details>

### Arbitrary class instances

支持从其他对象的属性实例化 Model 对象

<details>
<summary>Example</summary>

```python
from typing import Annotated

from sqlalchemy import ARRAY, String
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

from pydantic import BaseModel, ConfigDict, StringConstraints


class Base(DeclarativeBase):
    pass


class CompanyOrm(Base):
    __tablename__ = 'companies'

    id: Mapped[int] = mapped_column(primary_key=True, nullable=False)
    public_key: Mapped[str] = mapped_column(
        String(20), index=True, nullable=False, unique=True
    )
    domains: Mapped[list[str]] = mapped_column(ARRAY(String(255)))


class CompanyModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    public_key: Annotated[str, StringConstraints(max_length=20)]
    domains: list[Annotated[str, StringConstraints(max_length=255)]]


co_orm = CompanyOrm(
    id=123,
    public_key='foobar',
    domains=['example.com', 'foobar.com'],
)
print(co_orm)
#> <__main__.CompanyOrm object at 0x0123456789ab>
co_model = CompanyModel.model_validate(co_orm)
print(co_model)
#> id=123 public_key='foobar' domains=['example.com', 'foobar.com']
```

</details>

### Attribute copies

引用参数在传递给模型进行初始化时会对参数进行浅拷贝复制而不是直接保存.

<details>
<summary>Example</summary>

```python
from pydantic import BaseModel


class C1:
    arr = []
    body: dict = {}

    def __init__(self, in_arr, in_dict):
        self.arr = in_arr
        self.body = in_dict


class C2(BaseModel):
    arr: list[int]
    body: dict


arr_orig = [1, 9, 10, 3]
dict_orig = {"key": [1,2,3]}


c1 = C1(arr_orig, dict_orig)
c2 = C2(arr=arr_orig, body=dict_orig)
print(f'{id(c1.arr) == id(c2.arr)=}')
#> id(c1.arr) == id(c2.arr)=False
print(f'{id(c1.body) == id(c2.body)=}')
#> id(c1.body) == id(c2.body)=False
print(f'{id(c1.body["key"]) == id(c2.body["key"])=}')
#> id(c1.body["key"]) == id(c2.body["key"])=True
```

</details>

## Examples

### extra allow

默认情况下, pydantic 会丢弃与定义不相关的字段.

通过设置 `config.extra` 属性, 允许透传额外字段不进行任何处理.

<details>
<summary>Example</summary>

```python
from pydantic import BaseModel, ConfigDict


class Model(BaseModel):
    x: int

    model_config = ConfigDict(extra='allow')


m = Model(x=1, y='a')  
assert m.model_dump() == {'x': 1, 'y': 'a'}
assert m.__pydantic_extra__ == {'y': 'a'}
```

</details>
