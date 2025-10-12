# mmap

mmap 通过利用操作系统的虚拟内存映射机制，将磁盘的文件映射到虚拟内存的连续空间, 以实现高效的文件内容读写

一些进程间的内存共享可以通过此机制实现

但是存在一些缺点

1. 内存映射导致占用更多的内存
2. 无法直接通过 mmap 扩写文件, 必须对文件本身进行扩写后, 再重新映射一块内存

## 映射文件到内存进行读写操作

```python
import mmap

with open("./example.dat", "r+b") as f:
    mm = mmap.mmap(f.fileno(), 0)
    data = mm[:10]
    mm[:5] = b"Hello"
    pos = mm.find(b"world")
    mm.close()

```
