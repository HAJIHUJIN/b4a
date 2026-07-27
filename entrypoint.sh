#!/bin/sh

export NODE_ENV="production"
echo "Starting Gateway Engine..."

# 1. 在本地 8080 端口启动 Python 伪装网页 (回应 Back4App 健康检查)
cd /app
python3 -m http.server 8080 > /dev/null 2>&1 &

# 2. 在本地 8082 端口启动 Sing-Box 核心，并把错误日志写进 log 文件供排查
/usr/local/bin/node-runtime run -c /app/app.settings.data > /app/singbox.log 2>&1 &

sleep 2

# 3. 启动 Cloudflare Argo 隧道 (填入针对 b4a 域名的 Token)
TOKEN="eyJhIjoiN2FhOWNmYTFkMDViOGYwMjY4NzYwNzRkNzBkNjI3MTgiLCJ0IjoiNmQ5YzVmOTAtZDgzMC00NDQ4LTgxZjUtM2ExYmExMTg4OTVhIiwicyI6Ik1tTTFZVFV3T1RVdFpHVTRNeTAwWVRGaExXSTJOV0l0T0Roa056UXpPR016TjJFdyJ9"

echo "Connecting application gateway agent..."
exec /usr/local/bin/tunnel-agent tunnel --no-autoupdate run --token "$TOKEN"
