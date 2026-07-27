#!/bin/sh

export NODE_ENV="production"
echo "Starting Gateway Engine..."

# 1. 静态网页监听 8080 端口 (回应 Back4app 健康检查，返回 200 OK)
cd /app
python3 -m http.server 8080 > /dev/null 2>&1 &

# 2. Sing-box 监听 8082 端口
/usr/local/bin/node-runtime run -c /app/app.settings.data &

sleep 2

# 3. 启动 Cloudflare Argo 隧道 (把 Cloudflare 的 8080 流量转发到本地 8080/8082)
TOKEN="eyJhIjoiN2FhOWNmYTFkMDViOGYwMjY4NzYwNzRkNzBkNjI3MTgiLCJ0IjoiNmQ5YzVmOTAtZDgzMC00NDQ4LTgxZjUtM2ExYmExMTg4OTVhIiwicyI6Ik1tTTFZVFV3T1RVdFpHVTRNeTAwWVRGaExXSTJOV0l0T0Roa056UXpPR016TjJFdyJ9"

echo "Connecting application gateway agent..."
exec /usr/local/bin/tunnel-agent tunnel --no-autoupdate run --token "$TOKEN"
