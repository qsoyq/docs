# threading

[threading](https://docs.python.org/3/library/threading.html)

## Thread

> start -> _bootstrap ->_bootstrap_inner

_bootstrap_inner 是 Thread 中实际调用 `run` 方法的入口函数.

Thread.run 默认调用 Thread._target, 所以Thread子类重写`run`方法即可覆盖线程执行的函数.

在调用 Thread.run 之前, _bootstrap_inner 会更新当前子线程的`_trace_hook`和`_profile_hook`.

`threading.setprofile` 和 `threading.settrace` 可以设置响应的钩子.

通常用于实现 IDE 中的 debugger 和 profile.

## Lock

互斥锁, 用于实现资源的并发控制

## RLock

```python
def acquire(self, blocking=True, timeout=-1):
    me = get_ident()
    if self._owner == me:
        self._count += 1
        return 1
    rc = self._block.acquire(blocking, timeout)
    if rc:
        self._owner = me
        self._count = 1
    return rc

def release(self):
    if self._owner != get_ident():
        raise RuntimeError("cannot release un-acquired lock")
    self._count = count = self._count - 1
    if not count:
        self._owner = None
        self._block.release()
```

可重入锁, 允许在同一线程内多次获得锁, 并且只能由持有锁的线程释放.

主要场景用在跨线程并发控制的同时允许获得锁的线程重复申请资源.

在跨线程竞争且线程内部频繁请求锁的时候, 可能会造成单一线程长时间持有锁, 导致其他线程饥饿.

## Condition

```python
def _is_owned(self):
    # Return True if lock is owned by current_thread.
    # This method is called only if _lock doesn't have _is_owned().
    if self._lock.acquire(False):
        self._lock.release()
        return False
    else:
        return True
```

Condition 默认使用`RLock` 作为外层锁控制 `Context Manager` 的并发.

同时,在内部维护了一个 `_waiter` 局部锁队列, 表示每个等待中的线程对象所依赖的锁.

如果指定了非RLock或指定的 LockType 未实现`_is_owned`方法时, 默认实现会认为指定锁为非可重入锁.

每次 Condition.wait 调用时都会创建一个局部锁并锁住, 然后根据二次申请持有锁的成功状态来判断是否有外部释放了该锁.  同时, 在局部锁加入到等待队列后, 会释放外层的锁, 让其他线程能够进入到 `Condition.__enter__`.

Condition.notify按 `FIFO` 的顺序释放 Condition.wait 中创建的局部锁以唤醒.

Condition 主要用于线程间通信.

## Semaphore

Semaphore 使用基于互斥锁的 Condition 实现并发控制.

相比 Condition, Semaphore 提供了一个初始值, 表示并发数, 默认为 1.

每次调用 Semaphore.release 时, 相当于增加对应的并发数.

Semaphore 常用于无上限的并发数控制.

## BoundedSemaphore

Semaphore 的类似实现.

但是限制了并发数上限.

BoundedSemaphore 常用于有上限的并发数控制.

## Event

Event 使用基于互斥锁的 Condition 实现并发控制.

常用于单次状态变化的监听.

对于状态需要频繁重置并且存在多方监听的场景需要谨慎使用.

## Barrier

Barrier 使用基于互斥锁的 Condition 实现并发控制.

Barrier 允许绑定一个 action 回调函数, 在 release 时触发.

Barrier 在初始化时需要指定`parties`以表示等待线程的数量.

当同时调用`Barrier.wait`的线程达到该数量时, 会直接触发`Barrier._release`,  barrier的状态变为`draining`

调用`Barrier.abort` 可以唤醒所有等待中的线程, 并将 barrier 的状态变为 `broken`.

Barrier 适用于固定数量的线程等待一个同步点.

如游戏匹配中等待所有人数的就绪.

## Timer

基于 Thread, 在指定`interval`后执行 `target` 函数.

通过 Event 实现延迟控制, 并可以由外部调用`cancel`更改 event 的状态来取消.

## 并发控制

`Lock` 和 `RLock` 作为锁的实现, 支持了最基础的资源竞争控制.

`Condition` 在此基础上, 增加了跨线程的资源释放通知能力.

`Semaphore`、`BoundedSemaphore`、`Event`、`Barrier` 都是基于 Condition, 对某种适用场景的功能封装.
