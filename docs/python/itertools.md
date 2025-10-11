# itertools

## batched

将序列按长度划分为多个元组的迭代器

<details>
<summary>Example</summary>

```python
import itertools

data = ['apple', 'banana', 'cherry', 'date', 'elderberry', 'fig', 'grape']

batches = itertools.batched(data, 3)

for batch in batches:
    print(batch)

# ('apple', 'banana', 'cherry')
# ('date', 'elderberry', 'fig')
# ('grape',)

```

</details>
