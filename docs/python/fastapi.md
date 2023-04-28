# fastapi

[fastapi](https://fastapi.tiangolo.com/)

## support mermaid

在自动生成的API 文档中, 支持`mermaid`图表

### 构造替换函数, 在返回的 HTML 中引入 `mermaid js`

```python
from functools import wraps
from typing import Callable

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
```

### 替换html渲染函数

```python
import imp
import fastapi
import fastapi.applications
import fastapi.openapi.docs

# A
fastapi.openapi.docs.get_swagger_ui_html = add_mermaid_support(fastapi.openapi.docs.get_swagger_ui_html)
fastapi.openapi.docs.get_redoc_html = add_mermaid_support(fastapi.openapi.docs.get_redoc_html)
imp.reload(fastapi.applications)

# B
# fastapi.applications.get_swagger_ui_html = add_mermaid_support(fastapi.openapi.docs.get_swagger_ui_html)
# fastapi.applications.get_redoc_html = add_mermaid_support(fastapi.openapi.docs.get_redoc_html)
# app = FastAPI()
```

`fastapi.applications`模块通过 `from import` 语法导入并使用相应的函数对象, 所以需要通过 `imp.reload(fastapi.applications)`重载模块.

或者直接修改 `fastapi.applications.get_swagger_ui_html` 和 `fastapi.applications.get_redoc_html` 函数对象.

### 在函数注释中添加mermaid图表

```python
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

[参考示例](https://github.com/qsoyq/pytoolkit/blob/main/examples/mermaid_with_fastapi_openapi/main.py)
