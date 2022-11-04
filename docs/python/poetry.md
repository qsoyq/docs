# Poetry

## Faq

### install-failure-invalid-hashes

[python-poetry-install-failure-invalid-hashes](https://stackoverflow.com/questions/71001968/python-poetry-install-failure-invalid-hashes)

在`poetry` 安装过程中意外退出, 可能会导致缓存污染造成安装失败.

此时只需清理缓存目录即可.

```shell
rm -r ~/Library/Caches/pypoetry/cache
rm -r ~/Library/Caches/pypoetry/artifacts
```
