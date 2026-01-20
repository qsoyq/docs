# 飞书单聊应用机器人

## 飞书机器人相关介绍

### 机器人类型

- 飞书应用机器人支持和用户进行消息交互
- 飞书自定义机器人仅支持单向往群组内推送消息
- 飞书自定义机器人就是通过Webhook往群组内推送消息, 场景单一, 集成方便, 适合监控推送类场景.

### 应用可见范围

[配置应用可见范围](https://open.feishu.cn/document/develop-process/test-and-release-app/availability)

- 授权可以访问机器人应用的部门或成员
- 修改应用可见范围需要在版本管理与发布中创建一个新版本

### 机器人添加步骤

1. 在[开发者后台](https://open.feishu.cn/app?lang=zh-CN)创建应用, 并开启机器人能力

### 单聊机器人权限开通

权限管理入口: [飞书开放平台](https://open.feishu.cn/app?lang=zh-CN) -> 选择目标应用 -> 左侧权限管理 -> 开通权限

需要开通以下三个权限

- im:message
- im:message.p2p_msg:readonly
- im:message:send_as_bot

## API

### 机器人主动向会话发送消息

1. [发送消息](https://open.feishu.cn/document/server-docs/im-v1/message/create)

需要注意, `receive_id_type` 需要根据实际情况.

在单聊机器人中, 推荐使用`open_id`.

`open_id`的值可以在接收消息的监听事件`data.event.sender.sender_id.open_id` 中获得.

```python
def push_text_message(
    appid: str = typer.Option(..., help="飞书应用ID", envvar="FEISHU_APP_ID"),
    appsecret: str = typer.Option(..., help="飞书应用密钥", envvar="FEISHU_APP_SECRET"),
    log_level: int = typer.Option(logging.DEBUG, help="日志级别", envvar="FEISHU_LOG_LEVEL"),
    receive_id_type: Literal["open_id", "union_id", "user_id", "email", "chat_id"] = typer.Option("open_id", help="和 receive_id 一起使用"),
    receive_id: str = typer.Option(..., help="和 receive_id_type 一起使用"),
    msg_type: Literal["text", "post", "image", "file", "audio", "media", "sticker", "interactive", "share_chat", "share_user", "system"] = typer.Option("text", help="和 content 一起使用"),
    content: str = typer.Argument(..., help="推送文本消息"),
):
    """
    飞书推送文本消息.

    https://open.feishu.cn/document/server-docs/im-v1/message/create
    """
    logging.basicConfig(level=log_level)
    typer.echo(helptext)
    client = init_client(appid, appsecret)
    if client.im is None:
        raise Exception("client.im is None")
    if client.im.v1 is None:
        raise Exception("client.im.v1 is None")
    request: CreateMessageRequest = (
        CreateMessageRequest.builder()
        .receive_id_type(receive_id_type)
        .request_body(CreateMessageRequestBody.builder().receive_id(receive_id).msg_type(msg_type).content(json.dumps({"text": content})).build())
        .build()
    )

    # 发起请求
    response: CreateMessageResponse = client.im.v1.message.create(request)
)
```

### 机器人接收用户消息并回复

1. [接收消息](https://open.feishu.cn/document/server-docs/im-v1/message/events/receive)
2. [回复消息](https://open.feishu.cn/document/server-docs/im-v1/message/reply)

#### 示例代码

##### 客户端实例化

存在两个实例化的客户端, 一个是`wsClient`, 负责维护 WebSocket 长连接, 一个`client`, 负责调用飞书 OpenAPI

```python
def init_ws_client(appid: str, appsecret: str) -> lark.ws.Client:
    global client
    event_handler = lark.EventDispatcherHandler.builder("", "").register_p2_im_message_receive_v1(do_p2_im_message_receive_v1).build()

    client = lark.Client.builder().app_id(appid).app_secret(appsecret).build()
    wsClient = lark.ws.Client(
        appid,
        appsecret,
        event_handler=event_handler,
        log_level=lark.LogLevel.DEBUG,
    )
    return wsClient
```

##### 注册监听事件

```python
# https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/reference/im-v1/message/events/receive
# https://open.feishu.cn/document/uAjLw4CM/ukTMukTMukTM/reference/im-v1/message/create
def do_p2_im_message_receive_v1(data: P2ImMessageReceiveV1) -> None:
    global client
    if client is None:
        raise Exception("client is None")
    if client.im is None:
        raise Exception("client.im is None")
    res_content = ""
    if data.event is None or data.event.message is None or data.event.sender is None or data.event.sender.sender_id is None or data.event.sender.sender_id.open_id is None:
        typer.echo("解析消息失败, 请发送文本消息")
        raise Exception("解析消息失败, 请发送文本消息")
    if data.event.message.message_type == "text" and data.event.message.content is not None:
        text = json.loads(data.event.message.content)["text"]
        res_content = (
            f"{text}\nchat_type: {data.event.message.chat_type}\nchat_id: {data.event.message.chat_id}"
            f"\nmessage_type: {data.event.message.message_type}\nmessage_id: {data.event.message.message_id}"
            f"\nsender_openid: {data.event.sender.sender_id.open_id}\nsender_type: {data.event.sender.sender_type}"
        )
        typer.echo(f"res_content: {res_content}")
    else:
        res_content = "解析消息失败, 请发送文本消息"

    content = json.dumps({"text": "收到你发送的消息:" + res_content})
    if data.event.message.chat_type == "p2p":
        receive_id = data.event.message.chat_id
        if receive_id is None:
            raise Exception("receive_id is None")
        p2p_request: CreateMessageRequest = (
            CreateMessageRequest.builder().receive_id_type("chat_id").request_body(CreateMessageRequestBody.builder().receive_id(receive_id).msg_type("text").content(content).build()).build()
        )

        response: CreateMessageResponse = client.im.v1.message.create(p2p_request)

        if not response.success():
            raise Exception(f"client.im.v1.message.create failed, code: {response.code}, msg: {response.msg}, log_id: {response.get_log_id()}")
    else:
        msg_id = data.event.message.message_id
        if msg_id is None:
            raise Exception("msg_id is None")
        other_request: ReplyMessageRequest = ReplyMessageRequest.builder().message_id(msg_id).request_body(ReplyMessageRequestBody.builder().content(content).msg_type("text").build()).build()
        reply_response: ReplyMessageResponse = client.im.v1.message.reply(other_request)
        if not reply_response.success():
            raise Exception(f"client.im.v1.message.reply failed, code: {reply_response.code}, msg: {reply_response.msg}, log_id: {reply_response.get_log_id()}")
```

##### 启动客户端

```pytyhon
wsClient = init_ws_client(appid, appsecret)
wsClient.start()
```

#### WebSocket VS Webhook

飞书机器人应用允许以WebSecket 长连接或 Webhook 事件推送的方式接收用户消息.

WebSocket 模式免去了公网端口依赖, 便于开发调试和部署.

##### WebSocket

- [使用长连接接收事件](https://open.feishu.cn/document/server-docs/event-subscription-guide/event-subscription-configure-/request-url-configuration-case)
- [将事件发送至开发者服务器](https://open.feishu.cn/document/event-subscription-guide/event-subscriptions/event-subscription-configure-/choose-a-subscription-mode/send-notifications-to-developers-server)

- WebSocket 模式需要应用能访问外网
- WebSocket 模式支持部署至多 50 个连接实例.
- WebSocket 模式要求客户端在 3 秒内响应, 否则会触发超时重推

##### Webhook

- Webhook 需要应用有暴露在公网的地址, 并配置在飞书开发者后台
- Webhook模式需要应用在 1 秒内回复请求中携带的`challenge`参数

## 相关链接

- [机器人菜单](https://open.feishu.cn/document/client-docs/bot-v3/bot-customized-menu)
- [三分钟快速开发](https://open.feishu.cn/document/develop-an-echo-bot/introduction)
