# Server

位于 `traefik/pkg/server/server.go` 的 Server Struct 是traefik 服务的抽象.

在服务启动的过程中, 实际上就是启动了 Server 结构体中的 `tcpEntryPoints` , `udpEntryPoints` , `watcher` .

主线程监听 `Server.stopChan` , 当后台协程监听到表示退出的信号, 完成清理后, 写入 stopChan, 表示退出清理完成, 主线程即结束.

`Deamon` 服务监听 `Server.signals` , 对应的信号到达后, 执行日志文件切割等逻辑重新打开日志.

`routinesPool` 维护了所有后台运行中的协程, 当执行退出清理时, 会保证协程池内的任务全部结束后退出.

1. 监听 context 以启动停止流程
    1. tcpEntryPoints 停止
    2. udpEntryPoints 停止
    3. stopChan 写入, 停止完成

2. 启动 tcpEntryPoints
3. 启动 udpEntryPoints
4. 启动 watcher
5. 监听`SIGUSR1`信号以重置日志
