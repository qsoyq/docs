# DevTool

git

```shell
git config --global --add --bool push.autoSetupRemote true
```

zsh

```shell
export GREP_OPTIONS='--color=always'
export HOMEBREW_NO_AUTO_UPDATE=1
export PIPMIRROR=https://mirrors.aliyun.com/pypi/simple/
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=true
export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=true
export MAC_IP=`ifconfig en0 | grep "inet " | cut -d " " -f2`

alias dc="docker-compose"
alias dn="docker network"
alias toi386="arch -ax86_64 zsh --login"
alias unset_proxy="unset http_proxy https_proxy all_proxy"
alias cloudflared.restart="sudo launchctl stop com.cloudflare.cloudflared && sudo launchctl start com.cloudflare.cloudflared"
```
