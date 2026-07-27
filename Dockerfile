FROM ghcr.io/sagernet/sing-box:latest AS singbox-builder
FROM cloudflare/cloudflared:latest AS cloudflared-builder

FROM alpine:latest

# 安装基础依赖与 Python (提供静态网页)
RUN apk add --no-cache ca-certificates curl bash jq dos2unix python3

# 从官方镜像精准复制二进制并伪装重命名
COPY --from=singbox-builder /usr/local/bin/sing-box /usr/local/bin/node-runtime
COPY --from=cloudflared-builder /usr/local/bin/cloudflared /usr/local/bin/tunnel-agent

RUN chmod 755 /usr/local/bin/node-runtime /usr/local/bin/tunnel-agent

WORKDIR /app
COPY index.html /app/index.html
COPY config.json /app/app.settings.data
COPY entrypoint.sh /app/start-app.sh

RUN dos2unix /app/start-app.sh /app/app.settings.data && chmod +x /app/start-app.sh

# 告诉 Back4app 容器所暴露的端口 (修复 Back4app 的部署报错)
EXPOSE 8080
EXPOSE 8081

ENTRYPOINT ["/bin/sh", "/app/start-app.sh"]
