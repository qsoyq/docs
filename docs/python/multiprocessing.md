# multiprocessing

## 关于进程间通信

1. Pipe 功能单一, 适合最简单的一对一通信
2. Queue 适合一对多的小数据通信, 灵活安全
3. shared_memory 主要功能是进程间内存共享

## Queue

比较可靠的跨进程通信方案, 适合传递一些小数据

<details>
<summary>Example</summary>

```python
from multiprocessing import Process, Queue
import time


def producer(q):
    for i in range(5):
        q.put(f"item {i}")
        print(f"Produced item {i}")
        time.sleep(1)


def consumer(q):
    while True:
        item = q.get()
        print(f"Consumed {item}")
        if item == "item 4":
            break


if __name__ == "__main__":
    q = Queue()
    p1 = Process(target=producer, args=(q,))
    p2 = Process(target=consumer, args=(q,))
    p1.start()
    p2.start()
    p1.join()
    p2.join()

```

</details>

## Pipe

通过管道机制在不同进程间一对一通信, 比 Queue 更轻量，功能也更单一

<details>
<summary>Example</summary>

```python
from multiprocessing import Process, Pipe

def worker(conn):
    msg = conn.recv()
    print("Child received:", msg)
    conn.send("Hello from child")
    conn.close()

if __name__ == "__main__":
    parent_conn, child_conn = Pipe()
    p = Process(target=worker, args=(child_conn,))
    p.start()
    parent_conn.send("Hello from parent")
    print("Parent received:", parent_conn.recv())
    p.join()

```

</details>

## shared_memory

基于操作系统的共享内存机制, 在各个进程间传递`name`来访问内存, 性能更高效，适合大批量的数据

<details>
<summary>Example</summary>

```python
from multiprocessing import Process, shared_memory
import numpy as np


def worker(name, shape):
    existing_shm = shared_memory.SharedMemory(name=name)
    np_array = np.ndarray(shape, dtype=np.int64, buffer=existing_shm.buf)
    np_array[0] = 99
    existing_shm.close()


if __name__ == "__main__":
    array = np.array([1, 2, 3, 4, 5], dtype=np.int64)
    shm = shared_memory.SharedMemory(create=True, size=array.nbytes)
    shm_array = np.ndarray(array.shape, dtype=array.dtype, buffer=shm.buf)
    shm_array[:] = array[:]

    p = Process(target=worker, args=(shm.name, array.shape))
    p.start()
    p.join()

    print("Shared memory content:", shm_array[:])
    shm.close()
    shm.unlink()
```

</details>
