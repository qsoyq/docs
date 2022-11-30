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
    """在</body>标签前插入mermaid js

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
        index = content.find("</body>")
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
fastapi.openapi.docs.get_swagger_ui_html = add_mermaid_support(fastapi.openapi.docs.get_swagger_ui_html)
fastapi.openapi.docs.get_redoc_html = add_mermaid_support(fastapi.openapi.docs.get_redoc_html)
imp.reload(fastapi.applications)
app = FastAPI()
```

`imp.reload(fastapi.applications)`重载了模块, 使得替换函数能生效

替换行为必须发生在 `FastAPI` 对象实例化之前.

否则需要重新调用对象的`setup`方法重置文档路由.

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
