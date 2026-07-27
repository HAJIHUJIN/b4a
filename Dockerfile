#!/bin/bash

# 1. 赋予二进制文件可执行权限
chmod +x ./sing-box ./cloudflared

echo "=========================================="
echo " 正在启动 Sing-box 与 Cloudflare Argo... "
echo "=========================================="

# 2. 在后台拉起 Sing-box
./sing-box run -c ./config.json &

# 3. 等待 2 秒确保 Sing-box 已经监听 8080 端口
sleep 2

# 4. 在前台拉起 Argo Tunnel（使用 exec 保持容器持续运行）
exec ./cloudflared tunnel --no-autoupdate run --token "eyJhIjoiN2FhOWNmYTFkMDViOGYwMjY4NzYwNzRkNzBkNjI3MTgiLCJ0IjoiNWMwMTAxYjUtNTQwZS00MjUwLTlhYzItMWFiNDgyMDA2ZjVlIiwicyI6Ik5tSmxZMkUyTjJJdFpUaGtPQzAwTURZNExXSTJNRGN0T0RJM1lUUmxOR1F5WXpJeCJ9"