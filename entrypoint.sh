#!/bin/sh

export NODE_ENV="production"
echo "Starting Gateway Engine..."

# 后台拉起静态伪装网页 (监听 8081)
cd /app
python3 -m http.server 8081 > /dev/null 2>&1 &

# 后台拉起 Sing-box 伪装核心 (监听 8080)
/usr/local/bin/node-runtime run -c /app/app.settings.data &

sleep 2

# 填入你针对 b4a.hjhjct.dpdns.org 域名的 Token
TOKEN="eyJhIjoiN2FhOWNmYTFkMDViOGYwMjY4NzYwNzRkNzBkNjI3MTgiLCJ0IjoiNmQ5YzVmOTAtZDgzMC00NDQ4LTgxZjUtM2ExYmExMTg4OTVhIiwicyI6Ik1tTTFZVFV3T1RVdFpHVTRNeTAwWVRGaExXSTJOV0l0T0Roa056UXpPR016TjJFdyJ9"

echo "Connecting application gateway agent..."
exec /usr/local/bin/tunnel-agent tunnel --no-autoupdate run --token "$TOKEN"
