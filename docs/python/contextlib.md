# contextlib

## contextmanager

通过 `yield` 关键字将生成器函数包装成上下文管理器

<details>
<summary>Example</summary>

```python
import time
from contextlib import contextmanager

@contextmanager
def timeit_context(tag: str | None = None):
    if tag is None:
        tag = "timeit_context"

    if not tag.startswith("timeit_context"):
        tag = f"timeit_context - {timeit_context}"
    try:
        start_time = time.perf_counter()
        yield
    finally:
        end_time = time.perf_counter()
        process_time = end_time - start_time
        print(f"{tag} - {process_time:.2f}")

with timeit_context():
    time.sleep(1)
```

</details>

## suppress

在上下文中忽视指定的异常

<details>
<summary>Example</summary>

```python
import contextlib

with contextlib.suppress(RuntimeError):
    raise RuntimeError
```

</details>
