[脚本参考](https://github.com/yeahwu/v2ray-wss)

## 以 root 用户执行

```bash
sudo su
```

## 安装Python依赖

```bash
curl https://raw.githubusercontent.com/qsoyq/shell/main/scripts/bash/pyenv-installer.sh | bash
source ~/.bash_profile
pyenv install 3.13.1 && pyenv global 3.13.1 && pyenv rehash
python3 -m pip install typer rich toml
```

## 安装 Reality

```bash
# 按提示输入参数
python3 <(curl -sL https://raw.githubusercontent.com/qsoyq/shell/main/scripts/python/vpn/reality.py)
```

### 传参示例

```bash
# 直接传入所有参数
python3 <(curl -sL https://raw.githubusercontent.com/qsoyq/shell/main/scripts/python/vpn/reality.py) \
    --sni www.amazon.com \
    --no-sniff \
    --port 443 \
    --uuid ed305e8e-123b-4477-a66d-52c68df4e199 \
    --short-ids 88 \
    --public-key ShmdO7WIVSv0Xy8qo4N3Ach8YwG8-_prSumyWDsgg0g \
    --private-key 8C6QksOsd5DXWqpEOa3bdSaaUDnGhOC4EoljJg7uuV8
```

## TCP优化

> 此脚本运行后会重启服务器。

```bash
wget https://raw.githubusercontent.com/yeahwu/v2ray-wss/main/tcp-window.sh && bash tcp-window.sh
```
