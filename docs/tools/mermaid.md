# [mermaid](https://github.com/mermaid-js/mermaid)

[mkdocs-material-diagrams](https://squidfunk.github.io/mkdocs-material/reference/diagrams/)

## 流程图

```mermaid
graph LR
    A[路由匹配开始] --> B{命名捕获组正则匹配成功?}
    B -->|YES| C{命名参数提取校验是否成功?}
    B -->|NO| D[Match.NONE]
    C -->|YES| F{请求方法是否允许?}
    C -->|NO| E[异常]
    F -->|YES| G[Match.FULL]
    F -->|NO| H[Match.PARTIAL]
```

```` markdown title="sequenceDiagram"
``` mermaid
sequenceDiagram
Alice->>John: Hello John, how are you?
loop Healthcheck
    John->>John: Fight against hypochondria
end
Note right of John: Rational thoughts!
John-->>Alice: Great!
John->>Bob: How about you?
Bob-->>John: Jolly good!
```
````

```mermaid
sequenceDiagram
Alice->>John: Hello John, how are you?
loop Healthcheck
    John->>John: Fight against hypochondria
end
Note right of John: Rational thoughts!
John-->>Alice: Great!
John->>Bob: How about you?
Bob-->>John: Jolly good!
```

## 甘特图

```mermaid
gantt
    title 项目进度图例
    dateFormat YYYY-MM-DD
    axisFormat %m-%d
    section 需求分析
    需求调研 :a1, 2025-10-01, 5d
    需求确认 :a2, after a1, 3d
    section 开发阶段
    编码 :b1, 2025-10-10, 7d
    测试 :b2, after b1, 4d
```
