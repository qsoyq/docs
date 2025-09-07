# 使用快捷指令创建 Github Issue

## 准备

在[Github Token 设置页面](https://github.com/settings/personal-access-tokens) 创建一个具有 `Issue` 权限的 Token

## 具体步骤

1. 添加一个 `Ask for input` 组件，输入标题
2. 添加一个 `Ask for input` 组件，输入内容
3. 添加一个 `Text` 组件，输入`owner`用户名
4. 添加一个 `Text` 组件，输入`repo`仓库名
5. 添加一个 `Text` 组件，输入之前准备的 `Token`
6. 添加一个`URL`组件, 拼接 url, 路径为`https://api.github.com/repos/{owner}/{repo}/issues`, 将`owner`和`repo`变量填入对应的位置
7. 添加一个`Dictionary`组件，分别添加`title`和`body` key, value 和步骤 1、2 中的变量
8. 添加一个`Get Contents of URL`组件
      1. `Method` 选择`POST`
      2. 设置 `Headers`
           1. 添加 `Authorization`, 值为 `Bearer {token}`, token 为步骤 5 准备的变量
           1. 添加 `Accept`, 值为 `application/vnd.github+json`
           1. 添加 `X-Github-Api-Version`, 值为 `2022-11-28`
      3. Request Body 设置为 `File`, 选择步骤 7 的`Dictionary`变量

## 运行

点击指令运行后，会连续出现两个文本框，分别输入标题和内容, 等待指令执行完成后即创建 `Issue` 成功
