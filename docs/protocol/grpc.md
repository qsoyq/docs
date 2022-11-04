## Python grpc 代码生成与目录结构

```shell
python -m grpc_tools.protoc -I./protos --python_out=. --grpc_python_out=.  ./protos/**/*.proto
```

```shell
# betterproto
python -m grpc_tools.protoc -I./protos --python_betterproto_out=./lib  ./protos/**/*.proto
```

例如, 有存在以下的目录结构

```
src
├── core
├── protos
│    └── grpcs
│        └── toolbox
│            └── toolbox.proto
├── grpcs
│    └── toolbox
│        ├── toolbox_pb2.py
│        └── toolbox_pb2_grpc.py
```

需要注意的时, 生成的 `*_pb2_grpc.py` 会导入对应的 `*_pb2.py` , 而导入的模块路径, 是与 {proto_path} 下的目录结构一致.

如将 `src/protos` 作为 `{proto_path}` , 那么 `toolbox_pb2_grpc.py` 对 `toolbox_pb2.py` 的导入语句如下

```python
from grpcs.toolbox import toolbox_pb2 as grpcs_dot_toolbox_dot_toolbox__pb2
```

除了保持 `src/protos/grpcs/` 目录结构与 `src/grpcs` 一致外, 另外的解决方案是通过 `PYTHONPATH` 或 `sys.path` , 将 `*_pb2.py` 所在的目录添加到 Python 解释器的包寻找路径.

## Python grpc 服务启动管理

一种策略是每个 `*_pb2_grpc.py` 文件所在的目录, 存在一个启动服务的入口文件.

这种实现下, 每个服务单独部署, 符合微服务的接口最小职责定义.

但是考虑到实际需求, 比如方便本地测试部署, 那么将多个微服务挂载到一个服务上, 有是有必要的.

思路是每个 `*_pb2_grpc.py` 文件所在的目录, 对外暴露一个 `service.py` , 提供 `add_servicer_to_serve` 的回调, 将对应的服务下的方法绑定的要启动的服务上.

在统一的服务启动入口, 通过配置, 去加载不同服务下的 `service.py` , 并调用 `add_servicer_to_serve` 回调.

```python
def add_servicer_to_serve(server: _Server):
    toolbox_pb2_grpc.add_toolboxServicer_to_server(Toolbox(), server)
```

## Python grpc 客户端管理

Grpc 客户端通过 `insecure_channel` 获得 channel 对象, channel 对象绑定了服务的地址.

每个 `*_pb2_grpc.py` , 提供了 `*Stub` 方法, 获得一个 `stub` 对象, 封装了可调用的 rpc 方法.

对于连接的每个服务地址, 仅有在第一次发起 rpc 调用的时候, 才会建立真正的连接.

所以对于每个内部服务, 启动后, 可以加载并保存所有微服务的 `channel` 和 `stub` 对象.

这么做既方便了客户端代码的维护, 又没有额外的网络开销.

## FAQ

> Mac Apple Silicon 下安装 grpcio 编译异常

尝试在导出以下环境变量后继续安装依赖

```shell
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=true
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=true
```

> grpc-python 客户端未指定端口导致的请求异常

在 `grpc-python` 客户端中使用 `grpc.insecure_channel` 访问目标时, 如果未指定 `target` 的端口, 则默认使用 `443` 端口进行访问.

通过 `{host}:{port}` 指定端口的格式, 会更加明确.
