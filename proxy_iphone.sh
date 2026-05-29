#!/bin/bash
# ═══════════════════════════════════════════
# GFW Bypass - iPhone HTTP 中继
# 让 iPhone 通过 Mac 代理翻墙
# ═══════════════════════════════════════════

IPHONE_RELAY_PORT="${1:-10888}"
PHONE_HTTP_PROXY="${2:-10809}"
ADB_FORWARD_PORT="20809"

echo ">>> 检查手机 HTTP 代理端口..."
# 先确认手机有 HTTP 代理（tomvpn 通常同时开 SOCKS 10808 + HTTP 10809）
adb forward "tcp:${ADB_FORWARD_PORT}" "tcp:${PHONE_HTTP_PROXY}"

echo ">>> 启动 HTTP 中继 (0.0.0.0:${IPHONE_RELAY_PORT} -> 手机:${PHONE_HTTP_PROXY})..."

cat > /tmp/proxy_relay.py << 'PYEOF'
import socket, threading, sys

LISTEN = ('0.0.0.0', int(sys.argv[1]))
TARGET = ('127.0.0.1', int(sys.argv[2]))

def relay(src, dst):
    try:
        while True:
            data = src.recv(4096)
            if not data: break
            dst.sendall(data)
    except: pass
    finally:
        try: src.close()
        except: pass
        try: dst.close()
        except: pass

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(LISTEN)
s.listen(10)
print(f"HTTP Relay: {LISTEN[0]}:{LISTEN[1]} -> {TARGET[0]}:{TARGET[1]}")

while True:
    client, addr = s.accept()
    target = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    target.connect(TARGET)
    t1 = threading.Thread(target=relay, args=(client, target), daemon=True)
    t2 = threading.Thread(target=relay, args=(target, client), daemon=True)
    t1.start(); t2.start()
PYEOF

MAC_IP=$(ifconfig en0 2>/dev/null | grep "inet " | awk '{print $2}')
echo ""
echo "═══════════════════════════════════"
echo "  ✅ HTTP 中继已启动!"
echo "═══════════════════════════════════"
echo ""
echo "📱 现在拿起 iPhone，按下面操作："
echo ""
echo "  1. 设置 → 无线局域网"
echo "  2. 点 Wi-Fi 名字右边的 ⓘ"
echo "  3. 滑到底 → HTTP 代理 → 手动"
echo "  4. 填写："
echo ""
echo "     ┌─────────────────────────┐"
echo "     │ 服务器   ${MAC_IP}"
echo "     │ 端口      ${IPHONE_RELAY_PORT}"
echo "     │ 鉴定     ❌ 关掉          │"
echo "     └─────────────────────────┘"
echo ""
echo "  5. 点右上角「存储」"
echo ""
echo "⚠️  iPhone 和 Mac 必须在同一 Wi-Fi/热点"
echo "⚠️  不用了记得回来把 HTTP 代理改回「关闭」"
echo "⚠️  关代理前先 Ctrl+C 停止本脚本"

python3 /tmp/proxy_relay.py "$IPHONE_RELAY_PORT" "$ADB_FORWARD_PORT"
