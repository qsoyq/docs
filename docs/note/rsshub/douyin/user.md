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

## 疑问

为什么个别用户返回的视频会不包含最新的?

会有好几天的延迟?

例如2025.09.05 才推送 2025.08.29 的内容?
