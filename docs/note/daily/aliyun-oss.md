# 阿里云 OSS 管理

- [阿里云 OSS 控制台](https://oss.console.aliyun.com/overview)

## Bucket 管理

### 创建

1. 登陆 [Bucket 列表](https://oss.console.aliyun.com/bucket)
2. 创建 Bucket, 快捷创建, 输入 Bucket 名称、地域

### 数据安全

#### 跨域设置

1. 在[Bucket 列表](https://oss.console.aliyun.com/bucket) 找到创建的 bucket
2. 左侧菜单页 -> 数据安全 -> 跨域设置 -> 创建规则
	1. 来源设置为 `*`
	2. 允许 Methods 全部勾选上
	3. 确定

### 权限控制

#### 公共访问

1. 在[Bucket 列表](https://oss.console.aliyun.com/bucket) 找到创建的 bucket
2. 左侧菜单页 -> 权限控制 -> 阻止公共访问 -> 关闭
3. 左侧菜单页 -> 权限控制 -> 读写权限 -> Bucket ACL -> 设置公共读

### 访问控制RAM

1. 在[Bucket 列表](https://oss.console.aliyun.com/bucket) 找到创建的 bucket
2. 左侧菜单页 -> 权限控制 -> 访问控制 RAM -> 前往 [RAM 控制台](https://ram.console.aliyun.com/overview?activeTab=overview)
3. 概览 -> 快速开始 -> 创建程序用户 -> 创建程序用户/向指定 OSS Bucket 写入对象
4. 按需修改登陆名称、策略名称
5. 策略内容 -> OSS Bucket ->  编辑资源名称 -> bucketName 输入授权的名称或者勾选匹配全部 -> 确定 -> 执行配置

### endpoint列表

- 上海, oss-cn-shanghai.aliyuncs.com
- 杭州, oss-cn-hangzhou.aliyuncs.com
