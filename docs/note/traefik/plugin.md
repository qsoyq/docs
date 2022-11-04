# Plugin

`traefik/cmd/traefik/plugins.go`

在服务启动初始化的时候, 会通过静态配置加载插件.

插件既可以是 `Provider`, 也可以是`Middleware`.

`Provider` 用于服务发现更新动态配置, `Middleware` 用于实现HTTP 中间件.

Traefik 支持通过线上的 Pilot, 一个插件市场, 安装插件.

## createPluginBuilder

使用`initPlugins` 实例化 `Builder`对象, 持有`middlewareBuilders` 和 `providerBuilders`.

后续会利用该 `Builder`对象, 去导入对应插件的源代码, 编译构建对应的插件模块.

### initPlugins

1. `checkUniquePluginNames`,  本地插件和远程插件命名不能重复.
2. 检查本地 `Pilot` 配置, 加载远程插件
3. `SetupLocalPlugins`, 加载本地插件环境
    1. 检查插件重复、命名规范
    2. `ReadManifest` 读取插件模块配置
    3. 检查插件模块字段值

## PluginBuilder

traefik 使用 `github.com/traefik/yaegi/interp` 动态导入源代码.

`NewBuilder` 实例持有`ProviderBuilder` 和 `MiddlewareBuilder`.

### ProviderPlugin

在初始化服务`setupServer`, 会遍历静态配置 `staticConfiguration.Providers.Plugin`, 通过`newProvider`实例化对应的插件.

每个插件

```go
type Provider struct {
	name string
	pp   PP
}

// PP the interface of a plugin's provider.
type PP interface {
	Init() error
	Provide(cfgChan chan<- json.Marshaler) error
	Stop() error
}
```

### MiddlewarePlugin

对于 `Middleware Plugin`, 需要对应`basePkg`的包实现 `New` 和 `CreateConfig` 方法

```go
func newMiddlewareBuilder(i *interp.Interpreter, basePkg, imp string) (*middlewareBuilder, error) {
	if basePkg == "" {
		basePkg = strings.ReplaceAll(path.Base(imp), "-", "_")
	}

	fnNew, err := i.Eval(basePkg + `.New`)
	if err != nil {
		return nil, fmt.Errorf("failed to eval New: %w", err)
	}

	fnCreateConfig, err := i.Eval(basePkg + `.CreateConfig`)
	if err != nil {
		return nil, fmt.Errorf("failed to eval CreateConfig: %w", err)
	}

	return &middlewareBuilder{
		fnNew:          fnNew,
		fnCreateConfig: fnCreateConfig,
	}, nil
}
```

## 注意事项

### 插件不能重复

静态配置`Experimental`下的 `Plugins`和 `LocalPlugins` 不能有重复的 key.

对于远程插件 `Plugins`, 插件存在冲突或下载插件失败, 都会终止插件初始化.

对于本地插件 `LocalPlugins`, 如果有重复的插件, 会跳过后出现的插件, 但是会报告相应的错误.

### LocalPlugin

本地插件要将源代码存储在 traefik 对应的目录.

本地插件模块文件路径按`{goPath}/{goPathSrc}/{moduleName}/{pluginManifest}`.

- goPath, `./plugins-local/`
- goPathSrc, `src`
- pluginManifest, `.traefik.yml`

插件模块配置必须为 yaml 格式.

每个配置文件需要按照以下字段进行反序列化.

并且每个字段值必须有效.

```go
type Manifest struct {
	DisplayName   string                 `yaml:"displayName"`
	Type          string                 `yaml:"type"`
	Import        string                 `yaml:"import"`
	BasePkg       string                 `yaml:"basePkg"`
	Compatibility string                 `yaml:"compatibility"`
	Summary       string                 `yaml:"summary"`
	TestData      map[string]interface{} `yaml:"testData"`
}
```

## 一些想法

### checkLocalPluginManifest

加载本地插件的时候, 首次反序列化配置文件后的对象, 并没有存储, 而是只对配置文件内容做基本检查.

后面实际使用的时候, 又序列化了一次, 那么在这个期间, 如果文件发生了变化, 就会出现不可预期的问题.

在测试环境中, 这种问题也是有不小的概率出现, 并且难以排查.

如果直接将对应的`Manifest`挂载在服务对象上, 也是一种办法.
