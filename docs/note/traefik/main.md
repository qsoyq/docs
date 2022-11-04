# 程序启动逻辑

`traefik/cmd/traefik/traefik:main` 是整个程序的入口.

traefik 会从文件配置、命令行参数、环境变量读取相应的配置， 写到 `TraefikCmdConfiguration` 对象内

## 启动流程

01. 实例化`Command`命令行解析对象, 绑定 `TraefikCmdConfiguration` 对象作为静态配置
02. 实例化`FileLoader`, `FlagLoader`, `EnvLoader`解析文件、命令行参数、环境变量 填充静态配置
03. 实例化`healthcheck`子命令
04. 实例化`cmdVersion`子命令
05. Execute 执行当前命令
    01. 启动 traefik 主命令
        01. 遍历 resource 对象, 执行对应的 load 方法, 初始化配置
            01. FileLoader
            02. FlagLoader
            03. EnvLoader
    02. healthcheck 子命令
    03. cmdVersion 子命令
    04. Resources Load
        01. File Load
        02. Flag Load
        03. Env Load
    05. cmd run

## FileLoader

01. 尝试从命令行参数解析配置文件
    01. 命令行参数解析语法按 `--name value`, `--name=value` 的格式解析 `name:value` 键值对

02. `loadConfigFiles` 尝试寻找配置文件
    01. 遍历预设的文件路径, 查找文件路径
        01. 对路径名进行环境变量展开
        02. 若读取文件信息失败
            01. 文件不存在, 跳过
            02. 其他错误, 向上传递
        03. 读取文件信息成功后, 返回文件绝对路径

03. 找到配置文件路径后, 读取文件并填充静态配置

## FlagLoader

## EnvLoader

## Cmd run

01. 通过 `configureLogging` 初始化日志对象
    01. 设置日志级别
    02. 设置日志格式
        01. 仅当静态配置中的`Format`为`json`时, 使用`json`formatter, 否则使用`text` formatter
    03. 设置日志落盘
        01. 尝试创建目录, 若路径已存在文件, 则向上返回错误. 若路径已存在目录, 则直接结束创建
        02. 目录创建成功后, 打开文件, 并为`logrus`绑定`Out`对象
        03. 打开文件成功后, 为 `logrus` 绑定退出回调. 在退出回调中, 关闭对应文件.
02. 设置 `net/http`内置库的 `DefaultTransport` 代理使用 `ProxyFromEnvironment` 从环境变量读取.
03. 初始化 `roundrobin` 的权重
04. `SetEffectiveConfiguration` 补全静态配置参数
    01. 添加默认 `EntryPoint`, 仅当配置文件未指定任何 `EntryPoint` 时, 会添加一个名为 `http` 监听 `80` 端口的默认 `EntryPoint`
    02. 检查配置参数, 当 API、Ping、Metrics 等内部服务有被使用的情况下, 添加一个名为`traefik`, 监听 `8080` 端口的 `EntryPoint`
05. `ValidateConfiguration` 校验
    01. 启用了 `ACME` 的 `Resolver` 的 `Storage` 必须有值
    02. 所有 `ACME Resolver` 的 `acmeEmail` 字段值必须相同
06. 版本检查
    01. 首次启动延迟 10 分钟后检查 github 上的版本信息
    02. 第二次检查发生在程序启动后的 24 小时, 之后每次检查间隔 24 小时
    03. 版本检查检索到最新版本后, 只输出, 不做更新操作
    04. 版本检查仅在静态配置设置了 `Global.CheckNewVersion` 后启动
    05. 当程序版本属于`Dev`时, 执行版本检查的操作时直接跳过, 而不是请求 github
07. 统计收集
    01. 仅当启用了 `Global.SendAnonymousUsage` 后, 才会开启统计收集
    02. 统计间隔同样按首次 10 分钟, 第二次 23h-10m, 第三次往后 24h.

08. 服务器设置
    01. Add Provider Aggregator
        01. File、Docker、Rest、Http、Redis 等动态配置 Provider
    02. Add internal provider
    03. Add ACME Provider
        01. Make Tls Manager
        02. Add httpChallengeProvider
        03. Add tlsChallengeProvider
    04. Add Entrypoints
        01. Add Tcp Entry Points
        02. Add Udp Entry Points
    05. Add Pilot
    06. Create Plugin Builder
    07. Providers plugins
    08. Add Metrics
        01. Register Prometheus
        02. Register Datadog
        03. Register Statsd
        04. Register InfluxDB
        05. Register InfluxDB2
    09. Add Service Manager Factory
        01. Metrics Registry
        02. Round Tripper Manager
        03. Acme HTTP Handler
    10. Add Router Factory
        01. Setup Access Log
        02. Make Chain Builder
        03. Add Plugin Builder
        04. Add Tls Manager
    11. Add Listening
        01. Add Tls Listening
        02. Add Metrics Listening
        03. Add Server Transports
        04. Add Switch Router Listening
        05. Add Tls Challenge Listening
        06. Add Certificate Resolver Logs Listening
    12. 实例化 Server 对象
        01. Configure Signals `syscall.SIGUSR1`

    13. `signal.NotifyContext`初始化信号监听上下文
        1. 监听信号达到后触发退出
            1. 关闭 `Ping` 服务
            2. 关闭 traefik 服务
                1. `tcpEntryPoints->Stop`
                2. `udpEntryPoints->Stop`
                3. `stopChan <- true`
    14. traefik 服务启动
        1. `tcpEntryPoints->Start`
        2. `udpEntryPoints->Start`
        3. `watcher->Start`
        4. `listenSignals` 监听信号
            1. 监听 `SIGUSR1` 信号
                1. Closing and re-opening log files for rotation
    15. 守护进程设置
        1. `SdNotify` 初始化 Daemon
        2. `SdWatchdogEnabled` 启动 Watchdog
        3. `healthcheck.Do`
    16. `<-stopChan` 等待 traeifk 服务退出清理完成

