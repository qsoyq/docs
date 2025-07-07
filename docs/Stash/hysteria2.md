## hysteria2一键脚本

```bash
wget git.io/tcp-wss.sh && bash tcp-wss.sh
```

## Realm 本地转发

```bash
 wget https://github.com/zhboner/realm/releases/download/v2.7.0/realm-x86_64-unknown-linux-gnu.tar.gz -O - | tar -xz -C /usr/local/bin/
```

```bash
mkdir /etc/realm
mkdir /root/realm
```

### 安装Python依赖

```bash
curl https://raw.githubusercontent.com/qsoyq/shell/main/scripts/bash/pyenv-installer.sh | bash
source ~/.bash_profile
pyenv install 3.13.1 -v && pyenv global 3.13.1 && pyenv rehash
python3 -m pip install typer rich toml
```

### 通过脚本输出realm配置

```bash
# python3 <(curl -sL https://raw.githubusercontent.com/qsoyq/shell/main/scripts/python/vpn/realm.py) --help
python3 <(curl -sL https://raw.githubusercontent.com/qsoyq/shell/main/scripts/python/vpn/realm.py) --listen-port 7100-7110 --remote-port 7222 > /etc/realm/hysteria2.toml
```

### 启动 realm

```bash
nohup realm -c /etc/realm/hysteria2.toml > /root/realm/nohup.out 2>&1 &
```

### crontab 开机启动

```bash
PATH=/root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
@reboot nohup realm -c /etc/realm/hysteria2.toml > /root/realm/nohup.out 2>&1 &
```
