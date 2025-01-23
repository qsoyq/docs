# snellv3

## debian12 amd64

```bash
sudo apt update && sudo apt install unzip -y
curl -sL -o snell-server.zip https://raw.githubusercontent.com/qsoyq/shell/main/assets/bin/snell/snell-server-v3.0.1-linux-amd64.zip
unzip snell-server
rm snell-server.zip
echo 'y' | ./snell-server
nohup ./snell-server &
cat snell-server.conf |grep --color=auto listen
cat snell-server.conf |grep --color=auto psk
cat snell-server.conf |grep --color=auto obfs
```
