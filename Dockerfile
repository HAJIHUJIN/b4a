FROM python:3.11-alpine

WORKDIR /app

# 安装必要的系统工具
RUN apk add --no-cache curl tar ca-certificates bash

COPY . .

# 暴露 Back4App 默认端口 8080
EXPOSE 8080

CMD ["python3", "main.py"]
