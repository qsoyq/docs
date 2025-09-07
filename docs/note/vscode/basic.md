# VScode 使用手册

## 修改编辑器格式检查

### Markdown

#### 忽略部分警告

1. 命令面板输入 `Open User Settings(JSON)`, 打开用户配置文件
2. 找到或添加 `markdownlint.config`
3. 指定例如 `MD024`的策略, 如 `false` 表示禁用

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
