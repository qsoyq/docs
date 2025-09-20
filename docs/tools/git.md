# git 手册

## 本地开发

### 忽略指定文件的变动

忽略文件

```bash
git update-index --assume-unchanged <filename>
```

还原

```bash
git update-index --no-assume-unchanged <filename>
```

### 设置

自动关联远程分支

```bash
git config --global --add --bool push.autoSetupRemote true
```
