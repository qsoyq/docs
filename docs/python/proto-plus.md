# proto-plus

- [proto-plus](https://googleapis.dev/python/proto-plus/latest/)
- [Type Marshaling](https://googleapis.dev/python/proto-plus/latest/marshal.html)

## 类型转换

### to_dict

在对`proto`对象进行`to_dict`转换为`dict`时, 会对`bytes`对象进行 base64 编码以保留语义

<details>
<summary>查看代码示例</summary>

```python
import proto
from google.protobuf.json_format import ParseDict

class MyMessage(proto.Message):
    data = proto.Field(proto.BYTES, number=1)

msg = MyMessage(data=b"this is a message")
msg_dict = MyMessage.to_dict(msg)

# Note: the value is the base64 encoded string of the bytes field

# It has a type of str, NOT bytes

assert type(msg_dict['data']) == str

msg_pb = ParseDict(msg_dict, MyMessage.pb())
msg_two = MyMessage(msg_dict)

assert msg == msg_pb == msg_two
```

</details>

## 赋值拷贝

当一个字段赋值给另外一个字段时，采取拷贝而非引用

可以通过重新赋值来更新拷贝

<details>
<summary>查看代码示例</summary>

```python
composer = Composer(given_name="Johann", family_name="Bach")
song = Song(title="Tocatta and Fugue in D Minor", composer=composer)
composer.given_name = "Wilhelm"

# 'composer' is NOT a reference to song.composer
assert song.composer.given_name == "Johann"

# We CAN update the song's composer by assignment.
song.composer = composer
composer.given_name = "Carl"

# 'composer' is STILL not a reference to song.composer.
assert song.composer.given_name == "Wilhelm"

# It does work in reverse, though,
# if we want a reference we can access then update.
composer = song.composer
composer.given_name = "Gottfried"

assert song.composer.given_name == "Gottfried"

# We can use 'copy_from' if we're concerned that the code
# implies that assignment involves references.
composer = Composer(given_name="Elisabeth", family_name="Bach")
# We could also do Message.copy_from(song.composer, composer) instead.
Composer.copy_from(song.composer, composer)

assert song.composer.given_name == "Elisabeth"
```

</details>

## 示例

### 解析 v2fly geosite dat 数据

<details>

<summary>查看示例代码</summary>

```python

import httpx
from enum import IntEnum
import proto

class DomainTypeEnum(IntEnum):
    Domain_Plain = 0
    Domain_Regex = 1
    Domain_RootDomain = 2
    Domain_Full = 3

class Domain_Attribute(proto.Message):
    key = proto.Field(proto.STRING, number=1)
    bool_value = proto.Field(proto.BOOL, number=2, oneof="typed_value")
    int_value = proto.Field(proto.INT64, number=3, oneof="typed_value")

class Domain(proto.Message):
    type = proto.Field(proto.INT32, number=1)
    value = proto.Field(proto.STRING, number=2)
    attribute = proto.RepeatedField(Domain_Attribute, number=3)

class GeoSite(proto.Message):
    country_code = proto.Field(proto.STRING, number=1)
    domain = proto.RepeatedField(Domain, number=2)
    resource_hash = proto.RepeatedField(proto.BYTES, number=3)
    code = proto.Field(proto.STRING, number=4)
    file_path = proto.Field(proto.STRING, number=5)

class GeoSiteList(proto.Message):
    entry = proto.RepeatedField(GeoSite, number=1)

def main():
    res = httpx.get("<https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat>", follow_redirects=True)
    geosite_list = GeoSiteList.deserialize(res.content)
    cnt = 0
    for entry in geosite_list.entry:
        for domain in entry.domain:
            cnt += 1
            print(f"{entry.country_code} - {DomainTypeEnum(domain.type).name} - {domain.value} - {domain.attribute}")
    print(cnt)

main()

```

</details>
