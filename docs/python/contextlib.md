# contextlib

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
