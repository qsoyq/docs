# RSS服务一览

## 简单说明

实现了一些数据源的 RSS API.

部分实现基于[JSONFeed V1](https://www.jsonfeed.org/version/1/).

`ReDoc` 文档适合浏览接口信息.

`SwaggerUI` 适合在线请求调试

- [接口文档 - ReDoc](https://p.19940731.xyz/redoc#tag/RSS)
- [在线调试 - SwaggerUI](https://p.19940731.xyz/docs#/RSS)

### 自行部署

- github: <https://github.com/qsoyq/proxy-tool>

## API 列表

### NNR转发

<https://nnr.moe>

- 流量订阅
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/traffic_used_by_day_jsonfeed_api_rss_nnr_traffic_used_day__ssid___get)
  
### 1024.day

<https://1024.day/>

- 新鲜出炉, 按发布时间从新到旧
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/jsonfeed_api_rss_1024_day_newest_get)

### Nodeseek

<https://www.nodeseek.com/>

- 获取分区订阅, <https://p.19940731.xyz/api/rss/nodeseek/category/life>, 部分部署节点可能会被 Nodeseek 设置的 Cloudflare WAF 拒绝访问.
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/newest_jsonfeed_api_rss_nodeseek_category__category__get)

### V2ex

- V2ex 节点 RSS 订阅聚合
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/aggregation_api_rss_jsonfeed_v2ex_aggregation_get)
- V2ex 收藏帖回复 RSS 订阅
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/favorite_api_rss_jsonfeed_v2ex_favorite_get)

### NGA

<https://bbs.nga.cn>

- NGA 收藏贴回复 RSS 订阅
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/favorite_jsonfeed_api_rss_nga_favor__favorid__get)
- NGA 分区新贴 RSS 订阅
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/threads_jsonfeed_api_rss_nga_threads_get)

### GoFans

<https://gofans.cn/>

- GoFans App Store iOS 限免RSS订阅
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/ios_jsonfeed_api_rss_gofans_iOS_get)
- GoFans App Store macOS 限免RSS订阅
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/macOS_jsonfeed_api_rss_gofans_macOS_get)

### Loon

- Loon插件更新RSS订阅
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/ipx_jsonfeed_api_rss_loon_ipx_get)

### Telegram

- Telegram Channel RSS Subscribe
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/channel_jsonfeed_api_rss_telegram_channel_get)

### Github

- Github Repo Releases RSS
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/releases_list_api_rss_github_releases_repos__owner___repo__get)
- Github Repo Commits RSS
    - [ReDoc](https://p.19940731.xyz/redoc#tag/RSS/operation/commits_list_api_rss_github_commits_repos__owner___repo__get)
