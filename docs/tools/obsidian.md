# Obsidian

## LiveSync 部署

插件利用 couchdb 数据库提供的 HTTP API 访问、存储数据.

部署在本地的数据库通过 cloudflare tunnel 访问, 多端同步, 测试约有 5s 的延迟.

该插件只用于同步, 数据备份需要另外处理.

```shell
cat > /opt/couchdb/etc/local.ini <<EOF
[couchdb]
single_node=true
max_document_size = 50000000

[chttpd]
require_valid_user = true
max_http_request_size = 4294967296

[chttpd_auth]
require_valid_user = true
authentication_redirect = /_utils/session.html

[httpd]
WWW-Authenticate = Basic realm="couchdb"
enable_cors = true

[cors]
origins = app://obsidian.md,capacitor://localhost,http://localhost
credentials = true
headers = accept, authorization, content-type, origin, referer
methods = GET, PUT, POST, HEAD, DELETE
max_age = 3600
EOF
```

```shell
docker run --rm -it -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password -v /opt/couchdb/etc/local.ini:/opt/couchdb/etc/local.ini -p 5984:5984 couchdb
```

```shell
docker run -d --restart always -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password -v /opt/couchdb/etc/local.ini:/opt/couchdb/etc/local.ini -p 5984:5984 couchdb
```

参考教程: <https://forum-zh.obsidian.md/t/topic/6241>

---
