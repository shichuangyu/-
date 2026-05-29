# 一键翻墙 🚀

> 一部安卓手机 + 免费 VPN = Mac + iPhone 全能翻墙
> AI 编程神器（OpenClaw / Hermes / Codex）从此不断线

## 🤔 能干嘛

**你只需要一部安卓手机，装个免费 VPN。**

然后这个东西能做到：

| 设备 | 效果 |
|------|------|
| 🖥️ **Mac** | Chrome / 终端 / VS Code 全走代理 |
| 🤖 **AI 编程工具** | OpenClaw、Hermes Agent 等短暂翻墙连 GitHub |
| 🍎 **iPhone** | 浏览器翻墙、刷国外 App（Twitter/Instagram/Discord 等） |
| 📦 **git clone** | 拉 GitHub 仓库不再卡 |

**原理很简单：** 手机 VPN → ADB 桥梁 → Mac 系统代理 → 所有设备共享。不需要电脑装 VPN，不需要买机场，一部安卓手机搞定一切。

---

## 📦 你需要什么

| 东西 | 说明 |
|------|------|
| 一台 Mac | macOS 任意版本 |
| 一部安卓手机 | 已装 VPN（ssr / v2ray / tomvpn / clash 都行） |
| 一根 USB 数据线 | **首次配置用**，之后可以无线 |
| 同一个网络 | Mac 连手机热点最稳 |

---

## 🔧 首次配置（第一次用必看，以后不用）

### 第一步：装 ADB

打开 Mac 的 **终端**（在 启动台 → 其他 → 终端），复制粘贴这行回车：

```bash
brew install android-platform-tools
```

如果提示 `brew: command not found`，先去 https://brew.sh 装 Homebrew。

装完后验证：

```bash
adb version
```

显示 `Android Debug Bridge version x.x.x` 就 OK。

---

### 第二步：手机开 USB 调试

1. 手机打开 **设置 → 关于手机**
2. 疯狂点 **"版本号"** 7 次，直到提示"已进入开发者模式"
3. 回到 **设置 → 系统 → 开发者选项**（不同手机位置略有不同）
4. 打开 **"USB 调试"** 开关
5. 打开 **"无线调试"** 或 **"网络 ADB 调试"**（如果有的话）

---

### 第三步：用 USB 线连上 Mac

1. 用数据线把手机插到 Mac
2. 手机屏幕会弹窗 **"允许 USB 调试吗？"** → 勾选 **"一律允许"** → 点 **确定**
3. 在 Mac 终端输入：

```bash
adb devices
```

你应该看到类似这样（有一串设备号 + `device`）：

```
List of devices attached
XXXXXXXX    device
```

如果显示 `unauthorized`，说明手机上没点允许。拔线重插，注意看手机弹窗。

---

### 第四步：开启无线 ADB（以后不用插线）

手机还插着线的时候，在终端输入：

```bash
adb tcpip 5555
```

显示 `restarting in TCP mode port: 5555` 就成功了。**现在可以拔掉 USB 线了。**

---

### 第五步：找到手机的 IP 地址

**方式 A — Mac 连手机热点（推荐）：**

手机开热点 → Mac 连上 → 手机 IP 固定是 `10.233.0.85`（tomvpn 默认）

**方式 B — 手机和 Mac 连同一个 Wi-Fi：**

手机：设置 → WLAN → 点你连的 Wi-Fi 名字 → 看 **IP 地址**（类似 `192.168.1.105`）

**方式 C — 安卓状态信息里查（最可靠）：**

设置 → 关于手机 → 状态信息 → 查看 **IP 地址**

记下这个 IP。

---

### 第六步：测试无线连接

```bash
adb connect 你的IP:5555
```

比如：

```bash
adb connect 10.233.0.85:5555
```

显示 `connected to 10.233.0.85:5555` 就 OK。

---

### 第七步：确认手机 VPN 端口

大部分 VPN 软件的代理端口是固定的：

| VPN 软件 | SOCKS 端口 | HTTP 端口 |
|----------|------------|-----------|
| tomvpn | 10808 | 10809 |
| ssr (ShadowsocksR) | 1080 | — |
| v2rayNG | 10808 | 10809 |
| Clash | 7890 | 7890 |

如果不确定，在终端跑这个看：

```bash
adb shell netstat -tlnp 2>/dev/null | grep -E "1080|10808|10809|7890"
```

---

✅ **首次配置完成！** 以后每次只需要：
1. 手机开 VPN
2. Mac 终端跑 `./proxy_on.sh`

---

## 🚀 日常使用

### 1. 开启代理

```bash
./proxy_on.sh
```

默认连 `10.233.0.85:5555`（手机热点 IP），SOCKS 端口 `20808`。

**如果你的配置不一样，可以传参数：**

```bash
./proxy_on.sh 手机IP:ADB端口 Mac代理端口 手机VPN端口
```

比如你的手机 IP 是 `192.168.1.100`，VPN SOCKS 端口是 `1080`：

```bash
./proxy_on.sh 192.168.1.100:5555 20808 1080
```

