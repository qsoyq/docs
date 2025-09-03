# Watcher

实现动态配置的更新.

监听各种 Provider, 收集从 Provider 收集的动态配置, 并更新.

- Start
    - receiveConfigurations
    - applyConfigurations
    - startProviderAggregator

## ReceiveConfigurations

接收动态配置文件

1. 监听 Server Context Done.
2. 监听 `allProvidersConfigs`
3. `newConfigurations`, 写入 `output`, 重置 `output`
4. `logConfiguration` 输出动态配置到日志.
5. `reflect.DeepEqual` 对比本地动态配置与刚接收到的动态配置是否一致
6. 将收到的动态配置写入到本地变量`newConfigurations`
7. 将 `output` 绑定到`ConfigurationWatcher`

## ApplyConfigurations

更新动态配置

1. 监听`ConfigurationWatcher.newConfigs`
2. 更新 `ConfigurationWatcher.requiredProvider` 对应的Privider 写入的动态配置信息.
3. 合并动态配置和`ConfigurationWatcher.defaultEntryPoints`
4. `applyModel` 实例化动态路由配置
5. 传递动态配置, 由 listener 执行更新逻辑

## StartProviderAggregator

启动聚合提供者, 定时收集 Provider 内的动态配置信息.

1. 调用 `(ProviderAggregator).Provide`, 执行每个 provider 的 provide 方法收集动态配置
    1. `launchProvider` 执行对应 Provider
    2. `RemoveCredentials` 根据 tag 信息中的`loggable` 来重置敏感字段为零值
    3. 去敏后的动态配置信息输出到日志
    4. `maybeThrottledProvide` 执行 Provider 的 Provide 方法

## 注意事项

### DefaultEntryPoints

`ConfigurationWatcher.defaultEntryPoints` 是对静态配置执行 `getDefaultsEntrypoints` 获得的所有 `name` 不为 `traefik` 且 `protocol` 为 `tcp` 的 `EntryPoints`

```go
func getDefaultsEntrypoints(staticConfiguration *static.Configuration) []string {
 var defaultEntryPoints []string
 for name, cfg := range staticConfiguration.EntryPoints {
  protocol, err := cfg.GetProtocol()
  if err != nil {
   // Should never happen because Traefik should not start if protocol is invalid.
   log.WithoutContext().Errorf("Invalid protocol: %v", err)
  }

  if protocol != "udp" && name != static.DefaultInternalEntryPointName {
   defaultEntryPoints = append(defaultEntryPoints, name)
  }
 }

 sort.Strings(defaultEntryPoints)
 return defaultEntryPoints
}
```

### RequiredProvider

`ApplyConfigurations` 在监听动态配置时, 仅当判断 `requiredProvider` 对应的配置存在时才会进入下一步.

目前 `requiredProvider` 对应的 `Provider` 是 `internal` .

### logConfiguration

仅当 log level 为 DEBUG 的情况下, 才会将动态配置的信息输出到日志.

而且 `logConfiguration` 发生在接收到 Provider 写入动态配置消息之后, 实际应用到全局之前.

在日志文件看到输出到对应动态配置生效是有一定间隔的, 比如在后续可能发生异常, 或者在传递给消费任务之前, Provider 又传递了新的动态配置, 导致看到的动态配置可能实际并未生效.

即在日志文件中看到动态配置的记录不代表动态配置已经生效.

在 `logConfiguration` 中, 会深拷贝一份动态配置, 并且重写清空涉敏信息.

涉敏信息包括证书相关信息.

所以不用担心动态配置的修改导致日志中出现关于证书的敏感信息.

但是其余信息如果涉敏, 就需要考虑是否要开启 DEBUG Mode了.

### mergeConfiguration

在更新动态配置时, 可能会对多个 Provider 写入的配置无序遍历后写入.

所有多个 Provider 如果存在冲突的配置项, 最终使用的配置项完全是随机的.

并且每次写入后, 冲突的部分, 都可能使用随机的配置项.

traefik 并没有对配置被覆盖的情况进行检测, 所以需要用户想办法留意.

### Provide

Provider 的执行顺序按 FileProvider -> Others -> InternalProvider 执行.

其中, `InternalProvider` 必须在最后执行, 因为需要知晓其他 providers 的加载情况.

同样的, `Internal` 作为 `RequiredProvider` , 动态配置必须加载到此条后, 才会进入处理流程.

### MaybeThrottledProvide

当 Provider 实现了 `throttled` 接口且返回的 `time.Duration` 不为 0 时, 会包装一层限流功能.

限流功能启用后, 会实例化一个 `RingChannel` , Provider 的所有写入都是基于 `RingChannel` , 并且保证每次写入都不会阻塞.

每次从 RingChannel 读到消息, 在写入 `configurationChan` , 会挂起 `ThrottleDuration` 对应的时间间隔.

合理利用限流功能, 可以减少 Provider 对 CPU 的占用.

### Provider 何时执行?

`providerAggregator` 会在 watch 启动时被调用, 然后调用 FileProvider -> Others Provider -> TraefikProvider.

每次 Provider 只会被`providerAggregator`调用一次.

FileProvider 在执行 Provide 时会通过`fsnotify` 监听目录变化来传递配置信息.

DockerProvider 在执行 Provide 后会根据`Watch`决定是否订阅, 根据`SwarmMode` 决定订阅的逻辑.

## 一些想法

### 动态配置同步生效机制

`receiveConfigurations` 在接收 Provider 传递的动态消息后, 并不会直接通过channel 传递给 `applyConfigurations` , 而是通过 `output` 变量, 在下一次 output 可写的时候, 将缓存的多个 Provider 动态配置一次写入.

一方面, `applyConfigurations` 生效配置需要时间, 而这个时候, 如果 `receiveConfigurations` 不通过 `output` 的方式而是直接写入, 可能会导致阻塞, 无法接收 Provider 传递的新到的动态配置消息.

另一方面, `receiveConfigurations` 到 `applyConfigurations` 传递的动态配置, 是各个 Provider 动态配置的集合. 并且是 `ConfigurationWatcher.newConfigs` 可写入时的最新集合. 那么当 `applyConfigurations` 在处理完一次的期间, 有 Provider 重复发现多个动态配置信息时, 只会使用最新的动态配置. 这种机制也让 `applyConfigurations` 一次尽可能处理多个 Provider 并且尽可能不处于已经需要被抛弃的动态配置信息.

### RingChannel

`RingChannel` 是为了在限流功能下, 每次挂起间隔达到后, 尽可能的只消费最新的消息, 丢弃旧消息.

因此, `RingChannel` 基于 in、out 读写 channel, 以及 buffer 缓存每次写入的消息.

Provider 向 in channel 写入消息后, 消息会被转移到 buffer, 而保证 in channel 可以持续消费来自 Provider 的消息.

buffer 始终能获得来自 Provider 的最新消息.

所以当 output 可写的时候, next 所指向的 buffer, 始终保持新值.
