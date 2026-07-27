FROM ghcr.io/sagernet/sing-box:latest AS singbox-builder
FROM cloudflare/cloudflared:latest AS cloudflared-builder

FROM alpine:latest

RUN apk add --no-cache ca-certificates curl bash jq dos2unix python3

COPY --from=singbox-builder /usr/local/bin/sing-box /usr/local/bin/node-runtime
COPY --from=cloudflared-builder /usr/local/bin/cloudflared /usr/local/bin/tunnel-agent

RUN chmod 755 /usr/local/bin/node-runtime /usr/local/bin/tunnel-agent

WORKDIR /app
COPY index.html /app/index.html
COPY config.json /app/app.settings.data
COPY entrypoint.sh /app/start-app.sh

RUN dos2unix /app/start-app.sh /app/app.settings.data && chmod +x /app/start-app.sh

# 只保留一个默认端口 8080，方便 Back4app 自动锁定
EXPOSE 8080

ENTRYPOINT ["/bin/sh", "/app/start-app.sh"]
