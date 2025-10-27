# iOS Safari 跳转 App 的几种机制

## Smart App Banner

网页存在一个`name`为`apple-itunes-app`的`meta`标签

通过 mitm 移除对应标签即可阻止

实际例子`https://ssapi.com`

## Universal Links Banner

应用安装时，系统会请求 AASA 文件, 在访问对应网站时，显示 Banner

AASA 文件示例 `https://app-site-association.cdn-apple.com/a/v1/bilibili.com`

mitm `app-site-association.cdn-apple.com` 后重新安装应用, 即可导致该机制失效

实际例子`https://bilibili.com`

## URLScheme

iOS 系统接收到类似 `zhihu://` 格式的网页请求，就会唤醒注册的 App。

如果系统没有相应注册的事件，macOS 上会在控制台打印一条警告，而 iOS Safari 会弹出一条系统级别的页面无效的弹窗。

从用户体验考虑，应该让用户在网页上点击某个元素后再跳转 URLScheme。

但是`臭名昭著`的知乎会在页面加载后即刻执行 URLScheme 重定向，导致未安装 App 的 iOS 设备通过 Safari 访问时每次刷新都会有弹窗，体验极其糟糕。

URLScheme 跳转 App 时会弹出确认按钮，从体验上不如`Universal Links`
