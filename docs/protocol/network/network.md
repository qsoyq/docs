# network

[协议森林](https://www.cnblogs.com/vamei/archive/2012/12/05/2802811.html)

## 网络分层

- 物理层, 传输物理信号
- 连接层, 在局域网内计算机之间进行通信
- 网络层, 在不同局域网的计算机之间进行同行
- 传输层, 在不同的计算机进程之间进行通信
- 应用层, 规定了通信内容的格式

这些概念最终允许互联网上的分布于两台计算机的两个进程相互通信。

## 连接层

以太网协议将帧分为三部分, 分别是头部、数据、尾部.

头部记录了源主机和目标主机的 MAC 地址. 数据部分不关心具体内容. 尾部记录了校验和, 用 CRC 算法校验数据在传输过程中是否有错误.

以太网通过集线器或交换机传输信号帧.

集线器通过广播机制转发帧数据.

交换机记录设备的 MAC地址, 根据帧数据中目标主机的 MAC 地址进行转发.

## 网络层

### IP

IP 协议将IP 数据包分为头部和数据两部分.

头部主要包含源主机和目标主机的 IP 地址以及其他的标识字段.

IP 只负责传输, 并不保证数据的可靠性.

并且在 IPv6 中去除了 header checksum, 交由上层协议来处理.

通过 ip 类别和子网掩码, 将 ip 地址分为网络号和主机号.

主机和路由器通过路由表将 ip 包转发到指定的网关地址.

```shell
# linux 下查看路由表
route -n

# macos 下查看路由表
netstat -rn
```

### ARP

ARP 协议介于连接层和网络层.

ARP协议通过 ARP 包进行广播, 以维护 ARP 表.

ARP 包携带了源主机的 IP 地址和 MAC 地址.

ARP 表记录了局域网内 IP 地址和 MAC 地址的映射关系.

ARP协议只用于IPv4.

```shell
# linux 下查看 ARP 表
arp

# macos 下查看 ARP 表
arp -a
```

基于 RIP 协议生成路由表, 记录源主机到目的主机需要经过的节点数量.

BGP的基本工作过程与RIP类似，但在考虑距离的同时，也权衡比如政策、连接性能等其他因素，再决定交通的走向(routing table)。

### ICMP

icmp 协议基于 IP 协议, 将 ICMP 包作为 IP 包的 payload 部分.

ICMP包分为 type、code、checksum、数据 四个部分.

其中, Type 为包的大的类型, code 为大类型下的细分类型.

ping 命令就是由源主机发出 type 为 8 的 Echo 数据包, 并根据目的主机返回的 type 为 0 的 Echo Reply数据包, 计算 RTT.

常见类型

- Echo
- source quench
- Destination Unreachable
- Time Exceeded
- redirect

### Neighbor Discovery

ipv6 使用基于 ICMP 协议的 ND 协议来实现类似 IPV4 中的 ARP 协议功能.

## 传输层

### UDP

![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/8dbf903fa7eb413c91e326e3fad7951b.png)

UDP 包分为头部和数据两部分.

头部记录了源主机的端口和目的主机的端口, 加上 IP 包头部的源主机地址和目的主机地址, 就能定位网络中两台主机中的进程.

UDP 可以认为是IP协议暴露在传输层的一个接口.

### TCP

TCP 是一种面向连接的、可靠的、基于字节流的传输层通信协议.

TCP 按segment, 将一段字节流拆分成多个包封装到 IP包内进行传输.

每个 TCP 包同样分为头部和数据两部分. 头部中携带序号, 以标识 TCP 包在整个字节流中的顺序.

接收方通过回复 ACK 包告知发送方的传输状况, 以保证数据的可靠性.

发送方也会在一定时间内没有收到 ACK 包后, 重传对应序列的分片.

TCP 通过滑动窗口, 并发发送多个分片.

仅当最小序号的分片得到确认后, 窗口才会移动, 发送新的分片, 直到结束.

![](https://qsoyq-public.oss-cn-shanghai.aliyuncs.com/pic/obsidian/v1/895c23db387a4afa8488f9dcd8616e35.png)
