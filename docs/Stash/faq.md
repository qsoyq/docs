
## GEOSITE、GEOIP 和 no-resolve 的关系

IP 类规则, 如`GEOIP`, 是针对出站请求为 IP 地址的部分进行内容匹配

如 `https://223.5.5.5/dns-query`

```yaml
- GEOSITE,cn,DIRECT # 仅针对域名请求进行内容匹配
- GEOIP,cn,DIRECT,no-resolve # 仅针对IP 请求进行内容匹配
- GEOIP,cn,DIRECT # 仅针对IP 请求进行内容匹配, 如果请求是域名，会将域名解析为 IP 再进行内容匹配
```

## 添加远程代理集后，策略组不显示代理集里的节点

底部导航栏策略组＞左上角小云朵图标 ＞ proxies 列表 ＞ 左滑更新 ＞ 显示更新时间和数量表示成功

![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/a4c3ea84bc4b4e4599281ee56014cb7a.jpeg)
![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/b7a197f5417943419ec6c2626a81a1b8.jpeg)
![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/7ddcedc029594d8aaeb0d46d7c865b41.jpeg)
![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/ecdf0058cc884d43b18df472ab9244b2.jpeg)

## 更新远程代理集失败

尝试切换到全局模式， 指定 GLOBAL 策略走直连，重试
![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/64cc26491f6645f1b7988d30ba8ab6bb.jpeg)
![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/976d2e4565604f1993dd8ecaad1b8532.jpeg)

## 机场订阅无法导入或更新

部分机场订阅接口不支持 Stash UA, 返回了错误的格式

需要手动在订阅里添加flag参数，修改如下

`https://example.org/api/v1/client/subscribe?token=token` -> `https://example.org/api/v1/client/subscribe?token=token&flag=clash`

## 统计中订阅流量显示规则

1. 订阅的配置，手动更新，会基于 head 方法请求订阅接口更新数据
2. 配置中的远程代理集，会根据缓存结果显示，手动更新无效，更新远程资源无效，刷新机制不明
3. 覆写中填写的远程代理集，统计中不显示订阅的流量信息

部分机场不支持 head 方法的订阅请求，所以在 stash中无法刷新统计订阅流量，只显示第一次拉取配置的流量统计信息。

## DNS查询规则

1. 直连请求会触发 DNS 查询
2. 匹配规则时遇到IP-CIDR、IP-ASN、GEOIP， 且规则未添加 *no-resolve*

## 订阅转换

> 什么情况下需要使用订阅转换接口？

1. 机场不识别 Stash 客户端的 UserAgent, 需要自定义User-Agent以绕过限制
2. 机场订阅接口未允许 `Head` 请求, 于是 Stash 流量更新失败
3. 远程代理集为代理添加前缀，以方便正则过滤
4. 修改默认的延迟测速地址

### 支持功能

- 自定义User-Agent
- 兼容Head请求
- 节点名称添加前缀(仅适用于只返回代理的情况)
- 订阅只返回代理节点
- 修改节点延迟测速链接
- 修改节点延迟测速时间

### 如何操作

1. 访问接口网页: `https://p.19940731.xyz/docs#/Proxy/subscribe_api_clash_subscribe_get`
2. 点击 `Try it out`
3. 在页面输入参数，其中 `url` 必填, `user_agent` 等其他参数按需填写
4. 点击 `Execute` 执行
5. 在下方结果中复制`Request URL`内的链接
6. 导入到配置文件或远程代理集

![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/94c704d0b95f4a348c3ff9424d5093ba.png)
![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/cf8762130d2e406c91610e9b5470348c.png)
![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/35c703b598d841dbab179c210aa7ca05.png)
![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/e9b2cf623c3844f6b456f405cd584ae6.png)