参数说明：
- 第1个：`手机IP:5555`（ADB 连接地址）
- 第2个：Mac 本地代理端口（默认 `20808`，不用改）
- 第3个：手机 VPN 的 SOCKS 端口（tomvpn 是 `10808`，ssr 是 `1080`）

成功后会显示：

```
✅ 翻墙成功！SOCKS5 代理: 127.0.0.1:20808
```

---

### 2. 各应用怎么走代理

**浏览器（Chrome / Safari / Edge）：** 不用管，自动走代理。

**终端（curl / wget / git clone）：** 需要手动设：

```bash
export ALL_PROXY=socks5://127.0.0.1:20808
```

这条命令只在**当前终端窗口**有效，关了就没。

**VS Code / Codex / ChatGPT 桌面版（Electron 应用）：**

这些应用不走系统代理，需要这样启动：

```bash
ALL_PROXY=socks5://127.0.0.1:20808 open /Applications/Codex.app
```

每次都要这样开。嫌麻烦可以写个 alias。

---

### 3. iPhone 也能翻 🍎

**前提：** iPhone 和 Mac 连同一个热点/Wi-Fi。

**Mac 上运行：**

```bash
./proxy_iphone.sh
```

脚本会显示类似：

```
✅ 中继已启动!

📱 iPhone 设置:
   Wi-Fi -> HTTP 代理 -> 手动
   服务器: 10.233.0.2
   端口:   10888

⚠️  iPhone 和 Mac 必须在同一 Wi-Fi/热点
```

---

**然后拿起 iPhone，按下面设置：**

> ⚠️ 服务器 IP **不要抄下面的例子！** 填脚本运行时显示的实际 IP，每个人不一样。

1. 打开 **「设置」** → 点 **「无线局域网」（Wi-Fi）**
2. 找到你正连着的 Wi-Fi 名字 → 点右边的 **蓝色 ⓘ（感叹号）**
3. 往下滑到底 → 点 **「HTTP 代理」**
4. 选 **「手动」** → 填写：

| 设置项 | 填什么 |
|--------|--------|
| **服务器** | **脚本显示的 IP**（比如你的是 `10.233.0.2`） |
| **端口** | `10888` |
| **鉴定** | **关掉**（不需要） |

5. 点右上角 **「存储」** → 返回即可

搞定！现在 iPhone 所有流量都走手机 VPN 了。

**不用了记得关：**
- iPhone：回到 HTTP 代理设置，选 **"关闭"** → 存储
- Mac：按 `Ctrl + C` 停止 proxy_iphone.sh

---

### 4. 关闭所有代理 🔴

```bash
./proxy_off.sh
```

⚠️ **用完一定要关！** 不然 VPN 一断，Mac 就断网了。关不掉的时候手动检查：

```bash
scutil --proxy | grep Enable
```

所有 `Enable` 都应该是 `0`。如果不全是 0，说明还有代理没关掉。

---

## 🔧 原理

```
手机 VPN (ssr/v2ray)
    ↓
手机本地代理 (127.0.0.1:10808 SOCKS / 10809 HTTP)
    ↓ ADB forward
Mac 本地端口 (127.0.0.1:20808)
    ↓ macOS 系统代理
所有 Mac 应用 → 走手机 VPN → 翻墙成功
    ↓ HTTP 中继 (port 10888)
iPhone → Mac → 手机 VPN → 翻墙
```

---

## ❓ 常见问题

**Q: `adb connect` 连不上？**

```bash
# 先杀掉 adb 重启
adb kill-server && adb start-server
# 再连
adb connect 手机IP:5555
```

还不行的话，检查：
- 手机和 Mac 在同一个网络吗？
- 手机 VPN 在运行吗？（部分 VPN 会改网络规则）
- USB 插上再试试 `adb devices`

---

**Q: `./proxy_on.sh` 报 `adb: command not found`？**

你没装 ADB。回头看 **首次配置 → 第一步**。

---

**Q: Chrome 能翻但终端 curl 不行？**

正常现象。终端不走系统代理，需要手动设：

```bash
export ALL_PROXY=socks5://127.0.0.1:20808
```

---

**Q: 代理开着突然上不了网？**

手机 VPN 断了。先跑 `./proxy_off.sh` 关代理，重连 VPN 再开。

---

**Q: 我的 VPN 端口不是 10808？**

传第三个参数：

```bash
./proxy_on.sh 10.233.0.85:5555 20808 你的端口
```

---

**Q: iPhone 设了代理但上不了网？**

检查：
1. iPhone 和 Mac 在同一个 Wi-Fi/热点吗？
2. Mac 上 `proxy_iphone.sh` 还在运行吗？（没被 Ctrl+C 关掉吧？）
3. 服务器 IP 填对了吗？（填脚本显示的，不要复制别人的）
4. Mac 的防火墙关了吗？（系统设置 → 网络 → 防火墙 → 关闭）

---

## ⭐ 如果对你有用

点个星标呗，让更多需要的人看到。
