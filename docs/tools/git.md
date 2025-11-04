# git 手册

## 本地开发

### 撤回已提交未推送到本地暂存区

```bash
git reset --soft HEAD~1
```

### 忽略指定文件的变动

忽略文件

```bash
git update-index --assume-unchanged <filename>
```

还原

```bash
git update-index --no-assume-unchanged <filename>
```

#### 注意点

1. 使用`git checkout` 会导致对临时忽略文件的修改也被还原

### 设置

自动关联远程分支

```bash
git config --global --add --bool push.autoSetupRemote true
```
