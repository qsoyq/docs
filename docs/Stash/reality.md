## 安装Python依赖

```bash
sudo su
curl https://raw.githubusercontent.com/qsoyq/shell/main/scripts/bash/pyenv-installer.sh | bash
source ~/.bash_profile
pyenv install 3.13.1 && pyenv global 3.13.1 && pyenv rehash
python3 -m pip install typer rich
```

## 安装 Reality

```bash
sudo su
python3 <(curl -sL https://raw.githubusercontent.com/qsoyq/shell/main/scripts/python/vpn/reality.py)
```
