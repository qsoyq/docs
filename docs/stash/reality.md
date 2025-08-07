[脚本参考](https://github.com/yeahwu/v2ray-wss)

## 以 root 用户执行

```bash
sudo su
touch ~/.bash_profile
```

## 安装Python依赖

以下二选一, 时间、磁盘空间允许, 建议 `pyenv` 方式

### Debian12 venv 虚拟环境

```bash
apt update && apt install python3-pip python3-venv -y
python3 -m venv ~/python
echo "source ~/python/bin/activate" >> ~/.bash_profile
source ~/.bash_profile
python3 -m pip install typer rich toml dateparser
```

### 基于 pyenv 安装

耗时较长, 但是兼容多系统(大概?)

```bash
curl https://raw.githubusercontent.com/qsoyq/shell/main/scripts/bash/pyenv-installer.sh | bash
source ~/.bash_profile
pyenv install 3.13.1 -v && pyenv global 3.13.1 && pyenv rehash
python3 -m pip install typer rich toml dateparser
```

## 安装 Reality

服务端配置路径: */usr/local/etc/xray/config.json*

客户端配置路径: */usr/local/etc/xray/reclient.json*

```bash
# 按提示输入参数
python3 <(curl -sL https://raw.githubusercontent.com/qsoyq/shell/main/scripts/python/vpn/reality.py)
```

### 传递参数

同时传递所有参数, 所有机器使用同一份配置, 客户端仅需要修改 ip 即可。

```bash
python3 <(curl -sL https://raw.githubusercontent.com/qsoyq/shell/main/scripts/python/vpn/reality.py) \
    --sni www.amazon.com \
    --no-sniff \
    --port 443 \
    --uuid ed305e8e-123b-4477-a66d-52c68df4e199 \
    --short-ids 88 \
    --public-key ShmdO7WIVSv0Xy8qo4N3Ach8YwG8-_prSumyWDsgg0g \
    --private-key 8C6QksOsd5DXWqpEOa3bdSaaUDnGhOC4EoljJg7uuV8 \
    --no-limit-fallback
```

## TCP优化

> 此脚本运行后会重启服务器。

```bash
wget https://raw.githubusercontent.com/yeahwu/v2ray-wss/main/tcp-window.sh && bash tcp-window.sh
```
