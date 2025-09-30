# nameserver-policy

## 使用基于 Geosite 生成的NameserverPolicy

已知 Stash 不支持在`nameserver-policy`中使用`geosite`的语法。

如果通过 `API` 动态生成对应的覆写, 以添加覆写的方式, 导入相应的`nameserver-policy`, 便可以达成该目的。

### 缺点

1. 首次导入需要添加多个对应`geosite`的覆写, 操作可能有点繁琐?
2. 更新需要手动更新; 包括启用和关闭, 如果数量比较多, 也比较繁琐?
3. 未严格测试对内存的影响, 数量比较多的情况下, 对于会比较占内存?
4. Stash 的`nameserver-policy` 应该是不支持`regexp`相关的规则.

### 优点

就是个临时解决方案, 凑合用得了

### 如何使用覆写

1. 点开在线 [API](https://p.19940731.xyz/docs#/Stash/nameserver_policy_by_geosite_api_stash_stoverride_geosite_nameserver_policy__geosite__get) 交互工具
2. 点击 `Try it out`
3. 在 `geosite` 输入框里输入, 比如`google`、`google@ads`、`google@cn`
4. 在 `dns` 输入框里输入需要的 dns 服务器, 比如`system`、`1.0.0.1`、`https://223.6.6.6/dns-query`
5. 点击`Execute`执行请求
6. 在 `Request URL` 中复制 `URL`, 然后在 Stash 里导入覆写即可
