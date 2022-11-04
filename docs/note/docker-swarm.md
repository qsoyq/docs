记录下 `docker swarm` 的使用体验


### install docker-machine

linux 下安装
```shell
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
chmod +x /usr/local/bin/docker-machine
```

### install virtualbox

```shell
sudo dnf config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo \
&& sudo yum install VirtualBox-6.0
```

### create swarm manager

安装前确保 docker 后台进程已启动, 否则会卡在`Waiting for an IP...`

```shell
docker-machine create  -d virtualbox swarm-manager
```

上面的命令如果失败, 可以尝试下面这条
```shell
docker-machine create --virtualbox-no-vtx-check -d virtualbox swarm-manager
```
阿里云机器默认的 yum 配置无法解析阿里云源的域名, 安装依赖失败.

腾讯云机器在执行 ssh 命令的时候异常, 卡在`waiting for an IP`.

下次继续尝试.
