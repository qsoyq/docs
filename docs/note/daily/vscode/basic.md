# VScode 使用手册

## 修改编辑器格式检查

### Markdown

#### 忽略部分警告

1. 命令面板输入 `Open User Settings(JSON)`, 打开用户配置文件
2. 找到或添加 `markdownlint.config`
3. 指定例如 `MD024`的策略, 如 `false` 表示禁用

<details>
<summary>查看代码示例</summary>
```json
{
    "markdownlint.config": {
        "default": true,
        "MD004": {
            "style": "dash"
        },
        "MD024": false,
        "MD041": false,
        "MD045": false,
        "MD007": {
            "indent": 4
        },
        "no-hard-tabs": false
    }
}
```

</details>

## 自定义有代码片段模板

1. 命令行面板选择`Snippets: Configure Snippets`
2. 选择为全局或当前项目添加 `New Global Snippets file...` or `New Snippets file for '{project}'`
3. 配置模板参数

<details>
<summary>查看代码示例</summary>
```json
{
    "DetailsTag": {
        "prefix": "details",
        "body": [
            "<details>",
            "<summary>查看代码示例</summary>",
            "",
            "",
            "</details>"
        ],
        "description": "快速创建 details - summary 标签"
    }
}
```
</details>
