## Apple CDN 优选 IP

下载脚本到本地

```bash
curl -L -o /usr/local/bin/dns-latency-ranker https://raw.githubusercontent.com/qsoyq/shell/main/scripts/python/tool/dns_latency_ranker.py 
```

安装脚本依赖

```bash
pip3 install typer httpx dnspython pythonping 
```

iOS App Store

```bash
sudo python3 /usr/local/bin/dns-latency-ranker -d iosapps.itunes.apple.com
```

macOS App Store

```bash
sudo python3 /usr/local/bin/dns-latency-ranker -d osxapps.itunes.apple.com
```
