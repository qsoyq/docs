# zimaboard

## 软路由

网卡混杂模式启动

```shell
ip link set enp3s0 promisc on
```

创建 docker 网络

```shell
docker network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=enp3s0 macnet
```

修改 openwrt 网络配置

```shell
cat > /etc/openwrt/network <<EOF
config interface 'loopback'
        option ifname 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'

config globals 'globals'
        option packet_steering '1'

config interface 'lan'
        option type 'bridge'
        option ifname 'enp3s0'
        option proto 'static'
        option ipaddr '192.168.1.77'
        option netmask '255.255.255.0'
        option ip6assign '60'
        option gateway '192.168.1.1'
        option broadcast '192.168.1.255'
        option dns '192.168.1.1'

config interface 'vpn0'
        option ifname 'tun0'
        option proto 'none'
EOF
```

启动容器

```shell
docker run --restart always -d  --ip 192.168.1.77 --name openwrt -v /etc/openwrt/network:/etc/config/network --network macnet --privileged registry.cn-shanghai.aliyuncs.com/suling/openwrt:x86_64 /sbin/init
```

添加 macvlan 子网访问容器

```shell
ip link add mynet link enp3s0 type macvlan mode bridge
ip addr add 192.168.1.63 dev mynet
ip link set mynet up
ip route add 192.168.1.79 dev mynet
```

创建自启动脚本

```shell
cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# 设置网卡混杂模式
ip link set enp3s0 promisc on

# 添加 macvlan 网卡和路由 在宿主机直接访问 openwrt
ip link add mynet link enp3s0 type macvlan mode bridge
ip addr add 192.168.1.63 dev mynet
ip link set mynet up
ip route add 192.168.1.79 dev mynet

exit 0
EOF
```

赋予可执行权限

```shell
chmod +x /etc/rc.local
```

启动服务

```shell
systemctl enable --now rc-local
```

参考文档

[openwrt-docker](https://github.com/SuLingGG/OpenWrt-Docker)

[在Docker 中运行 OpenWrt 旁路网关](https://mlapp.cn/376.html)

[在Docker 中运行 OpenWrt 旁路网关 - issues](https://github.com/SuLingGG/blog-comments/issues/2)

[N1安装docker版本的openwrt做旁路由](https://www.mrdoc.fun/doc/140/)

[Debian 11 Bullseye 解决 /etc/rc.local 开机启动问题](https://u.sb/debian-rc-local/)
