# Telegram Deeplink

## 通过 deeplink 发送消息给指定机器人

如果目标是给某个 bot 发送一条“带参数的启动消息”，可用以下格式：

- `https://t.me/<bot_username>?start=<payload>`
- `tg://resolve?domain=<bot_username>&start=<payload>`

其中：

- `<bot_username>`：机器人用户名（不带 `@`）
- `<payload>`：会作为 `/start <payload>` 的参数传给 bot，建议先做 URL 编码

示例（给 `my_demo_bot` 发送 `/start hello_123`）：

- `https://t.me/my_demo_bot?start=hello_123`

如果参数包含空格或特殊字符，请先编码，例如：

- 原始参数：`scene=invite user=42`
- 编码后：`scene%3Dinvite%20user%3D42`
- deeplink：`https://t.me/my_demo_bot?start=scene%3Dinvite%20user%3D42`

如果你希望**不带 `/start` 指令**，可以用预填文本参数：

- `https://t.me/<bot_username>?text=<message>`
- `tg://resolve?domain=<bot_username>&text=<message>`

示例（预填 `hello bot`）：

- `https://t.me/my_demo_bot?text=hello%20bot`

注意：

- 这是 Telegram 官方支持的 bot deeplink 方式，本质是触发 `/start`（或带参数的 `/start`）。
- `?text=` 主要用于预填输入框，用户仍需手动点发送；不同客户端兼容性可能有差异。
- **不是任意文本自动发送**。首次打开 bot 通常需要用户点击 `Start` 才会发出消息。
- 如需发送任意消息内容，请走 Bot API（服务端代发）或让用户手动发送。

## References

- <https://core.telegram.org/api/links>
