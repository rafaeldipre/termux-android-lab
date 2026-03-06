# 📱 Termux Android Lab

> Two ready-to-run desktop environments for Android — a full **Ubuntu 24.04 LTS** workspace and a **Mobile HackLab** — both powered by Termux + proot-distro + Termux-X11.

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%208%2B-green.svg)]()
[![Termux](https://img.shields.io/badge/Requires-Termux%20F--Droid-blue.svg)](https://f-droid.org/packages/com.termux/)

</div>

---

## 📦 Available Versions

| Feature | 🐧 Ubuntu Desktop | 🔴 Mobile HackLab |
|---------|:-----------------:|:-----------------:|
| Ubuntu 24.04 LTS (proot) | ✅ | ❌ |
| XFCE4 Desktop | ✅ | ✅ |
| GPU Acceleration | ✅ | ✅ |
| PulseAudio (sound) | ✅ | ✅ |
| Firefox | ✅ | ✅ |
| VS Code | ✅ | ✅ |
| Python 3 + pip | ✅ | ✅ |
| Wine / Hangover (.exe) | ✅ | ✅ |
| OpenSSH server | ✅ | ❌ |
| Bluetooth (bluez) | ✅ | ❌ |
| Thunar File Manager | ✅ | ✅ |
| Nmap, Hydra, SQLMap | ❌ | ✅ |
| John the Ripper | ❌ | ✅ |
| Metasploit Framework | ❌ | ✅ |
| Hacking tools menu | ❌ | ✅ |
| Intended use | 🛠 Development | 🔒 Security research |

---

## ⚡ Quick Install (one-line)

> Requires **Termux from F-Droid** and the **Termux-X11** app installed before running.

### 🐧 Ubuntu Desktop

```bash
# Install
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/ubuntu-desktop/install.sh | bash
```

```bash
# Uninstall
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/ubuntu-desktop/uninstall.sh | bash
```

### 🔴 Mobile HackLab

```bash
# Install
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/install.sh | bash
```

```bash
# Uninstall
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/uninstall.sh | bash
```

---

## 📋 Requirements (both versions)

| Item | Minimum |
|------|---------|
| Android | 8.0+ |
| RAM | 3 GB free |
| Storage | 8 GB free (Ubuntu) / 4 GB (HackLab) |
| Internet | Stable — downloads 500 MB–1 GB |
| App | [Termux via F-Droid](https://f-droid.org/packages/com.termux/) |
| App | [Termux-X11 via GitHub](https://github.com/termux/termux-x11/releases) |

> ⚠️ **Do NOT use the Play Store version of Termux** — it is outdated and incompatible with these scripts.

---

## 🐧 Ubuntu Desktop

A clean, productivity-focused Ubuntu 24.04 LTS environment for development and daily use on Android.

### What gets installed

**Inside Ubuntu (proot):**
- XFCE4 desktop + xfce4-terminal
- Thunar file manager + Mousepad editor
- Firefox browser
- VS Code (Microsoft official ARM64 build)
- Python 3 + pip + venv
- OpenSSH server (port 2222)
- Bluetooth (bluez + blueman)

**In Termux (host):**
- Termux-X11 display server
- PulseAudio (sound)
- GPU drivers — Turnip (Adreno) or swrast (other)
- Wine/Hangover (run `.exe` apps)

### Installation

```bash
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/ubuntu-desktop/install.sh | bash
```

Estimated time: **25–45 minutes** depending on internet speed.

### Usage

```bash
# 1. Open the Termux-X11 app on your device
# 2. In Termux, start the desktop:
bash ~/start-ubuntu.sh

# Open a Ubuntu shell (CLI only):
proot-distro login ubuntu

# Stop the desktop:
bash ~/stop-ubuntu.sh
```

### OpenSSH

```bash
# Inside Ubuntu:
service ssh start

# Connect from another device on the same Wi-Fi:
ssh root@<android-ip> -p 2222
```

### Running .exe apps (Wine)

```bash
wine /path/to/application.exe
winecfg    # Wine configuration GUI
```

### Uninstall

```bash
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/ubuntu-desktop/uninstall.sh | bash
```

> Type `yes` when prompted. Removes Ubuntu rootfs (~3–5 GB), all packages, scripts, and restores `~/.bashrc`.

---

## 🔴 Mobile HackLab

A security research and penetration testing environment running directly in Termux (no proot needed).

> ⚠️ **For educational and authorized security testing only.** Always obtain explicit permission before testing systems you do not own.

### What gets installed

**Desktop & apps:**
- XFCE4 desktop via Termux-X11
- Firefox, VS Code, Git, wget, cURL
- Thunar file manager
- GPU acceleration (Turnip/Zink)
- PulseAudio (sound)
- Wine/Hangover (.exe support)

**Security & network tools:**
- Nmap (network scanning)
- Netcat, Whois, DNS utils, Tracepath
- Hydra (credential testing)
- John the Ripper (password analysis)
- SQLMap (SQL injection testing)
- Metasploit Framework

**Launcher:**
- `~/start-hacklab.sh` — start the desktop
- `~/stop-hacklab.sh` — stop the desktop
- `~/hacktools.sh` — interactive tools menu (includes input validation)

### Installation

```bash
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/install.sh | bash
```

Estimated time: **15–30 minutes** depending on internet speed.

### Usage

```bash
# 1. Open the Termux-X11 app on your device
# 2. In Termux, start the desktop:
bash ~/start-hacklab.sh

# Quick tools menu:
bash ~/hacktools.sh

# Stop the desktop:
bash ~/stop-hacklab.sh
```

### Quick tools menu options

```
1) Nmap     — network scan (with input validation)
2) SQLMap   — SQL injection test (URL validated, no auto-batch)
3) Hydra    — credential attack (manual mode)
4) Metasploit — msfconsole
5) Start Desktop
6) Check GPU status
```

### Uninstall

```bash
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/uninstall.sh | bash
```

> Type `yes` when prompted. Removes all packages, tools, scripts, and restores `~/.bashrc`.

---

## 🎮 GPU Acceleration

Both versions automatically detect your GPU at install time:

| GPU | Driver | Result |
|-----|--------|--------|
| Adreno (Qualcomm Snapdragon) | Turnip / freedreno | Full hardware acceleration |
| Mali / PowerVR / other | swrast | Software rendering |

Detection uses the Android system property `ro.hardware.egl` — no brand-based guessing.

---

## 📁 Repository Structure

```
termux-android-lab/
│
├── README.md               ← You are here
├── install.sh              ← HackLab installer
├── uninstall.sh            ← HackLab uninstaller
│
└── ubuntu-desktop/
    ├── install.sh          ← Ubuntu Desktop installer
    ├── uninstall.sh        ← Ubuntu Desktop uninstaller
    └── README.md           ← Ubuntu Desktop documentation
```

---

## 🔒 Security Notes

Both scripts were reviewed and hardened:

- **No command injection** — all user inputs (IPs, URLs) are validated with regex before being passed to tools
- **No anonymous audio** — PulseAudio TCP restricted to `127.0.0.1` without `auth-anonymous`
- **Graceful process shutdown** — SIGTERM first, then SIGKILL after a 1-second wait
- **Symlinks verified** — Wine symlinks are only created if the binary actually exists
- **No `MESA_NO_ERROR`** — OpenGL error checking is preserved for diagnostics
- **Quoted variables** — all shell variables are properly quoted throughout

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first.

---

## 📺 Author

**Tech Jarves** — [youtube.com/@TechJarves](https://youtube.com/@TechJarves)

---

## ⚖️ License

MIT — see [LICENSE](LICENSE) for details.
