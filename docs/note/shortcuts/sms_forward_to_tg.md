# iOS 自动化转发短信到Telegram群组

疑似部分机型或版本仅支持从指定的联系人进行信息的自动化处理, 比如 iOS18.7.1 下的 iPhone13 mini

需要先确认在自动化选择信息时, 允许选择任意联系人.

## 前置准备

1. 在[BotFather](https://t.me/BotFather) 创建一个机器人, 并按照提示记录下`APIToken`
2. 创建一个群组, 并将机器人添加到该群组
3. 在群组中发送一条消息
4. 根据 `APIToken`, 构造一个`getUpdates`的网页链接
5. 从网页内容`result.my_chat_member.chat.id` 找到 `chat_id`

---

- getUpadte 示例: `https://api.telegram.org/bot1111111:xxxxxxxx-xxxxxxxxxxxxx/getUpdates`
   	- 注意 `getUpadte`的格式, `https://api.telegram.org/bot{APIToken}/getUpdates`, 链接中间的 bot 不要省略
- APIToken 示例: `1111111:xxxxxxxx-xxxxxxxxxxxxx`
- chat_id 示例: `-1234567890`

## 设置场景自动化

1. Shortcuts -> Automation -> `+` -> Messages
2. `Message Contains` 选择要包含的短信内容, 比如`code`、`验证码`, 可以添加多条自动化指令
3. 选择`Run Immediately`
4. 点击`Next`, 在搜索框输入快捷指令名称, 如`短信转发到电报`

![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/27d8f082d19049aeafdac462f9b72b64.png)

## 修改快捷指令参数

短信转发到电报模板: <https://www.icloud.com/shortcuts/d29307c5c6b344ddaf92537d18a315e9>

1. 找到添加的快捷指令`短信转发到电报模板`, 进行编辑
2. 在如图所示的两个`Text`分别填入 `APIToken`和 `chat_id`

![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/748bbcc2ae334426902ff8cf7caa67b3.jpeg)
