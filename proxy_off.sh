#!/bin/bash
# ═══════════════════════════════════════════
# GFW Bypass - 一键关闭代理
# ═══════════════════════════════════════════

SOCKS_PORT="${1:-20808}"

echo ">>> 关闭 macOS SOCKS 代理..."
networksetup -setsocksfirewallproxystate "Wi-Fi" off

echo ">>> 关闭 HTTP/HTTPS 代理（如果有）..."
networksetup -setwebproxystate "Wi-Fi" off 2>/dev/null
networksetup -setsecurewebproxystate "Wi-Fi" off 2>/dev/null

echo ">>> 移除 ADB 端口转发..."
adb forward --remove "tcp:${SOCKS_PORT}" 2>/dev/null

echo ""
echo "✅ 代理已全部关闭"
echo ""
echo "⚠️  检查: scutil --proxy | grep Enable (应该全是 0)"