## 注意事项

### 初始化配置规则

按照文件、命令行参数、环境变量的优先级规则读取配置， 且当读到配置并写入静态配置后, 就不会再读取下一个配置规则.

即三种配置规则, 最多只生效一种.

> loadConfigFiles内 Finder 对配置文件查找路径优先级规则

根据 `BasePaths` 和 `Extensions` , 按顺序进行查找.

目录优先级按照 `/etc/traefik/traefik` , `$XDG_CONFIG_HOME/traefik` , `$HOME/.config/traefik` , `./traefik` 从高到低.

文件格式优先级按照 `toml` , `yaml` , `yml` 从高到低.

如果命令行参数存在 `configPath` , 则优先查找该文件.

```go
finder := cli.Finder{
    BasePaths:  []string{"/etc/traefik/traefik", "$XDG_CONFIG_HOME/traefik", "$HOME/.config/traefik", "./traefik"},
    Extensions: []string{"toml", "yaml", "yml"},
}

func (f Finder) getPaths(configFile string) []string {
 var paths []string
 if strings.TrimSpace(configFile) != "" {
  paths = append(paths, configFile)
 }

 for _, basePath := range f.BasePaths {
  for _, ext := range f.Extensions {
   paths = append(paths, basePath+"."+ext)
  }
 }

 return paths
}
```

### 日志初始化

01. 当初始化日志遇到错误时, 仅终止到当前, 已完成初始化的部分不会移除, 未完成初始化的部分直接忽略
02. 当指定日志落盘时, 文本格式下, 彩色日志不起效.

### 默认配置参数补全

01. 当存在 `Docker Provider` 时, 长轮询请求的间隔为 `SwarmModeRefreshSeconds` 默认为 15 秒.
02. 所有超时相关的 `Duration` 为负数时, 设置为 0.
03. 当存在 `Rancher Provider`时, 长轮询请求的间隔为 `RefreshSeconds` 默认为 15 秒.
04. 仅当静态配置启用了 `pilot` 且配置了`Token`的情况下,  `SendAnonymousUsage` 默认开启.
05. 当静态配置未打开 `Experimental` 开关时, 关闭 `KubernetesGateway` 和 `HTTP3` 功能
06. 当成功启用`KubernetesGateway` 功能后, 将静态配置绑定的`EntryPoints`复制到`KubernetesGateway.EntryPoints`
07. 为`ACME Provider`分配合适的`CAServer`
    01. 未指定 CAServer 时, 默认值为`https://acme-v02.api.letsencrypt.org/directory`
    02. `https://acme-v01.api.letsencrypt.org` 替换成 `https://acme-v02.api.letsencrypt.org`
    03. `https://acme-staging.api.letsencrypt.org` 替换成 `https://acme-staging-v02.api.letsencrypt.org`

### 匿名统计

匿名统计除了包括版本信息等, 还包括了静态配置. 考虑到静态配置会比较敏感, 线上部署时尽量不要开启.

## 一些想法

### Command. Configuration 对象的类型声明

```go
type Command struct {
 Name           string
 Description    string
 Configuration  interface{}
 Resources      []ResourceLoader
 Run            func([]string) error
 CustomHelpFunc func(io.Writer, *Command) error
 Hidden         bool
 // AllowArg if not set, disallows any argument that is not a known command or a sub-command.
 AllowArg    bool
 subCommands []*Command
}
```

目前看下来, Command. Configuration 主要是存储静态配置.

在实例化的时候, 绑定的是 `TraefikCmdConfiguration` 对象.

在 loader_file 的相关函数内, 都已 interface{} 作为函数签名. 在实现上, 也更为复杂.

目前没想到这么声明的好处在哪里, 如果直接按 `TraefikCmdConfiguration` 声明, 实现会更容易, 可读性也会好上许多.

### 文件解析策略

```shell
// Decode decodes the given configuration file into the given element.
// The operation goes through three stages roughly summarized as:
// file contents -> tree of untyped nodes
// untyped nodes -> nodes augmented with metadata such as kind (inferred from element)
// "typed" nodes -> typed element.
```

在读取文件配置解析后写入静态配置时, 这个处理策略特别复杂.

比较困惑的一点还是为什么不声明明确的类型, 直接通过模型对象, 使用已有的解析工具来处理.

### 异常处理

```go
// Go starts a recoverable goroutine.
func Go(goroutine func()) {
 GoWithRecover(goroutine, defaultRecoverGoroutine)
}

// GoWithRecover starts a recoverable goroutine using given customRecover() function.
func GoWithRecover(goroutine func(), customRecover func(err interface{})) {
 go func() {
  defer func() {
   if err := recover(); err != nil {
    customRecover(err)
   }
  }()
  goroutine()
 }()
}

func defaultRecoverGoroutine(err interface{}) {
 logger := log.WithoutContext()
 logger.Errorf("Error in Go routine: %s", err)
 logger.Errorf("Stack: %s", debug.Stack())
}
```

捕获并输出后台运行的 `goroutine` 错误信息.

### 基于信号的退出机制

```go
 ctx, _ := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)

if staticConfiguration.Ping != nil {
    staticConfiguration.Ping.WithContext(ctx)
}
```

```go
func (h *Handler) WithContext(ctx context.Context) {
 go func() {
  <-ctx.Done()
  h.terminating = true
 }()
```

用 NotifyContext 中监听的信号来触发退出清理, 也是一种比较简明的方案.
