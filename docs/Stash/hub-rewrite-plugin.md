# 插件中心安装兼容 Stash

对于一些提供了非 Stash 插件的网站, 修改链接地址, 转换成 Stash 兼容的链接.

1. 安装转换覆写
2. 登录插件网站
3. 点击安装, 跳转到 Stash App 内安装覆写

## 适配网站

目前兼容网站如下:

- <https://hub.kelee.one>

## 覆写版本

### ScriptHub

通过 `scriptHub` 对插件内容进行转换

- <https://raw.githubusercontent.com/qsoyq/stash/main/override/enhance/hub-translate-plugin.stoverride>

### 自定义

通过自定义 API 实现对插件内容进行转换

- <https://raw.githubusercontent.com/qsoyq/stash/main/override/enhance/hub-translate-plugin-custom.stoverride>
