# RSSHub 是如何返回抖音用户订阅的

## 使用无头浏览器获取目标用户的数据

目标网页: <https://www.douyin.com/user/{uid}>

使用`puppeteer`浏览器进行进行交互

当浏览器执行网页脚本后，会请求`/web/aweme/post` 路径, 获取此接口返回的 `JSON`

页面的请求会在等待条件`networkidle2`下结束。

流程结束后，若是未获取到`/web/aweme/post`的结果，则视为被 `WAF` 拦截

## 内容解析

```ts
const userInfo = pageData.aweme_list[0].author;
const userNickName = userInfo.nickname;
const userAvatar = getOriginAvatar(userInfo.avatar_thumb.url_list.at(-1));

let videoList = post.video?.bit_rate?.map((item) => resolveUrl(item.play_addr.url_list.at(-1)));
let duration = post.video?.duration;
let img
img =
    img ||
    post.video?.cover?.url_list.at(-1) || // HD
    post.video?.origin_cover?.url_list.at(-1); // LD

const desc = post.desc?.replaceAll('\n', '<br>');    

return {
    title: post.desc.split('\n')[0],
    description,
    link: `https://www.douyin.com/video/${post.aweme_id}`,
    pubDate: parseDate(post.create_time * 1000),
    category: post.video_tag.map((t) => t.tag_name),
};
```

## 注意事项

### 登录与未登录的区别

经测试，未登录用户无法观看到最新的作品，大概有 6-7 的天延迟

如果传递登录用户的 `cookie`, 可以解决这个问题。

一开始的想法是直接通过代理 Mitm 目标请求传递 `Cookie`, 后来发现会导致请求失败。

未找到在 RSSHub 里如何传递 `cookie` 参数, 于是打算自己实现一个 API 来处理
