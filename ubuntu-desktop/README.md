# 🐧 Ubuntu Desktop for Android

> Full Ubuntu 24.04 LTS desktop environment running on Android via Termux + proot-distro.

---

## Overview

This project installs a complete Ubuntu 24.04 LTS graphical desktop on any Android device using Termux. It uses **proot-distro** to run a real Ubuntu environment inside a container and **Termux-X11** as the display server, with GPU acceleration, sound, and Windows app support via Wine.

**No hacking tools included** — this is a clean productivity and development environment.

---

## Requirements

| Item | Minimum |
|------|---------|
| Android version | 8.0+ |
| RAM | 3 GB free |
| Storage | 8 GB free |
| Internet | Stable connection (~1 GB download) |
| App | [Termux (F-Droid)](https://f-droid.org/packages/com.termux/) |
| App | [Termux-X11 (GitHub)](https://github.com/termux/termux-x11/releases) |

> **Important:** Install Termux from **F-Droid**, not the Play Store. The Play Store version is outdated and will not work.

---

## Installation

Run this one-liner in Termux:

```bash
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/ubuntu-desktop/install.sh | bash
```

The installer will:
1. Install Termux host packages (X11, PulseAudio, Mesa, GPU drivers, Wine)
2. Download and configure the Ubuntu 24.04 LTS rootfs via proot-distro
3. Install XFCE4 desktop, Firefox, VS Code, Python, OpenSSH, Bluetooth inside Ubuntu
4. Create the `~/start-ubuntu.sh` and `~/stop-ubuntu.sh` launchers in Termux

Estimated time: **25–45 minutes** depending on internet speed and device.

---

## Starting the Desktop

### Step 1 — Open Termux-X11
Launch the **Termux-X11** app on your Android device. You can leave it in the background.

### Step 2 — Run the launcher in Termux
```bash
bash ~/start-ubuntu.sh
```

### Step 3 — Switch to Termux-X11
Tap the **Termux-X11** app icon. The XFCE4 desktop will appear.

---

## Stopping the Desktop

```bash
bash ~/stop-ubuntu.sh
```

This gracefully terminates XFCE4, PulseAudio, and the X11 server.

---

## Ubuntu Shell (CLI only)

To enter the Ubuntu environment without starting the graphical desktop:

```bash
proot-distro login ubuntu
```

From here you can use `apt`, run Python scripts, use SSH, etc.

---

## Included Software

### Inside Ubuntu (proot)
| Software | Description |
|----------|-------------|
| **XFCE4** | Lightweight desktop (xfce4-session, xfwm4, xfdesktop4, xfce4-panel) |
| **xfce4-terminal** | Built-in terminal |
| **Thunar** | Graphical file manager |
| **Mousepad** | Text editor |
| **Firefox** | Web browser |
| **VS Code** | Code editor (Microsoft ARM64 official build) |
| **Python 3** | Python + pip + venv |
| **OpenSSH** | SSH server (port 2222) |
| **Bluetooth** | bluez + blueman GUI manager |
| **Git, curl, unzip** | Development essentials |

### In Termux (host)
| Software | Description |
|----------|-------------|
| **Termux-X11** | X11 display server for Android |
| **PulseAudio** | Sound server, TCP mode on 127.0.0.1 |
| **Mesa Zink** | OpenGL over Vulkan |
| **Turnip / swrast** | Vulkan driver — Turnip for Adreno, swrast for everything else |
| **Wine/Hangover** | Run Windows `.exe` applications |

---

## Running Windows Apps (.exe)

Wine is installed in the Termux host. To run a Windows application, open a **Termux** terminal (not the Ubuntu terminal) and run:

```bash
wine /path/to/application.exe
winecfg    # Wine configuration GUI
```

> **Note:** Wine/Hangover on ARM supports many 64-bit Windows applications. 32-bit support may require additional configuration.

---

## OpenSSH — Connect via SSH

Inside Ubuntu, start the SSH server and connect from another device on the same Wi-Fi:

```bash
# Inside Ubuntu (proot-distro login ubuntu):
service ssh start

# From another device on the same network:
ssh root@<android-ip> -p 2222
```

Find your Android IP:
```bash
ip addr show wlan0 | grep "inet "
```

---

## VS Code

Launch from a terminal inside Ubuntu:

```bash
code --no-sandbox
```

> The `--no-sandbox` flag is required — VS Code's sandbox is incompatible with proot environments.

---

## GPU Acceleration

GPU acceleration is configured automatically at install time:

| GPU | Driver | Status |
|-----|--------|--------|
| Adreno (Qualcomm Snapdragon) | Turnip (freedreno) | Full hardware acceleration |
| Mali / PowerVR / other | swrast | Software rendering |

Detection reads `ro.hardware.egl` from Android system properties directly. The GPU environment variables are saved to `~/.config/ubuntu-desktop-gpu.sh` and loaded automatically by `start-ubuntu.sh`.

To check your active renderer:
```bash
# In a Termux terminal with DISPLAY=:1 set
glxinfo | grep "renderer"
```

---

## Bluetooth

Bluetooth hardware access from within a proot container depends on Android's Bluetooth stack:

1. Open **Blueman Manager** from the XFCE4 desktop.
2. If devices are not detected, start the service first:
   ```bash
   # Inside Ubuntu:
   service bluetooth start
   ```
3. On some devices, host-level Bluetooth access may be limited by Android permissions.

---

## Architecture

Understanding how the pieces fit together:

```
Android
└── Termux (host, no root needed)
    ├── termux-x11 :1          ← X11 display server
    │   └── socket: $TMPDIR/.X11-unix/X1
    ├── pulseaudio (TCP :4713) ← Sound server
    ├── mesa / turnip          ← GPU drivers
    ├── wine/hangover          ← Windows app layer
    │
    └── proot-distro login ubuntu
        │   --bind $TMPDIR/.X11-unix:/tmp/.X11-unix
        │
        └── Ubuntu 24.04 LTS (proot container)
            ├── /etc/machine-id       ← Generated by dbus-uuidgen at install
            ├── dbus-run-session      ← D-Bus session bus
            └── xfce4-session         ← XFCE4 desktop (DISPLAY=:1)
```

**Key design decisions:**

- **proot-distro** runs Ubuntu without root by intercepting syscalls. No kernel modifications needed.
- **X11 socket bind-mount**: Termux-X11 creates its socket at `$TMPDIR/.X11-unix/X1`. Without `--bind`, proot's `/tmp` has no X11 sockets and `DISPLAY=:1` cannot connect. The bind-mount makes the socket visible at `/tmp/.X11-unix/X1` inside the container.
- **dbus-run-session** instead of `dbus-launch`: starts dbus-daemon and passes its address to the child without shell variable pollution from `bash --login` init scripts.
- **Standalone startup script** (`/usr/local/bin/ubuntu-desktop-start.sh`): called directly via `proot-distro login ubuntu -- /script.sh`. This avoids bash `--login` mode sourcing `/etc/profile.d/` files that could interfere with `DISPLAY` before xfce4-session starts.
- **policy-rc.d returning 101**: blocks `invoke-rc.d` during `apt-get install`, preventing dpkg post-install scripts from trying to start system services (which would hang indefinitely in proot — no init daemon running).
- **D-Bus machine-id**: `base-files` creates `/etc/machine-id` empty; `systemd` normally fills it on first boot, but systemd never runs in proot. Generated explicitly with `dbus-uuidgen` during install.
- **No `--shared-tmp`**: sharing Termux's `$TMPDIR` as Ubuntu's `/tmp` caused permission errors because `apt` modifies `$TMPDIR` permissions during package installation. Setup scripts are instead written to `$UBUNTU_ROOTFS/tmp/` (inside the Ubuntu filesystem tree) and the X11 socket is bind-mounted selectively.

---

## File Structure

```
ubuntu-desktop/
├── install.sh      — Main installer
├── uninstall.sh    — Complete removal script
└── README.md       — This file

Generated by install.sh (in Termux home):
~/start-ubuntu.sh                           — Start the desktop
~/stop-ubuntu.sh                            — Stop the desktop
~/.config/ubuntu-desktop-gpu.sh            — GPU environment variables

Generated inside Ubuntu rootfs:
/usr/local/bin/ubuntu-desktop-start.sh     — XFCE4 startup script (dbus + xfce4-session)
```

---

## Troubleshooting

### Black screen in Termux-X11
Make sure Termux-X11 is open **before** running `start-ubuntu.sh`. If the screen is black, stop and restart:
```bash
bash ~/stop-ubuntu.sh && bash ~/start-ubuntu.sh
```

### `Cannot open display: .` — XFCE4 won't start
This means the X11 unix socket is not accessible inside proot. Verify that `start-ubuntu.sh` includes the `--bind` flag:
```bash
grep "bind" ~/start-ubuntu.sh
# Should show: --bind "$TMPDIR/.X11-unix:/tmp/.X11-unix"
```
If missing, re-run the installer or run:
```bash
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/ubuntu-desktop/install.sh | bash
```

### `dbus-daemon: Failed to set fd limit` warning
This warning appears in Android proot environments because `setrlimit(RLIMIT_NOFILE)` is restricted. It is non-fatal — dbus-daemon continues running normally. You can safely ignore it.

### No sound
PulseAudio starts automatically. If audio is missing:
```bash
pulseaudio --kill && pulseaudio --start --exit-idle-time=-1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1
```

### XFCE4 crashes on launch
Check the session log:
```bash
cat ~/.xsession-errors
```
Reinstall the desktop packages inside Ubuntu:
```bash
proot-distro login ubuntu -- apt install --reinstall xfce4-session xfwm4 xfce4-panel xfdesktop4 -y
```

### VS Code GPG conflict on re-install
This happens when running the installer a second time and old keyring files conflict. The installer handles this automatically by removing old keyring files before re-adding them. If you see this error manually:
```bash
# Inside Ubuntu:
rm -f /usr/share/keyrings/microsoft*.gpg /etc/apt/sources.list.d/vscode.list*
apt-get update
apt-get install code
```

### Installation hangs at 50% during apt
This is caused by dpkg post-install scripts trying to start services (which requires an init system not present in proot). The installer installs a `policy-rc.d` that prevents this. If you encounter it in a manual install, create:
```bash
# Inside Ubuntu:
echo '#!/bin/sh
exit 101' > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
```

### Out of storage during install
Free at least **8 GB** before starting. The Ubuntu rootfs uses ~3–5 GB after packages are installed. Check available space:
```bash
df -h $PREFIX
```

---

## Uninstallation

```bash
curl -sL https://raw.githubusercontent.com/rafaeldipre/termux-android-lab/main/ubuntu-desktop/uninstall.sh | bash
```

Type `yes` when prompted. This removes:
- The Ubuntu 24.04 rootfs (~3–5 GB)
- All launcher scripts and GPU config
- All Termux host packages (mesa, vulkan, pulseaudio, wine, termux-x11…)
- The GPU env entry from `~/.bashrc`

> **Warning:** All files stored inside Ubuntu will be permanently deleted.

---

## Author

**Tech Jarves** — [youtube.com/@TechJarves](https://youtube.com/@TechJarves)
