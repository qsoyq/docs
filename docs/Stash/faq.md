# faq
  
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
