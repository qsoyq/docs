# Sentry

## Sentry Asgi 是如何运作的

`sentry_sdk.init` 初始化设置. 主要是配置 `hub`和`dsn`.

然后导入`SentryAsgiMiddleware`中间件.

### SentryAsgiMiddleware 运作流程 调用栈

通过 `_asgi_middleware_applied` 上下文变量控制初始化逻辑.  建立连接后记录, 并当连接退出时清除.

- `auto_session_tracking`
    - `hub.start_session`
        - `hub.__enter__`
            - `hub.configure_scope`
            - `Transaction.continue_from_headers`
            - `hub.start_transaction`
                - `_capture_exception`
        - `hub.__exit__`
    - `hub.end_session`

- `_capture_exception`
    - `event_from_exception`
    - `hub.capture_event`
        - `client.capture_event`
            - `transport.capture_envelope` => `HttpTransport.capture_envelope`
                - `HttpTransport._worker.submit`
                    - `send_envelope_wrapper`
                        - `hub.__enter__`
                            - `capture_internal_exceptions`
                                - `HttpTransport._send_envelope`
                                - `HttpTransport._flush_client_reports`
                        - `hub.__exit__`

### 注意事项

- 虽然在`hub.capture_event`中仍然使用的是`urllib3`进行 HTTP 请求. 但执行这个动作是通过一个独立的线程进行的, 并不会阻塞协程事件队列.

- 线程队列满时, 待办消息会进入`_discarded_events`, 以`[[data_category, reason]: quantity`的形式记录.

- 请求次数触发限流时, 会根据响应头的`Retry-After`字段解析屏蔽时间, 默认60s

- 触发限流后的所有消息, 也会进入`_discarded_events`
