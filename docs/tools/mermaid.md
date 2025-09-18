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
