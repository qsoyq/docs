# PyYAML

## 序列化

### width

序列化时会对过长字符串进行换行拆分

如代码所示，在默认情况下，对于字符串长度高于某个值时，会对序列号的字符串跨行，对于某些会兼容跨行字符串的应用会有冲突，例如`Stash`内的脚本参数

通过指定 width 参数来避免字符串换行

`yaml.safe_dump(payload, width=1000)`

<details>

<summary>查看示例代码</summary>

```python
import json
import yaml


def main():
    jsonstr = json.dumps({x: x for x in range(10)})
    payload = {"http": {"mitm": [{"argument": jsonstr}]}}
    print(yaml.safe_dump(payload))
    # http:
    #   mitm:
    #   - argument: '{"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8":
    #       8, "9": 9}'

    print(yaml.safe_dump(payload, width=1000))
    # http:
    #   mitm:
    #   - argument: '{"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9}'


if __name__ == "__main__":
    main()
```

</details>

#### 回顾

但是`width`应该设置为多少?  

有没有更优雅的方式？

### sort_keys

默认情况下, 会对导出的对象安装字典序排序后再输出序列化后的内容

可以通过 `sort_keys=False` 禁止这个行为

而高版本的 Python 内部是假定有序的, 所以最后的输出内容就会按照赋值时的顺序排列.

为了保险, 也可以使用 `collections.OrderedDict` 维护有序字典

<details>

<summary>查看示例代码</summary>

```python
policy = {}
body = {
    "name": f"nameserver-policy-geosite",
    "desc": "基于 geosite 动态生成的 nameserver-policy 覆写策略",
    "icon": "https://stash.wiki/favicon.ico",
    "category": "dns",
    "dns": {"nameserver-policy": policy},
}

yaml.safe_dump(body, width=9999, allow_unicode=True, sort_keys=False)
```

</details>
