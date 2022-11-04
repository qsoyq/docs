# vscode

## 重新选择

17 年的时候, 因为 15 款的 mba 运行 pycharm 过于吃力, 在一阵犹豫后就改用 sublime text 作为开发工具.

一直到 2022.03.02, 也差不多有 5 个年头了, 也终于要让 sublime text 退居二线了.

作为一个重度 sublime text 用户, 是什么让我放弃了 st 而转向 vscode 的呢?

`anaconda`插件的更新, 算是导火线.

sublime 内置的`goto definition` 命令仅对函数和包跳转支持的比较好,  在对普通变量的跳转上表现较差.

在之前, 一直在使用`anaconda`的代码跳转功能, 但是今天的更新后, 这个功能出现了异常.

每一次的跳转, 大概率都是打开了一个 None 的空文件.

sublime 的更新频率、插件可靠性、用户人群, 再加上今天的`goto definition`事件, 让我打算彻底放弃这款编辑器.

## 如何选择

首选需要考虑的是, 比较`重`的 IDE, 还是比较`轻`的编辑器.

pycharm 作为老牌 IDE, 用来做 python 开发是不会有什么问题的.

而 m1 芯片加成的 mbp, 也足以运行这样的工具.

考虑到对编辑器的习惯, 还是将 pycharm 作为一个候选, 等后面足够空闲了,  会再考虑使用吧.

那么使用编辑器的话, 近年来最热门的 VSCode, 自然就是首选了.

## 如何适应 VScode

编辑器的迁移, 需要准备一系列的调研, 去搭建属于我自己的开发工具.

以下是为自己准备的一些摸索:

- 如何配置 UI 主题
- 插件市场

## 插件问题排查

通过扩展二等分, 一步步定位出现问题的扩展

## Plugin

### Markdown Table

[markdowntable](https://marketplace.visualstudio.com/items?itemName=TakumiI.markdowntable)

### Cannot read properties of undefined (reading 'trim')

> 命令"Markdown Table: Navigate to next cell."导致错误 (Cannot read properties of undefined (reading 'trim'))

<https://github.com/takumisoft68/vscode-markdown-table/issues/13>

当表格格式不正确时, 执行部分命令会出现此错误

## 自定义配置

```json
{
    "workbench.colorTheme": "Dainty – Monokai",
    "redhat.telemetry.enabled": true,
    "explorer.confirmDelete": false,
    "git.confirmSync": false,
    "git.autofetch": true,
    "files.exclude": {
        "**/__pycache__": true,
        "**/.benchmarks": true,
        "**/.mypy_cache": true,
        "**/.pytest_cache": true,
        "**/.venv": true,
        "**/.vscode": true
    },
    "editor.bracketPairColorization.enabled": true,
    "files.autoGuessEncoding": true,
    "workbench.startupEditor": "none",
    "google-translate.maxSizeOfResult": 300,
    "[markdown]": {
        // "editor.defaultFormatter": "mervin.markdown-formatter"

        "editor.formatOnSave": true,
        "editor.formatOnPaste": true,
        "editor.quickSuggestions": {
            "comments": "on",
            "strings": "on",
            "other": "on"
        },
        "editor.defaultFormatter": "DavidAnson.vscode-markdownlint"
    },

    "google-translate.firstLanguage": "zh-cn",
    "google-translate.secondLanguage": "en",
    "diffEditor.ignoreTrimWhitespace": false,


    // markdownlint
    "markdownlint.config": {
        "default": true,
        "MD004": {"style": "dash"},
        "MD007": { "indent": 4 },
        // "MD025": false,
        // "MD045": false,
        "no-hard-tabs": false

    },

    // highlightwords
    // https://marketplace.visualstudio.com/items?itemName=rsbondi.highlight-words
    "highlightwords.defaultMode": {
        "default": 1
    },
    "workbench.editor.untitled.hint": "hidden",

    // go
    "go.testTimeout": "600s",
    "go.toolsManagement.autoUpdate": true,

    // python
    "python.analysis.typeCheckingMode": "basic",
    "explorer.confirmDragAndDrop": false,
    "editor.minimap.enabled": false,
    "workbench.activityBar.visible": false,

}
```
