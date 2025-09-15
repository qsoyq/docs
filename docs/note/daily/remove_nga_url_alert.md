# 移除外链弹窗警告

## 背景

NGA 网页上的链接点击时会出现一个如下的警告, 打算移除这个

![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/a10002500cee4a5e9ee60cd1488c6a34.png)

## 分析

```js
<a href="https://pan.quark.cn/s/e90836d11306" class="urlincontent" target="_blank" onclick="ubbcode.showUrlAlert(event,this);commonui.cancelEvent(event);commonui.cancelBubble(event);return false" onmouseover="ubbcode.showUrlTip(event,this)" onmouseout="ubbcode.showUrlTip(event,this)"><span class="urltip" style="margin-top: -47.4609px; color: rgb(233, 180, 143); display: none;">https://pan.quark.cn/s/e90836d11306 </span>https://pan.quark.cn/s/e90836d11306</a>
```

渲染后的页面元素如上，`onclick` 属性导致弹窗

故此，有两个思路

### 移除监听

找到代码中 a 标签的点击事件监听代码，并拦截

### 覆写回调

修改点击 a 标签后执行的回调

## 解决方案

### 代码注入覆写函数

考虑使用覆写函数的方式，通过油猴脚本或者 Stash 脚本来实现代码注入

```js
function newUrlAlert(event, tag) {
    if (tag.tagName && tag.tagName.toLowerCase() === 'a') {
        if (tag.href) {
            console.log(event.button, event.metaKey)
            if (event.button === 0 && event.metaKey) {
                window.open(tag.href, '_blank');
            } else if (event.button === 0) {
                window.open(tag.href, '_blank');
            }
        }
    }
}
ubbcode.showUrlAlert = newUrlAlert;
```

## 回顾

1. 通过函数监听事件的 `event` 和 `tag` 属性来进行逻辑判断
      1. 通过`event.button`和`event.metaKey` 来判断键盘事件
      2. 通过`tag.tagName`判断当前元素对象
2. 使用`window.open` 并将第二个参数设置为`_blank`来创建新的标签页
