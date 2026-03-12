# 📱 Termux Android Lab

> Two ready-to-run desktop environments for Android — a full **Ubuntu 24.04 LTS** workspace and a **Mobile HackLab** — both powered by Termux + Termux-X11.

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
| **Authorship** | 🆕 Original | 🔧 Fork + hardened |

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

> **Original project** by [@rafaeldipre](https://github.com/rafaeldipre), developed in collaboration with Claude (Anthropic).

A clean, productivity-focused Ubuntu 24.04 LTS environment for development and daily use on Android. Runs Ubuntu inside a proot container managed by proot-distro, with XFCE4 as the graphical desktop.

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

> **Based on** [jarvesusaram99/termux-hacklab](https://github.com/jarvesusaram99/termux-hacklab) by [@jarvesusaram99](https://github.com/jarvesusaram99) — original concept and structure.
> **Modified and hardened** by [@rafaeldipre](https://github.com/rafaeldipre). See [changes](#-changes-from-the-original) below.

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
1) Nmap       — network scan     (input validated: alphanum/dots/dashes only)
2) SQLMap     — SQL injection     (URL validated: must start with http/https)
3) Hydra      — credential test  (manual mode, shows usage example)
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

## 🐧 Ubuntu Desktop — Engineering Notes

This section documents the non-obvious technical problems solved during development. Useful if you're building something similar or want to understand why the installer does what it does.

### Bugs fixed

| # | Symptom | Root cause | Fix |
|---|---------|-----------|-----|
| 1 | `apt` hangs at ~50% during XFCE4 install | `dpkg` post-install scripts call `invoke-rc.d` to start services; no init system in proot → infinite wait | Added `/usr/sbin/policy-rc.d` returning `101` before any `apt-get` call |
| 2 | `Permission denied` on `/tmp` for Firefox, VS Code, SSH, Bluetooth | Setup scripts were written to Android's `/tmp`; after `apt` modifies `$TMPDIR` permissions the path became inaccessible | Removed `--shared-tmp`; setup scripts written to `$UBUNTU_ROOTFS/tmp/` instead |
| 3 | `xfce4-session: Cannot open display: .` (D-Bus error) | `/etc/machine-id` created empty by `base-files`; `systemd` fills it on first boot but never runs in proot; `dbus-daemon` aborts without a valid UUID | Added `dbus-uuidgen > /etc/machine-id` in base setup after `dbus-x11` install |
| 4 | `xfce4-session: Cannot open display: .` (env corruption) | `proot-distro login ubuntu -- bash --login -c '...'` sources `/etc/profile.d/` login scripts that can overwrite `DISPLAY` before `dbus-launch` passes env to `xfce4-session` | Replaced inline command with a standalone script at `/usr/local/bin/ubuntu-desktop-start.sh`; called as `proot-distro login ubuntu -- /script.sh` (no login shell) |
| 5 | `xfce4-session: Cannot open display: .` (socket missing) | Termux-X11 creates its unix socket at `$TMPDIR/.X11-unix/X1`; without `--shared-tmp` proot's `/tmp` has no X11 sockets so `DISPLAY=:1` cannot connect | Added `--bind $TMPDIR/.X11-unix:/tmp/.X11-unix` to the `proot-distro login` call |
| 6 | VS Code `gpg` conflict on re-install | Second install finds both `microsoft-archive-keyring.gpg` and `microsoft.gpg`; `apt` refuses conflicting signed-by values | Idempotency check (`command -v code`); clean all conflicting keyring/source files before re-adding; `gpg --batch --yes` |

### Key architectural constraints

- **No `--shared-tmp`** — sharing Termux's `$TMPDIR` as Ubuntu's `/tmp` breaks when `apt` changes tmpdir permissions mid-install. X11 socket access is solved with a targeted `--bind` instead.
- **`policy-rc.d` is mandatory** — without it, every package that ships a systemd service (dbus, bluetooth, ssh, …) will attempt a service start via `invoke-rc.d` and hang forever.
- **`dbus-run-session` over `dbus-launch`** — `dbus-launch --exit-with-session` forks `xfce4-session` which inherits a potentially polluted environment from the login shell. `dbus-run-session` execs the child directly with a clean environment.
- **machine-id must be generated at install time** — dbus-daemon refuses to start with an empty `/etc/machine-id`.

---

## 🔧 Changes from the Original

