# grpc

## 如何在客户端设置 Header 调研

### 背景

为了支持 traefik 基于`host`的反向代理规则, 所有 grpc 客户端只维持指向 traefik 的一条连接, traefik 会负载均衡到相应的后端节点.

在 grpc 客户端中指定 metadata 的方式, 并不能修改HTTP2 请求中的 `host` Header.

为了解 grpc-python 对 host 的处理, 主要阅读 channel 相关的代码

`grpc.__init__` 中有对 Channel 的抽象, `grpc._channel.Channel` 有对 channel 的具体实现.

### 源码溯源

以 unary-unary 方法请求为例.

> `grpc._channel._channel_managed_call_management.create` == `grpc._channel._UnaryUnaryMultiCallable._managed_call`

- `grpc._channel.Channel.unary_unary`
    - `grpc._channel._UnaryUnaryMultiCallable`
        - `grpc._channel._channel_managed_call_management`
            - 首次调用时, 初始化
        `grpc._channel._UnaryUnaryMultiCallable.__call__`
            - `grpc._channel._UnaryUnaryMultiCallable._blocking`
                - `grpc._channel._UnaryUnaryMultiCallable._prepare`
                - `grpc._cython.cygrpc.Channel.segregated_call`
            - `grpc._channel._end_unary_response_blocking`

实际的网络请求处理, 发生在`segregated_call`.

而对应的 Channel 对象, 是`grpc._cython.cygrpc.Channel`的实例对象.

对应的本地文件为 `grpc/_cython/cygrpc.cpython-39-darwin.so`

因为没找到这部分 C 代码, 只能暂时搁置.

### 结论

grpc 提供了 metadata, 通过读写 metadata, 来达到 header 相关的需求.

对于 host, 虽然底层函数支持指定, 但用户使用的高层接口, 未暴露该参数, 所以

### 备用方案

#### 修改 hosts

将对应的 grpc 服务名作为访问地址, 并在 hosts 中加入服务名到 traefik 地址的映射.

服务名在 dns 正向解析后即为 traefik 的 ip 地址.

如此一来, 就不需要修改 host 请求头.

缺点是比较繁琐, 要么是借助于权限, 在程序运行时通过代码读写 `hosts` 文件, 要么是部署时, 将对应的服务名, 通过运维方式写入.

#### 猴子补丁

从 `grpc._channel._channel_managed_call_management.create` 猜测, 接口预留了`host` 参数, 但是目前的上层代码并没有暴露对应的参数.

而`segregated_call`的函数签名也与`grpc._channel._channel_managed_call_management.create` 保持一致.

那么基于猴子补丁, 定制 `_UnaryUnaryMultiCallable`, `_UnaryStreamMultiCallable`, `_StreamUnaryMultiCallable`, `_StreamStreamMultiCallable`  并重写 `_blocking` 方法, 将 `host` 参数传递到 `segregated_call` 内.

[![grpc_call_blocking_before]][grpc_call_blocking_before]

[grpc_call_blocking_before]: /assets/images/grpc_call_blocking_before.png

[![grpc_call_blocking_after]][grpc_call_blocking_after]

[grpc_call_blocking_after]: /assets/images/grpc_call_blocking_after.png

优点是非常灵活, 可以轻松修改组件逻辑.

缺点是过于灵活, 可读性极差, 容易埋雷, 尤其是在版本更新的时候.

##### sitecustomize 实现猴子补丁

并通过以下命令写到本地目录

```shell
cat sitecustomize.py > $(python -c "import site;print(f'{site.getsitepackages()[0]}/sitecustomize.py')")
```

