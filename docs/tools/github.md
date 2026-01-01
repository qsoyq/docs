# github 使用手册

- [API 文档](https://docs.github.com/en/rest/releases/releases)

## Sub Module

同步子模块

```bash
git submodule update --init --recursive
```

## 通过密钥访问

1. 创建密钥

    ```bash
    # cd ~/.ssh
    ssh-keygen -t ed25519 -C "email@example.com"
    ```

2. 在后台中添加密钥
3. 在配置文件指定地址使用特定的密钥

    ~/.ssh/config

    ```bash
    Host example.org
    HostName example.org
    Port 443
    User git
    IdentityFile ~/.ssh/example
    ```

## credentials

在首次拉取验证通过后将凭证保存在全局路径文件内, 在后续直接使用

```bash
# 使 https 凭证存储在 ~/.git-credentials
git config --global credential.helper store
```

## gh

### Notifications

[API](https://docs.github.com/zh/rest/activity/notifications?apiVersion=2022-11-28#list-notifications-for-the-authenticated-user)

#### 查找并删除指定通知

gh api notifications q='reason:mention'