The following modifications were applied to [jarvesusaram99/termux-hacklab](https://github.com/jarvesusaram99/termux-hacklab):

### Bug fixes
| # | Location | Problem | Fix |
|---|----------|---------|-----|
| 1 | `show_banner()` | Orphaned `BANNER` delimiter after heredoc caused syntax error | Removed duplicate line |
| 2 | `spinner()` | Race condition — spinner never showed if process finished before first loop iteration | Added initial `printf` before the `while` loop |
| 3 | `install_pkg()` | `$pkg` and `$!` unquoted — word-splitting risk | Added double-quotes around all variables |
| 4 | `step_metasploit` | Function called in `main()` but never defined — fatal crash | Implemented `step_metasploit()` with `install_pkg "metasploit"` |

### Security hardening
| # | Location | Problem | Fix |
|---|----------|---------|-----|
| 5 | `detect_device()` | GPU driver selected by device brand (Samsung → Adreno assumed) — wrong for Mali devices | Detection now uses only `ro.hardware.egl` hardware property |
| 6 | `hacktools.sh` → option 1 | `nmap -sV $target` — unquoted, unsanitized user input allows command injection | Input validated with regex `^[a-zA-Z0-9._/-]+$` before use |
| 7 | `hacktools.sh` → option 2 | `sqlmap -u "$url" --batch` — no URL validation; `--batch` skips all user confirmations | Added `^https?://` regex check; removed `--batch` flag |
| 8 | `start-hacklab.sh` | `auth-anonymous=1` in PulseAudio TCP module — allows unauthenticated audio connections | Removed `auth-anonymous=1`; keeps `auth-ip-acl=127.0.0.1` |
| 9 | `start/stop-hacklab.sh` | `pkill -9` used as first signal — processes have no chance to clean up | Changed to SIGTERM → `sleep 1` → SIGKILL in both scripts |
| 10 | `step_wine()` | `ln -sf` ran unconditionally — creates broken symlinks if installation failed | Added `[ -f "$wine_bin" ]` existence check before linking |
| 11 | `step_launchers()` | `MESA_NO_ERROR=1` in GPU config silently disabled all OpenGL error reporting | Variable removed from config |
| 12 | `start-hacklab.sh` | `exec startxfce4` — if XFCE4 crashes nothing runs after it, no error message shown | Replaced with `startxfce4 \|\| echo "⚠ XFCE4 exited..."` |

---

## 🎮 GPU Acceleration

Both versions automatically detect your GPU at install time:

| GPU | Driver | Result |
|-----|--------|--------|
| Adreno (Qualcomm Snapdragon) | Turnip / freedreno | Full hardware acceleration |
| Mali / PowerVR / other | swrast | Software rendering |

Detection reads the Android system property `ro.hardware.egl` directly — no brand-based guessing.

---

## 📁 Repository Structure

```
termux-android-lab/
│
├── README.md               ← You are here
├── LICENSE
├── install.sh              ← HackLab installer  (fork of jarvesusaram99)
├── uninstall.sh            ← HackLab uninstaller
│
└── ubuntu-desktop/
    ├── install.sh          ← Ubuntu Desktop installer  (original)
    ├── uninstall.sh        ← Ubuntu Desktop uninstaller
    └── README.md           ← Ubuntu Desktop documentation
```

---

## 🔒 Security Notes (applied to both versions)

- **No command injection** — user inputs (IPs, URLs) are validated with regex before being passed to tools
- **No anonymous audio** — PulseAudio TCP restricted to `127.0.0.1`, no `auth-anonymous`
- **Graceful process shutdown** — SIGTERM first, SIGKILL only after a 1-second grace period
- **Symlinks verified** — Wine symlinks created only if the binary actually exists
- **No `MESA_NO_ERROR`** — OpenGL error checking kept active for diagnostics
- **Quoted variables** — all shell variables are properly quoted throughout

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first.

---

## 📺 Credits

| Project | Author | Role |
|---------|--------|------|
| [termux-hacklab](https://github.com/jarvesusaram99/termux-hacklab) | [@jarvesusaram99](https://github.com/jarvesusaram99) | Original HackLab concept and script |
| Ubuntu Desktop | [@rafaeldipre](https://github.com/rafaeldipre) + Claude (Anthropic) | Original work |
| Security hardening & fork | [@rafaeldipre](https://github.com/rafaeldipre) | Bug fixes + vulnerability patches on HackLab |

**Tech Jarves** — [youtube.com/@TechJarves](https://youtube.com/@TechJarves)

---

## ⚖️ License

MIT — see [LICENSE](LICENSE) for details.