```python
import os

from typing import Optional

try:
    import pretty_errors
except ImportError:
    print(
        'You have uninstalled pretty_errors but it is still present in your python startup.' +
        '  Please remove its section from file:\n ' + __file__ + '\n'
    )

import grpc._channel

from grpc._channel import (
    _EMPTY_FLAGS,
    _STREAM_STREAM_INITIAL_DUE,
    _STREAM_UNARY_INITIAL_DUE,
    _UNARY_STREAM_INITIAL_DUE,
    _compression,
    _consume_request_iterator,
    _deadline,
    _determine_deadline,
    _event_handler,
    _handle_event,
    _InitialMetadataFlags,
    _MultiThreadedRendezvous,
    _RPCState,
    _start_unary_request,
    _stream_unary_invocation_operationses_and_tags,
    cygrpc
)

grpc_services_target_header_host: Optional[str] = os.getenv('grpc_services_target_header_host', None)
grpc_services_target_header_host = grpc_services_target_header_host.encode() if grpc_services_target_header_host else None


class MyUnaryUnaryMultiCallable(grpc._channel._UnaryUnaryMultiCallable):
    HOST: Optional[bytes] = grpc_services_target_header_host

    def _blocking(self, request, timeout, metadata, credentials, wait_for_ready, compression):
        state, operations, deadline, rendezvous = self._prepare(
            request, timeout, metadata, wait_for_ready, compression)
        if state is None:
            raise rendezvous  # pylint: disable-msg=raising-bad-type
        else:

            call = self._channel.segregated_call(
                cygrpc.PropagationConstants.GRPC_PROPAGATE_DEFAULTS,
                self._method,
                self.HOST,
                _determine_deadline(deadline),
                metadata,
                None if credentials is None else credentials._credentials,
                ((
                    operations,
                    None,
                ),
                ),
                self._context
            )
            event = call.next_event()
            _handle_event(event, state, self._response_deserializer)
            return state, call


class MyUnaryStreamMultiCallable(grpc._channel._UnaryStreamMultiCallable):
    HOST: Optional[bytes] = grpc_services_target_header_host

    def __call__(  # pylint: disable=too-many-locals
            self,
            request,
            timeout=None,
            metadata=None,
            credentials=None,
            wait_for_ready=None,
            compression=None):
        deadline, serialized_request, rendezvous = _start_unary_request(request, timeout, self._request_serializer)
        initial_metadata_flags = _InitialMetadataFlags().with_wait_for_ready(wait_for_ready)
        if serialized_request is None:
            raise rendezvous  # pylint: disable-msg=raising-bad-type
        else:
            augmented_metadata = _compression.augment_metadata(metadata, compression)
            state = _RPCState(_UNARY_STREAM_INITIAL_DUE, None, None, None, None)
            operationses = (
                (
                    cygrpc.SendInitialMetadataOperation(augmented_metadata,
                                                        initial_metadata_flags),
                    cygrpc.SendMessageOperation(serialized_request,
                                                _EMPTY_FLAGS),
                    cygrpc.SendCloseFromClientOperation(_EMPTY_FLAGS),
                    cygrpc.ReceiveStatusOnClientOperation(_EMPTY_FLAGS),
                ),
                (cygrpc.ReceiveInitialMetadataOperation(_EMPTY_FLAGS),
                 ),
            )
            call = self._managed_call(
                cygrpc.PropagationConstants.GRPC_PROPAGATE_DEFAULTS,
                self._method,
                self.HOST,
                _determine_deadline(deadline),
                metadata,
                None if credentials is None else credentials._credentials,
                operationses,
                _event_handler(state,
                               self._response_deserializer),
                self._context
            )
            return _MultiThreadedRendezvous(state, call, self._response_deserializer, deadline)


class MyStreamUnaryMultiCallable(grpc._channel._StreamUnaryMultiCallable):

    HOST: Optional[bytes] = grpc_services_target_header_host

    def _blocking(self, request_iterator, timeout, metadata, credentials, wait_for_ready, compression):
        deadline = _deadline(timeout)
        state = _RPCState(_STREAM_UNARY_INITIAL_DUE, None, None, None, None)
        initial_metadata_flags = _InitialMetadataFlags().with_wait_for_ready(wait_for_ready)
        augmented_metadata = _compression.augment_metadata(metadata, compression)
        call = self._channel.segregated_call(
            cygrpc.PropagationConstants.GRPC_PROPAGATE_DEFAULTS,
            self._method,
            self.HOST,
            _determine_deadline(deadline),
            augmented_metadata,
            None if credentials is None else credentials._credentials,
            _stream_unary_invocation_operationses_and_tags(augmented_metadata,
                                                           initial_metadata_flags),
            self._context
        )
        _consume_request_iterator(request_iterator, state, call, self._request_serializer, None)
        while True:
            event = call.next_event()
            with state.condition:
                _handle_event(event, state, self._response_deserializer)
                state.condition.notify_all()
                if not state.due:
                    break
        return state, call


class MyStreamStreamMultiCallable(grpc._channel._StreamStreamMultiCallable):
    HOST: Optional[bytes] = grpc_services_target_header_host

    def __call__(
        self,
        request_iterator,
        timeout=None,
        metadata=None,
        credentials=None,
        wait_for_ready=None,
        compression=None
    ):
        deadline = _deadline(timeout)
        state = _RPCState(_STREAM_STREAM_INITIAL_DUE, None, None, None, None)
        initial_metadata_flags = _InitialMetadataFlags().with_wait_for_ready(wait_for_ready)
        augmented_metadata = _compression.augment_metadata(metadata, compression)
        operationses = (
            (
                cygrpc.SendInitialMetadataOperation(augmented_metadata,
                                                    initial_metadata_flags),
                cygrpc.ReceiveStatusOnClientOperation(_EMPTY_FLAGS),
            ),
            (cygrpc.ReceiveInitialMetadataOperation(_EMPTY_FLAGS),
             ),
        )
        event_handler = _event_handler(state, self._response_deserializer)
        call = self._managed_call(
            cygrpc.PropagationConstants.GRPC_PROPAGATE_DEFAULTS,
            self._method,
            self.HOST,
            _determine_deadline(deadline),
            augmented_metadata,
            None if credentials is None else credentials._credentials,
            operationses,
            event_handler,
            self._context
        )
        _consume_request_iterator(request_iterator, state, call, self._request_serializer, event_handler)
        return _MultiThreadedRendezvous(state, call, self._response_deserializer, deadline)


grpc._channel._UnaryUnaryMultiCallable = MyUnaryUnaryMultiCallable
grpc._channel._UnaryStreamMultiCallable = MyUnaryStreamMultiCallable
grpc._channel._StreamUnaryMultiCallable = MyStreamUnaryMultiCallable
grpc._channel._StreamStreamMultiCallable = MyStreamStreamMultiCallable
```

## betterproto

### 流式响应中的 AsyncIterator

betterproto 在生成代码时, 会将流式响应的返回值定义为`AsyncIterator`.

在使用 `mypy` 检查的时候, 会提示使用了 `yield`的响应类型不匹配 `AsyncIterator`.

```shell
error: Return type "AsyncIterator[SubResponse]" of "sub" incompatible with return type "Coroutine[Any, Any, AsyncIterator[SubResponse]]" in supertype "RedisStreamServiceBase"
```

[![py_grpc_bp_ai]][py_grpc_bp_ai]

[py_grpc_bp_ai]: /assets/images/py_grpc_bp_ai.png

实际上, 在 `async def` 中, 使用 `yield` 关键字能实现 `AsyncIterator` 需要的功能.

而定义为 `AsyncIterator`, 函数需要返回一个实现了 `__aiter__` 和 `__anext__` 方法的对象, 不如直接使用 `yield` 关键字返回响应.

如果函数的响应定义为例如 `Coroutine[Any, Any, AsyncIterator[Any]`, 会更加友好.
