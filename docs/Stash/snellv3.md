# snellv3

## debian12 amd64

```bash
#!/bin/bash
sudo apt update && sudo apt install unzip -y
curl -sL -o ./snell-server.zip https://raw.githubusercontent.com/qsoyq/shell/main/assets/bin/snell/snell-server-v3.0.1-linux-amd64.zip
unzip ./snell-server
mv ./snell-server /usr/local/bin/snell
chmod +x /usr/local/bin/snell
rm ./snell-server.zip
mkdir -p /root/snell
echo 'y' | snell -c /root/snell/snell.conf
nohup snell -c /root/snell/snell.conf > /root/snell/nohup.out 2>&1 &
cat < /root/snell/snell.conf |grep --color=auto listen
cat < /root/snell/snell.conf |grep --color=auto psk
cat < /root/snell/snell.conf |grep --color=auto obfs
```
