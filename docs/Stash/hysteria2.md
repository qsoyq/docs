## 一键脚本

```bash
wget git.io/tcp-wss.sh && bash tcp-wss.sh
```

## Realm 本地转发

```bash
 wget https://github.com/zhboner/realm/releases/download/v2.7.0/realm-x86_64-unknown-linux-gnu.tar.gz -O - | tar -xz -C /usr/local/bin/
```

```bash
mkdir /etc/realm
```

```bash
cat > /etc/realm/hysteria2.toml << EOF
[log]
# 日志级别: off,debug,info,error,warn 测试时可用debug, 验证ok可用改成off
level = "off"
# 日志路径，默认是stdout, 标准输出，通常不需要
# output = "/var/log/realm.log"

[network]
# 同时开启tcp和udp
no_tcp = false
use_udp = true

[[endpoints]]
listen = "0.0.0.0:7100"
remote = "127.0.0.1:7222"

[[endpoints]]
listen = "0.0.0.0:7101"
remote = "127.0.0.1:7222"

[[endpoints]]
listen = "0.0.0.0:7102"
remote = "127.0.0.1:7222"

[[endpoints]]
listen = "0.0.0.0:7103"
remote = "127.0.0.1:7222"

[[endpoints]]
listen = "0.0.0.0:7104"
remote = "127.0.0.1:7222"

[[endpoints]]
listen = "0.0.0.0:7105"
remote = "127.0.0.1:7222"

[[endpoints]]
listen = "0.0.0.0:7106"
remote = "127.0.0.1:7222"

[[endpoints]]
listen = "0.0.0.0:7107"
remote = "127.0.0.1:7222"

[[endpoints]]
listen = "0.0.0.0:7108"
remote = "127.0.0.1:7222"

[[endpoints]]
listen = "0.0.0.0:7109"
remote = "127.0.0.1:7222"

[[endpoints]]
listen = "0.0.0.0:7110"
remote = "127.0.0.1:7222"
EOF
```

```bash
mkdir /root/realm
```

```bash
nohup realm -c /etc/realm/hysteria2.toml > /root/realm/nohup.out 2>&1 &
```
