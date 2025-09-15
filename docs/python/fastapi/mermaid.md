# 在FastAPI 路由注释中支持 Mermaid 图表方案

## 背景

FastAPI 会提取路由函数的注释并添加到生成的 OpenAPI 文档中

希望能在 OpenAPI 的前端页面中支持显示`mermaid`图表

## 分析

FastAPI 在指定请求中返回`redoc`/`docs`两种风格的的`OpenAPI`前端显示页面

通过注入的方式，在前端页面中引入`mermaid`的 sdk, 即可让页面支持渲染`mermaid`图表

## 方案

1. 构造替换装饰器函数, 在 HTML 中注入引用`mermaid`的代码
2. 覆写模块函数

<details>

<summary>点击查看代码示例</summary>

```python
import imp
from functools import wraps
from typing import Callable


import fastapi
import fastapi.applications
import fastapi.openapi.docs
from fastapi.responses import HTMLResponse


def add_mermaid_support(func: Callable[..., HTMLResponse]):
    """在</head>标签前插入mermaid js

    https://mermaid-js.github.io/mermaid/#/n00b-gettingStarted?id=requirements-for-the-mermaid-api
    """
    mermaid_js = '''

    <script type="module">
      import mermaid from 'https://unpkg.com/mermaid@9/dist/mermaid.esm.min.mjs';
      mermaid.initialize({ startOnLoad: true });
    </script>

    '''

    @wraps(func)
    def decorator(*args, **kwargs) -> HTMLResponse:
        res = func(*args, **kwargs)
        content = res.body.decode(res.charset)
        index = content.find("</head>")
        if index != -1:
            content = content[:index] + mermaid_js + content[index:]
        return HTMLResponse(content)

    return decorator


# A
fastapi.openapi.docs.get_swagger_ui_html = add_mermaid_support(fastapi.openapi.docs.get_swagger_ui_html)
fastapi.openapi.docs.get_redoc_html = add_mermaid_support(fastapi.openapi.docs.get_redoc_html)
imp.reload(fastapi.applications)

# B
# fastapi.applications.get_swagger_ui_html = add_mermaid_support(fastapi.openapi.docs.get_swagger_ui_html)
# fastapi.applications.get_redoc_html = add_mermaid_support(fastapi.openapi.docs.get_redoc_html)
# app = FastAPI()

@router.get('/')
def hello():
    """
    <pre class="mermaid">
            graph TD
            A[Client] -->|tcp_123| B
            B(Load Balancer)
            B -->|tcp_456| C[Server1]
            B -->|tcp_456| D[Server2]
    </pre>
    """
    return "hello world"

```

</details>

[参考示例](https://github.com/qsoyq/pytoolkit/blob/main/examples/mermaid_with_fastapi_openapi/main.py)

## 回顾

### 对于模块函数的覆写

`fastapi.applications`模块通过 `from import` 语法导入并使用相应的函数对象, 所以需要通过 `imp.reload(fastapi.applications)`重载模块.

或者直接修改 `fastapi.applications.get_swagger_ui_html` 和 `fastapi.applications.get_redoc_html` 函数对象.
