#!/bin/bash
# ═══════════════════════════════════════════
# GFW Bypass - 一键开启代理
# macOS + Android VPN (tomvpn/ssr) + ADB
# ═══════════════════════════════════════════

PHONE_IP="${1:-10.233.0.85:5555}"
SOCKS_PORT="${2:-20808}"
PHONE_PROXY_PORT="${3:-10808}"

echo ">>> 连接手机 ADB..."
adb connect "$PHONE_IP" 2>/dev/null
sleep 1

echo ">>> 设置端口转发 ${SOCKS_PORT} -> ${PHONE_PROXY_PORT}..."
adb forward "tcp:${SOCKS_PORT}" "tcp:${PHONE_PROXY_PORT}"

echo ">>> 开启 macOS SOCKS 代理..."
networksetup -setsocksfirewallproxy "Wi-Fi" 127.0.0.1 "$SOCKS_PORT"
networksetup -setsocksfirewallproxystate "Wi-Fi" on

echo ""
echo "✅ 翻墙成功！SOCKS5 代理: 127.0.0.1:${SOCKS_PORT}"
echo ""
echo "💡 使用方式:"
echo "   终端: export ALL_PROXY=socks5://127.0.0.1:${SOCKS_PORT}"
echo "   Chrome 类应用: 系统代理自动生效"
echo "   Electron 应用: ALL_PROXY=socks5://127.0.0.1:${SOCKS_PORT} open /Applications/App.app"
