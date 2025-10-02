# v2fly/domain-list-community

[main.go](https://github.com/v2fly/domain-list-community/blob/master/main.go)

## 序列化规则

### 主流程

1. 读取项目内容
	1. 遍历`data`目录
	2. 针对每个文件路径，执行`Load`解析文件, 记录 Name 和 List 的映射到`ref`对象
2. 创建输出目录
3. 基于 Proto 序列化输出
	1. 实例化 `router.GeoSiteList`
	2. 遍历 `ref` 对象
		1. 使用`ParseList` 解析单个文件的内容
		2. 使用`ParseList.toProto` 返回 `GeoSite`对象
		3. 将 `GeoSite`实例对象添加到`GeoSiteList.Entry`数组
		4. 根据`exportlists`命令行参数，选择是否以文本形式将文件内的记录输出到标准输出
	3. 根据 `CountryCode` 对 `router.GeoSiteList` 实例对象进行排序
	4. 对`router.GeoSiteList`进行序列化，生成二进制数据
	5. 将序列化后的二进制写入到文件

### protobuf

Protobuf 结构如下

- GeoSiteList
   	- GeoSite
      		- Domain
         			- Domain_Type
         			- Domain_Attribute

<details>
<summary>查看代码示例</summary>

```go
type GeoSiteList struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Entry []*GeoSite `protobuf:"bytes,1,rep,name=entry,proto3" json:"entry,omitempty"`
}

```

```go
type GeoSite struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	CountryCode string    `protobuf:"bytes,1,opt,name=country_code,json=countryCode,proto3" json:"country_code,omitempty"`
	Domain      []*Domain `protobuf:"bytes,2,rep,name=domain,proto3" json:"domain,omitempty"`
	// resource_hash instruct simplified config converter to load domain from geo file.
	ResourceHash []byte `protobuf:"bytes,3,opt,name=resource_hash,json=resourceHash,proto3" json:"resource_hash,omitempty"`
	Code         string `protobuf:"bytes,4,opt,name=code,proto3" json:"code,omitempty"`
	FilePath     string `protobuf:"bytes,68000,opt,name=file_path,json=filePath,proto3" json:"file_path,omitempty"`
}
```

```go
type Domain struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	// Domain matching type.
	Type Domain_Type `protobuf:"varint,1,opt,name=type,proto3,enum=v2ray.core.app.router.routercommon.Domain_Type" json:"type,omitempty"`
	// Domain value.
	Value string `protobuf:"bytes,2,opt,name=value,proto3" json:"value,omitempty"`
	// Attributes of this domain. May be used for filtering.
	Attribute []*Domain_Attribute `protobuf:"bytes,3,rep,name=attribute,proto3" json:"attribute,omitempty"`
}
```

```go
type Domain_Attribute struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Key string `protobuf:"bytes,1,opt,name=key,proto3" json:"key,omitempty"`
	// Types that are assignable to TypedValue:
	//
	//	*Domain_Attribute_BoolValue
	//	*Domain_Attribute_IntValue
	TypedValue isDomain_Attribute_TypedValue `protobuf_oneof:"typed_value"`
}
```

</details>

- [使用Python反序列化二进制文件](https://docs.19940731.xyz/python/proto-plus/?h=proto#v2fly-geosite-dat)

### 带着问题看源码

1. GeoSite 对象的 CountryCode 是如何得到的?
