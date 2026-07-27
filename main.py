import os
import sys
import json
import urllib.request
import tarfile
import subprocess
import time

# ==================== 参数配置 ====================
UUID = os.environ.get("UUID", "2c11bde0-fa06-4438-9ff0-f8502faf6aa3")
TUNNEL_HOST = "back4app.hjhjct.dpdns.org"  # 伪装域名
ENTRY_HOST = "nexusmods.com"             # 优选入口
WS_PATH = "/vless"

# Back4App 自动注入 PORT 环境变量，默认 8080
PORT = int(os.environ.get("PORT", 8080))
# ==================================================

WORK_DIR = os.path.dirname(os.path.abspath(__file__))
SINGBOX_PATH = os.path.join(WORK_DIR, "sing-box")
CONFIG_PATH = os.path.join(WORK_DIR, "config.json")

def prepare_singbox():
    """检测并自动下载 Sing-box 核心文件"""
    is_valid = False
    if os.path.exists(SINGBOX_PATH):
        try:
            if os.path.getsize(SINGBOX_PATH) > 5 * 1024 * 1024:
                is_valid = True
        except Exception:
            pass

    if not is_valid:
        print("[i] 正在自动下载 Sing-box 核心程序...")
        if os.path.exists(SINGBOX_PATH):
            os.remove(SINGBOX_PATH)

        tar_path = os.path.join(WORK_DIR, "sing-box.tar.gz")
        if os.path.exists(tar_path):
            os.remove(tar_path)

        url = "https://github.com/SagerNet/sing-box/releases/download/v1.9.3/sing-box-1.9.3-linux-amd64.tar.gz"
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        
        with urllib.request.urlopen(req) as response, open(tar_path, "wb") as out_file:
            out_file.write(response.read())

        print("[i] 正在自动解压...")
        with tarfile.open(tar_path, "r:gz") as tar:
            for member in tar.getmembers():
                if member.name.endswith("/sing-box") or member.name == "sing-box":
                    member.name = "sing-box"
                    tar.extract(member, WORK_DIR)

        if os.path.exists(tar_path):
            os.remove(tar_path)

        if os.path.exists(SINGBOX_PATH):
            os.chmod(SINGBOX_PATH, 0o755)
            print("[✓] Sing-box 核心成功准备完毕！")
        else:
            raise RuntimeError("解压失败，未找到 sing-box 主程序")
    else:
        print("[✓] Sing-box 核心文件状态正常")

def generate_config():
    """生成带 0-RTT 的 Sing-box 配置文件"""
    config = {
        "log": { "level": "info", "timestamp": True },
        "inbounds": [
            {
                "type": "vless",
                "tag": "vless-in",
                "listen": "0.0.0.0",
                "listen_port": PORT,
                "users": [
                    { "uuid": UUID, "flow": "" }
                ],
                "transport": {
                    "type": "ws",
                    "path": WS_PATH,
                    "max_early_data": 2048,
                    "early_data_header_name": "Sec-WebSocket-Protocol"
                }
            }
        ],
        "outbounds": [
            { "type": "direct", "tag": "direct" }
        ]
    }
    with open(CONFIG_PATH, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2)
    print(f"[✓] 配置文件生成完成 (监听端口: {PORT})")

def main():
    try:
        prepare_singbox()
        generate_config()

        print(f"[i] 正在启动 Sing-box 节点，监听端口: {PORT}...")
        process = subprocess.Popen(
            [SINGBOX_PATH, "run", "-c", CONFIG_PATH],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )

        vless_link = f"vless://{UUID}@{ENTRY_HOST}:443?type=ws&security=tls&sni={ENTRY_HOST}&host={TUNNEL_HOST}&path=%2Fvless%3Fed%3D2048#Back4App-Python-0RTT"

        time.sleep(1)
        print("\n==================================================")
        print("🎉 Back4App (Python) 节点部署上线成功！")
        print("--------------------------------------------------")
        print("📋 客户端导入节点链接：")
        print(vless_link)
        print("==================================================\n")

        # 实时打印日志
        for line in process.stdout:
            print(f"[Sing-box] {line.strip()}", flush=True)

    except Exception as e:
        print(f"[X] 运行出错: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()
