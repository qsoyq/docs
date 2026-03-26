# Tailscale

## Subnet

设备通过发布子网, 让网络内的设备访问目标网段时通过该出口访问

```shell
sudo tailscale up \
  --advertise-routes=0.0.0.0/1,128.0.0.0/1,127.0.0.1/32 \
  --accept-dns=false \
  --accept-routes \
  --advertise-exit-node \
  --reset
```
