# PyYAML

## 序列化时会对过长字符串进行换行拆分

### 原因

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

如代码所示，在默认情况下，对于字符串长度高于某个值时，会对序列号的字符串跨行，对于某些会兼容跨行字符串的应用会有冲突，例如`Stash`内的脚本参数

### 解决方案

#### 设置 Width 参数

`yaml.safe_dump(payload, width=1000)`

正如代码所示，修改 `width` 参数后，即可。

但是`width`应该设置为多少?  

有没有更优雅的方式？
