
## 前因

 因为 Stash Clash API 不标准(?)，yacd 的支持有限， 当使用页面上的切换后端功能时，会显示错误

## 解决办法

修改源码, 打包一个适配 stash 的版本

### 线上地址

- <http://yacd.19940731.xyz>
- <https://yacd.19940731.xyz>

### Docker部署

```bash
docker run -p 1234:80 -d --name yacd --rm qsoyq/yacd
```

## 使用注意

多数浏览器默认不允许 http/https 混用, 可能会导致后端无法切换，需要设置允许不安全内容.

### Chrome修改网站设置

1. 浏览器访问地址 hrome://settings/content/all?searchSubpage=yacd
	1. 或者直接访问地址  chrome://settings/content/siteDetails?site=https%3A%2F%2Fyacd.19940731.xyz%2F
2. 在 Permissions 中找到 Insecure content
3. 更改为 Allow,  重启浏览器即可
