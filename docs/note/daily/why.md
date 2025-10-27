
## Golang

### Dialer Default Timeout

```go
// Why 32? See https://github.com/docker/docker/pull/8035.
const defaultTimeout = 32 * time.Second
```

[Add timeout to client](https://github.com/moby/moby/pull/8035)

好像也没解释为什么是 32

### RuntimeError(“Task … running at … got Future … attached to a different loop”

[RuntimeError(“Task … running at … got Future … attached to a different loop”](https://github.com/pytest-dev/pytest-asyncio/issues/207#issue-859865020)

因为不清楚 `pytest-asyncio` 的逻辑, 所以不知道 `event_loop` 是如何解决问题的.

猜测是在多个测试中对资源的清理不当造成的.

比如多个用例之间同时引用了一个单例对象, 这个对象所依赖的 loop 对象在另外个测试中已经被关闭.

具体分析还是得找时间研究下`pytest-asyncio`的源代码.

```python
@pytest.fixture(scope="session")
def event_loop() -> Generator:
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()
```

## Python

### pysocks

在使用 `pysocks` 代替 `socket` 库进行 udp 客户端测试的时候, `sendto` 接口抛出了 `OSError`.

而相同的参数和接口, 使用 `socket` 模块是正常运作的.

```python

    s = socks.socksocket(socket.AF_INET, socket.SOCK_DGRAM)
    # s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    dst = (host, port)
    text = b"message"
    s.sendto(text, dst)
```

```python
E       OSError: [Errno 39] Destination address required

../../.pyenv/versions/3.10.0/lib/python3.10/site-packages/socks.py:379: OSError
```

在调用 `set_proxy` 后 `sendto`接口才恢复正常运作.

## uptime-kuma

### AxiosError: maxContentLength size of -1 exceeded

uptime-kuma 前端使用了 axios, 频繁出现`maxContentLength size of -1 exceeded`的报错.

[Check of running Websites results in error "maxContentLength size of -1 exceeded"](https://github.com/louislam/uptime-kuma/issues/2253)

[AxiosError: maxContentLength size of -1 exceeded](https://github.com/axios/axios/issues/4806)
