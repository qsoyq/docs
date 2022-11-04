# Provider

Provider 实现对数据源的订阅, 由`ProviderAggregator`启动.

收集到的数据, 会流转到 `Watcher` 进行格式化, 并由 `Watch` 合并后流转到 `Listening`, 实现内部组件的更新.

`Watcher` 首次监听动态消息时, 必然会等待`InternalProvider` 加载完动态消息

而 `InternalProvider`也仅在程序启动时, 由`ProviderAggregator`启动一次, 完成内置组件的初始化

## FileProvider

FileProvider 可以监控目录或文件, 当选择监控目录时, 不可以单独指定再监控额外的文件.

- `BuildConfiguration` 读取指定目录或指定文件, 实例化 `dynamic.Configuration` 对象
- `fsnotify` 监控目录, 当接收到事件时, 执行`watcherCallback`
- 后台监听`fsnotify` 事件, 并重新实例化 `dynamic.Configuration` 写入 Channel, 等待 watcher 消费

## InternalProvider

### 内置组件

- apiConfiguration
- pingConfiguration
- restConfiguration
- prometheusConfiguration
- entryPointModels
- redirection
- serverTransport
- acme

## DockerProvider

`traefik/pkg/provider/docker/docker.go`

1. 使用 `cenkalti/backoff/v4` 作为重试策略.
2. 按照退避策略执行`operation`
    1. 实例化 Docker API Client
    2. 获取 DockerData
        1. `listServices`获取 `SwarmMode`下的DockerData
        2. `listContainers` 获取非`SwarmMode`下的 DockerData
3. `buildConfiguration` 基于 DockerData 构建动态配置
4. 根据`Watch`执行订阅
    1. `SwarmMode`下的订阅
        1. 间隔`SwarmModeRefreshSeconds`(默认15s), `listServices` 获取 DockerData 并 `buildConfiguration` 生成配置
    2. 非`SwarmMode`下的订阅
        1. 订阅 docker events, 仅在`start`, `die`, `health_status*` 情况下执行`startStopHandle`回调

## 注意事项

### Provider 类型

每个 `ProviderAggregator` 只能持有一个 `FileProvider`和`TraefikProvider`, 每当添加此类 Provider 时只会覆盖.

### FileProvider 监听目录

FileProvider 只监听目录变化, 而不在乎对应的 Event 事件.  每当目录变化, 都会通过`BuildConfiguration` 实例化 ``dynamic.Configuration``.

### 前台运行 Provider

`FileProvider` 和 `InternalProvider` 是在前台运行的, 其他的 Provider 会创建一个`goroutine`在后台运行.

并且 `FileProvider` 最先运行, `TraefikProvider` 最后运行

### DockerProvider 运行机制

在非`DockerSwarm`的前提下, 如果启用了 `Watch`, DockerProvider 在执行 Provide 的时候, 会订阅 docker api 的`/events`接口, 并在循环里消费对应的事件来生成动态配置.

DockerProvider 使用 `github.com/cenkalti/backoff/v4` 作为重试, 对于非`SwarmMode`下的 `Watch`, 当请求docker `/events` 异常后, 就会在一段时间后重新执行.

DockerProvider 的 backoff 是按照`cenkalti/backoff/v4` 的指数退避, 需要注意在 traefik 并非 docker 部署的模式下, 当 `operation`执行失败后每次等待延迟会不断递增, 直到每次的阻塞时间都会很长.

对于云原生代理而已, 动态发现的延迟时间过高是不符合预期的, 所以这点需要额外处理.

比如限制 backoff 的 `MaxInterval` 因子, 或者按retry 次数 Reset 重新初始化因子.

## 一些想法

### Docker Provider SwarmModeRefreshSeconds

DockerSwarm 模式下的 15 秒默认时间对于需要高可用的服务而言有点太长了.

理想的时间个人认为应该在 1-10s.

### Docker API

部分 docker api 针对 GET 请求, `querystring` 中有一些复杂字段的时候, 会将字段序列化成 json.

如 `/events` 接口传递`filters`字段.

部分针对 RESTful 设计时, 都会表达对 `filter` 这种复杂字段如何传递的担忧.

其实像这样序列化字段再反序列化, 只要双方约定, 并且封装好相关的组件, 除了在文档上的表示需要定制以外, 确实是一种很好的办法.
