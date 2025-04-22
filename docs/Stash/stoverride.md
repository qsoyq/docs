# stoverride

## 覆写无效

- 尝试关闭/打开 设置＞网络设置＞仅打开 tunnel 模式
- 尝试关闭并重新打开 mitm
- 保持最新测试版
- 尝试关闭包含所有网络
- 更多设置＞其他＞删除临时文件
- 更新/重装覆写订阅

## 规则

- [自用配置文件](https://link.stash.ws/install-config/raw.githubusercontent.com/qsoyq/stash/main/config/default.yaml)

### 生效顺序

1. 覆写规则优先级大于配置文件
2. 覆写顺序决定生效顺序
3. 顺序安排
    1. pcdn拒绝
    2. AD分流屏蔽
    3. 分流屏蔽
    4. 电报分流代理
    5. talkatone分流代理
    6. 分流直连
    7. 微信分流直连

### 覆写规则

- [pcdn拒绝](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/bypass/reject.pcdn.stoverride)
- [AD分流屏蔽](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/bypass/ad.reject.stoverride)
- [分流屏蔽](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/bypass/reject.stoverride)
- [电报分流代理](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/bypass/telegram.stoverride)
- [talkatone分流代理](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/bypass/talkatone.stoverride)
- [分流直连](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/bypass/direct.stoverride)
- [微信分流直连](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/bypass/wechat.stoverride)

## 去广告

部分开屏广告会被缓存，需要删除 app 重新下载

### AdguardHome DNS

- 自建 DNS 服务器，基于 `AdguardHome`, 添加 `anti-AD` 等去广告规则
- 建议按如下操作打开 Fallback DNS
    - iOS: 设置 -> 网络设置 -> Fallback DNS
    - Mac: 控制面板 -> 设置 -> 网络 -> Fallback DNS

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/dns/adguardhome.stoverride)

### 可莉油管

- 网页端尝试刷新浏览器缓存

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/youtube.stoverride)

### 推特

- 移动端可能会导致bug不可用

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/x.stoverride)

### 起点读书

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/qidian.stoverride)

### 哔哩哔哩

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/bilibili.stoverride)

### 叮咚买菜

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/ddxq.stoverride)

### 斗鱼

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/douyu.stoverride)

### 什么值得买

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/smzdm.stoverride)

### 塔斯汀微信小程序

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/tastien.stoverride)

### 小红书

- [自用 - 点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/rednote.stoverride)
- [第三方推荐使用 - 点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/rednote_v2.stoverride)

### 便利蜂

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/bilbee.stoverride)

### Reddit

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/reddit.stoverride)

### 淘宝

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/taobao.stoverride)

### 大众点评

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/dianping.stoverride)

### 微博国际版

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/weibo.intl.stoverride)

### 美团外卖

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/waimai.meituan.stoverride)

### 盒马

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/freshippo.stoverride)

### 肯德基

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/kfc.stoverride)

### 麦当劳

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/mcd.stoverride)

### 谷歌搜索

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/search.google.stoverride)

### 下载狗

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/xiazaitool.stoverride)

### 腾讯医典

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/baike.qq.stoverride)

### 小黑盒

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/xiaoheihe.stoverride)

### 雷神加速器

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/leigod.stoverride)

### 七猫小说

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/qimao.stoverride)

### 饿了么

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/eleme.stoverride)

### 禁漫天堂

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/18comic.stoverride)

### Instagram

- 网页端去广告, 移动端不兼容

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/instagram.stoverride)

### 高德地图

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/amap.stoverride)

### 京东

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/jd.stoverride)

### 中国移动

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/ad/cmcc.stoverride)

## 增强

### 91Porn

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/enhance/91porn.stoverride)

### 美团域名重定向

- [美团外卖AppDebug域名分流BUG的问题](https://www.blueskyxn.com/202311/6919.html)

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/enhance/meituan.domain.redirect.stoverride)

### Apple 系统定位

- 飞行模式下，启动地图应用刷新系统定位

- [点击安装 - US](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/enhance/apple.location.us.stoverride)
- [点击安装 - UK](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/enhance/apple.location.uk.stoverride)

### 谷歌搜索重定向

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/enhance/redirect.google.stoverride)

### 阿里云 OSS 图床在线预览

- 仅对阿里云默认域名生效， 如 `example.oss-cn-shanghai.aliyuncs.com`

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/enhance/inline.oss.aliyun.stoverride)

### AiHubMix 重定向

- 通过透明代理的方式重定向 OpenAI API 到 AiHubMix.

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/enhance/aihubmix.stoverride)

### NGA 收藏帖优化

- 移除收藏列表中已过期或权限不足的帖子

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/enhance/favor.nga.stoverride)

### 微博页面访问跳转

- 访问网页版微博时，发送通知, 点击通知跳转到微博国际版

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/enhance/weibo.intl.stoverride)

## 签到

### 塔斯汀

- 需要手动在塔斯汀小程序上进行一次签到获取请求信息
- 签到会根据活动周期失效，失效后需要重新在小程序上执行签到

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/sign/tastien.stoverride)

## 磁贴

### 解锁检测

- 哔哩哔哩港澳台
- chatgpt iOS
- chatgpt web
- gemini
- youtube premium

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/tile/media-unlock-checker.stoverride)

### 网络信息 X

- [折腾啥](https://t.me/zhetengsha)

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/tile/x.network.stoverride)

### 货币汇率

- 覆写来源: <https://whatshub.top/stoverride/rates.stoverride>
- 脚本来源: <https://raw.githubusercontent.com/deezertidal/Surge_Module/master/files/rates.js>
- 数据源API: <https://api.exchangerate-api.com/v4/latest/CNY>

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/tile/currency-exchange-rate.stoverride)

## 调试

### 禁用 QUIC

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/debug/reject.quic.stoverride)

### HTTP抓包

- 会导致部分网络无法访问
- 会导致app store无法打开

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/debug/http-capture.stoverride)

### Github 文件资源优化

- 修改 github 仓库文件资源的文件类型

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/debug/media.github.stoverride)

### iRingo 资源在线预览

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/debug/inline.nsringo.stoverride)

### 可莉资源浏览器访问

- 绕过浏览器访问 WAF 拦截

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/debug/kelee.stoverride)

### 小红书图床浏览器预览

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/debug/cdn.rednote.stoverride)

### 禁用fakeip

[点击安装](https://link.stash.ws/install-override/raw.githubusercontent.com/qsoyq/stash/main/override/debug/fakeip.disable.stoverride)
