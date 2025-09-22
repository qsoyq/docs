# Dataclasses

## 基础用法

### 使用frozen参数

默认的`dataclass`因为不支持 `hash` 导致无法作为 set 的一个元素.

通过添加`frozen=True`, 使对象支持 `hash`.

同时, 所有属性在实例化之后仅可读，不可修改

<details>

<summary>查看代码示例</summary>

```python
@dataclass(frozen=True)
class DouyinPlaywrightTask:
    username: str
    cookie: str
```

</details>

### 使用 asdict 转换为 dict

通过 `asdict` 函数将`Dataclass` 实例转换为 `dict` 对象

<details>

<summary>查看代码示例</summary>

```python
import json
from dataclasses import dataclass, asdict
@dataclass
class CurlDetail:
    url: str
    body: str | None
    headers: dict
    method: str

    def to_json(self) -> str:
        return json.dumps(asdict(self), ensure_ascii=False)
```

</details>
