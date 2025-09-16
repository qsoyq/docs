# 增删改查手册

## Select

### 查询显式加锁

查询加读写锁

```sql
SELECT * FROM table_name WHERE condition FOR UPDATE;
SELECT * FROM table_name WHERE condition LOCK IN SHARE MODE;
```

获取表读写锁

```sql
LOCK TABLES table_name READ;
LOCK TABLES table_name WRITE;

UNLOCK TABLES;
```

获取用户自定义锁

```sql
SELECT GET_LOCK('my_lock', 10);
SELECT RELEASE_LOCK('my_lock');
```
