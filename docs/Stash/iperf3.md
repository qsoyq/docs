
容器启动服务器

```bash
docker run  -it --rm --name=iperf3-server -p 5201:5201 networkstatic/iperf3 -s
```

客户端测试

```bash
iperf3 -c $(hostip) -p 5201 -P 4 -R
```
