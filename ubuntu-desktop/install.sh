#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  🐧 UBUNTU DESKTOP - Installer v1.0
#
#  Installs a full Ubuntu 24.04 desktop on Android
#  via Termux + proot-distro. No hacking tools.
#
#  Includes:
#  - Ubuntu 24.04 LTS (proot-distro)
#  - XFCE4 desktop + Termux-X11 display server
#  - GPU acceleration (Turnip/Zink)
#  - VS Code, Python 3, Firefox
#  - Wine/Hangover (run .exe apps)
#  - PulseAudio (sound)
#  - Bluetooth (bluez + blueman)
#  - OpenSSH server
#  - Thunar file manager
#
#  Author: Tech Jarves
#  YouTube: https://youtube.com/@TechJarves
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=10
CURRENT_STEP=0
GPU_DRIVER="swrast"   # set in step_gpu_wine

# Termux prefix and Ubuntu rootfs paths (used to write setup scripts directly
# into the Ubuntu container's filesystem — avoids ALL /tmp permission issues)
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
UBUNTU_ROOTFS="${PREFIX}/var/lib/proot-distro/installed-rootfs/ubuntu"
INSTALL_LOG="${HOME}/.ubuntu_install.log"

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ============== PROGRESS ==============
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    FILLED=$((PERCENT / 5))
    EMPTY=$((20 - FILLED))

    BAR="${GREEN}"
    for ((i=0; i<FILLED; i++)); do BAR+="█"; done
    BAR+="${GRAY}"
    for ((i=0; i<EMPTY; i++)); do BAR+="░"; done
    BAR+="${NC}"

    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📊 PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============== SPINNER ==============
spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    printf "\r  ${YELLOW}⏳${NC} ${message} ${CYAN}${spin:0:1}${NC}  "
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r  ${YELLOW}⏳${NC} ${message} ${CYAN}${spin:$i:1}${NC}  "
        sleep 0.1
    done

    wait "$pid"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} ${message}                    \n"
    else
        printf "\r  ${RED}✗${NC} ${message} ${RED}(failed)${NC}     \n"
    fi

    return $exit_code
}

# ============== HELPERS ==============
install_pkg() {
    local pkg=$1
    local name="${2:-$pkg}"
    (yes | pkg install "$pkg" -y > /dev/null 2>&1) &
    spinner "$!" "Installing ${name}..."
}

# Run a script file inside Ubuntu proot (script_file is the Ubuntu-side path)
ubuntu_run() {
    local script_file=$1
    proot-distro login ubuntu -- bash "$script_file"
}

# Run a setup script inside Ubuntu proot with a spinner.
#
# WHY NO --shared-tmp:
#   proot --shared-tmp binds Termux's $TMPDIR as Ubuntu's /tmp.
#   When apt runs inside Ubuntu as root it can chmod/chown that dir, which then
#   blocks the HOST Termux process from writing new files to the host /tmp.
#   Writing scripts directly to ${UBUNTU_ROOTFS}/tmp/ avoids the issue entirely:
#   those files appear at /tmp/ inside proot without any bind-mount at all.
#
# HOW IT WORKS:
#   Caller creates the script at  ${UBUNTU_ROOTFS}/tmp/setup.sh  (host path)
#   ubuntu_cmd is called with     /tmp/setup.sh                  (Ubuntu path)
#   proot sees the file via its native rootfs — no shared-tmp needed.
#   Log lives in $HOME (guaranteed writable by the Termux user).
ubuntu_cmd() {
    local message=$1
    local script_file=$2          # path INSIDE Ubuntu (e.g. /tmp/ubuntu_base_setup.sh)
    local log="${INSTALL_LOG}"
    (proot-distro login ubuntu -- bash "$script_file" >> "$log" 2>&1) &
    spinner "$!" "$message"
    local result=$?
    if [ $result -ne 0 ]; then
        echo -e "  ${YELLOW}⚠${NC} Step failed. Last log output:"
        tail -5 "$log" 2>/dev/null | while IFS= read -r line; do
            echo -e "    ${GRAY}${line}${NC}"
        done
        echo -e "  ${GRAY}Full log: cat ${INSTALL_LOG}${NC}"
    fi
    return $result
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════╗
    ║                                      ║
    ║   🐧  UBUNTU DESKTOP v1.0  🐧        ║
    ║                                      ║
    ║       Tech Jarves - YouTube          ║
    ║                                      ║
    ╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "${WHITE}         Ubuntu 24.04 LTS on Android${NC}"
    echo ""
}

# ============== STEP 1: UPDATE TERMUX ==============
step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating Termux packages...${NC}"
    echo ""

    (yes | pkg update -y > /dev/null 2>&1) &
    spinner "$!" "Updating package lists..."

    (yes | pkg upgrade -y > /dev/null 2>&1) &
    spinner "$!" "Upgrading installed packages..."
}

# ============== STEP 2: REPOSITORIES ==============
step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding Termux repositories...${NC}"
    echo ""

    install_pkg "x11-repo"  "X11 Repository"
    install_pkg "tur-repo"  "TUR Repository"
}

# ============== STEP 3: TERMUX-X11 ==============
step_x11() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Termux-X11 display server...${NC}"
    echo ""

    install_pkg "termux-x11-nightly" "Termux-X11"
    install_pkg "xorg-xrandr"        "XRandR"
}

# ============== STEP 4: GPU DRIVERS + WINE ==============
step_gpu_wine() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing GPU drivers and Wine...${NC}"
    echo ""

    # Detect GPU via hardware EGL property (brand-based guessing is unreliable)
    local gpu_vendor
    gpu_vendor=$(getprop ro.hardware.egl 2>/dev/null || echo "")

    install_pkg "mesa-zink" "Mesa Zink (OpenGL over Vulkan)"

    if [[ "$gpu_vendor" == *"adreno"* ]] || [[ "$gpu_vendor" == *"freedreno"* ]]; then
        GPU_DRIVER="freedreno"
        install_pkg "mesa-vulkan-icd-freedreno" "Turnip Adreno Driver"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Adreno (Qualcomm) - Turnip driver${NC}"
    else
        GPU_DRIVER="swrast"
        install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan Renderer"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Software rendering (no Adreno detected)${NC}"
    fi

    install_pkg "vulkan-loader-android" "Vulkan Loader"

    # Hangover Wine (ARM-native .exe compatibility)
    (pkg remove wine-stable -y > /dev/null 2>&1) &
    spinner "$!" "Removing conflicting Wine versions..."

    install_pkg "hangover-wine"    "Hangover Wine"
    install_pkg "hangover-wowbox64" "Box64 Wrapper"

    local wine_bin="/data/data/com.termux/files/usr/opt/hangover-wine/bin/wine"
    if [ -f "$wine_bin" ]; then
        ln -sf "$wine_bin" /data/data/com.termux/files/usr/bin/wine
        ln -sf "/data/data/com.termux/files/usr/opt/hangover-wine/bin/winecfg" \
               /data/data/com.termux/files/usr/bin/winecfg
        echo -e "  ${GREEN}✓${NC} Wine symlinks created"
    else
        echo -e "  ${YELLOW}⚠${NC} Wine binary not found at expected path, skipping symlinks"
    fi
}

# ============== STEP 5: PULSEAUDIO ==============
step_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing PulseAudio...${NC}"
    echo ""

    install_pkg "pulseaudio" "PulseAudio Sound Server"
}

# ============== STEP 6: PROOT-DISTRO + UBUNTU ==============
step_proot_ubuntu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing proot-distro and Ubuntu 24.04...${NC}"
    echo ""

    install_pkg "proot-distro" "proot-distro"
    install_pkg "wget"         "wget"

    # proot-distro stores rootfs at $PREFIX/var/lib/proot-distro/installed-rootfs/
    # (same path we use as UBUNTU_ROOTFS — must stay in sync)
    if [ -d "${UBUNTU_ROOTFS}" ]; then
        echo -e "  ${GREEN}✓${NC} Ubuntu rootfs already present, skipping download"
    else
        (proot-distro install ubuntu > /dev/null 2>&1) &
        spinner "$!" "Downloading Ubuntu 24.04 LTS rootfs (~250 MB)..."
    fi
}

# ============== STEP 7: UBUNTU SYSTEM SETUP ==============
step_ubuntu_base() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Configuring Ubuntu system...${NC}"
    echo ""

    cat > "${UBUNTU_ROOTFS}/tmp/ubuntu_base_setup.sh" << 'INNEREOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NOWARNINGS=yes

# ── proot compatibility fix ────────────────────────────────────────────────
# dpkg post-install scripts call invoke-rc.d to start services.
# In proot there is no real init, so those calls hang forever (the "50% bug").
# policy-rc.d returning 101 tells invoke-rc.d to skip all service starts.
# This is the same technique Docker uses for container builds.
mkdir -p /usr/sbin
echo '#!/bin/sh
exit 101' > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d
# ──────────────────────────────────────────────────────────────────────────

apt-get update -y -q
apt-get upgrade -y -q
apt-get install -y -q --no-install-recommends \
    locales tzdata \
    dbus-x11 \
    ca-certificates curl gpg wget
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

# ── D-Bus machine-id ───────────────────────────────────────────────────────
# base-files creates /etc/machine-id as an empty placeholder.
# In a real system systemd fills it on first boot; in proot systemd never runs.
# dbus-launch (used by XFCE4 startup) REQUIRES a valid 32-char hex UUID here.
# We generate it explicitly with dbus-uuidgen right after dbus-x11 is installed.
dbus-uuidgen > /etc/machine-id 2>/dev/null || true
mkdir -p /var/lib/dbus
ln -sf /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true
echo "  [setup] D-Bus machine-id: $(cat /etc/machine-id 2>/dev/null)"
# ──────────────────────────────────────────────────────────────────────────
INNEREOF

    ubuntu_cmd "Updating Ubuntu and configuring system..." /tmp/ubuntu_base_setup.sh
    rm -f "${UBUNTU_ROOTFS}/tmp/ubuntu_base_setup.sh"
}

# ============== STEP 8: UBUNTU DESKTOP APPS ==============
step_ubuntu_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing desktop environment and apps...${NC}"
    echo ""

    cat > "${UBUNTU_ROOTFS}/tmp/ubuntu_desktop_setup.sh" << 'INNEREOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NOWARNINGS=yes

# ── PART 1: Core XFCE4 session ─────────────────────────────────────────────
# --no-install-recommends prevents xorg/xserver-xorg-* from being pulled in.
# Termux-X11 is the display server — xorg packages are NOT needed in proot.
# policy-rc.d (set in step 7) ensures dpkg does NOT try to start any service.
apt-get install -y -q --no-install-recommends \
    xfce4-session \
    xfwm4 \
    xfce4-panel \
    xfce4-settings \
    xfdesktop4 \
    dbus-x11

# ── PART 2: XFCE4 apps & UI extras ─────────────────────────────────────────
apt-get install -y -q --no-install-recommends \
    xfce4-terminal \
    xfce4-notifyd \
    thunar \
    mousepad \
    fonts-dejavu-core \
    adwaita-icon-theme

# ── PART 3: Developer essentials ────────────────────────────────────────────
apt-get install -y -q --no-install-recommends \
    git \
    curl \
    unzip

# ── VERIFY: startxfce4 must exist ───────────────────────────────────────────
if ! command -v startxfce4 >/dev/null 2>&1; then
    echo "FATAL: startxfce4 not found after installation!" >&2
    echo "Hint: check apt-get install output above for errors." >&2
    exit 1
fi
echo "SUCCESS: startxfce4 verified at $(command -v startxfce4)"
INNEREOF

    ubuntu_cmd "Installing XFCE4 desktop (core session)..." /tmp/ubuntu_desktop_setup.sh
    local xfce4_result=$?
    rm -f "${UBUNTU_ROOTFS}/tmp/ubuntu_desktop_setup.sh"

    # External verification — shows clearly whether XFCE4 is ready to launch
    # Write the check script into Ubuntu's rootfs (host path), run at Ubuntu path
    cat > "${UBUNTU_ROOTFS}/tmp/ubuntu_xfce4_verify.sh" << 'VERIFYEOF'
#!/bin/bash
command -v xfce4-session >/dev/null 2>&1
VERIFYEOF

    if proot-distro login ubuntu -- bash /tmp/ubuntu_xfce4_verify.sh > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} XFCE4 ready — xfce4-session found inside Ubuntu"
    else
        echo -e "  ${RED}✗${NC} XFCE4 not found inside Ubuntu!"
        echo ""
        echo -e "  ${YELLOW}Manual fix:${NC}"
        echo -e "  ${GRAY}  proot-distro login ubuntu${NC}"
        echo -e "  ${GRAY}  apt-get install -y --no-install-recommends xfce4-session xfwm4 xfce4-panel xfce4-settings xfdesktop4 dbus-x11${NC}"
        echo ""
        echo -e "  ${GRAY}Install log: cat ${INSTALL_LOG}${NC}"
    fi
    rm -f "${UBUNTU_ROOTFS}/tmp/ubuntu_xfce4_verify.sh"

    cat > "${UBUNTU_ROOTFS}/tmp/ubuntu_firefox_setup.sh" << 'INNEREOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt install -y firefox
INNEREOF

    ubuntu_cmd "Installing Firefox..." /tmp/ubuntu_firefox_setup.sh
    rm -f "${UBUNTU_ROOTFS}/tmp/ubuntu_firefox_setup.sh"
}

# ============== STEP 9: DEV TOOLS + SERVICES ==============
step_ubuntu_services() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing dev tools and services...${NC}"
    echo ""

    # Python 3
    cat > "${UBUNTU_ROOTFS}/tmp/ubuntu_python_setup.sh" << 'INNEREOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -q --no-install-recommends python3 python3-pip python3-venv
INNEREOF

    ubuntu_cmd "Installing Python 3..." /tmp/ubuntu_python_setup.sh
    rm -f "${UBUNTU_ROOTFS}/tmp/ubuntu_python_setup.sh"

    # VS Code (Microsoft ARM64 repo)
    cat > "${UBUNTU_ROOTFS}/tmp/ubuntu_vscode_setup.sh" << 'INNEREOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] \
https://packages.microsoft.com/repos/code stable main" \
    > /etc/apt/sources.list.d/vscode.list
apt-get update -y -q
apt-get install -y -q code
INNEREOF

    ubuntu_cmd "Installing VS Code..." /tmp/ubuntu_vscode_setup.sh
    rm -f "${UBUNTU_ROOTFS}/tmp/ubuntu_vscode_setup.sh"

    # OpenSSH
    cat > "${UBUNTU_ROOTFS}/tmp/ubuntu_ssh_setup.sh" << 'INNEREOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -q --no-install-recommends openssh-server
mkdir -p /run/sshd
# Configure SSH: allow root, change default port to 2222 to avoid Android conflicts
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
INNEREOF

    ubuntu_cmd "Installing OpenSSH (port 2222)..." /tmp/ubuntu_ssh_setup.sh
    rm -f "${UBUNTU_ROOTFS}/tmp/ubuntu_ssh_setup.sh"

    # Bluetooth
    cat > "${UBUNTU_ROOTFS}/tmp/ubuntu_bt_setup.sh" << 'INNEREOF'
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -q --no-install-recommends bluetooth bluez blueman
INNEREOF

    ubuntu_cmd "Installing Bluetooth (bluez + blueman)..." /tmp/ubuntu_bt_setup.sh
    rm -f "${UBUNTU_ROOTFS}/tmp/ubuntu_bt_setup.sh"
}

# ============== STEP 10: LAUNCHERS + SHORTCUTS ==============
step_launchers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating launcher scripts and shortcuts...${NC}"
    echo ""

    # GPU environment config
    mkdir -p ~/.config
    cat > ~/.config/ubuntu-desktop-gpu.sh << 'GPUEOF'
# Ubuntu Desktop - GPU Acceleration Config
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
GPUEOF

    if ! grep -q "ubuntu-desktop-gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/ubuntu-desktop-gpu.sh 2>/dev/null' >> ~/.bashrc
    fi
    echo -e "  ${GREEN}✓${NC} GPU config written"

    # --- start-ubuntu.sh ---
    cat > ~/start-ubuntu.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🐧 Starting Ubuntu Desktop..."
echo ""

source ~/.config/ubuntu-desktop-gpu.sh 2>/dev/null

# Stop existing sessions (SIGTERM first, then SIGKILL)
pkill -f "termux.x11" 2>/dev/null; sleep 1; pkill -9 -f "termux.x11" 2>/dev/null
pkill -f "xfce"        2>/dev/null; sleep 1; pkill -9 -f "xfce"        2>/dev/null
pkill -f "dbus"        2>/dev/null; sleep 1; pkill -9 -f "dbus"        2>/dev/null

# Audio
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "🔊 Starting PulseAudio..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 2>/dev/null
export PULSE_SERVER=127.0.0.1

# X11
echo "📺 Starting X11 display server..."
termux-x11 :1 -ac &
sleep 3
export DISPLAY=:1

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Open the Termux-X11 app to see the desktop!"
echo "  🔊 Audio is enabled!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Launch Ubuntu XFCE4 desktop
# ─────────────────────────────────────────────────────────────────────────────
# WHY NOT startxfce4:
#   startxfce4 is a wrapper that tries to start its OWN X server via xinit.
#   Since Termux-X11 is already running on :1, startxfce4 errors:
#     "X server already running on display :1"
#   We do NOT want to start a new X server — we want to connect to the existing one.
#
# CORRECT APPROACH: run xfce4-session directly with dbus-launch.
#   dbus-launch creates a D-Bus session bus and starts xfce4-session inside it.
#   xfce4-session handles starting xfwm4, xfce4-panel, xfdesktop, etc. itself.
# ─────────────────────────────────────────────────────────────────────────────
proot-distro login ubuntu -- bash --login -c '
    export DISPLAY=:1
    export PULSE_SERVER=127.0.0.1

    # ── Ensure D-Bus machine-id is valid (must happen before dbus-launch) ───
    # /etc/machine-id is created empty by base-files. Systemd fills it on first
    # boot but systemd does not run in proot. Without a valid 32-char hex UUID,
    # dbus-daemon aborts and xfce4-session loses DISPLAY — "Cannot open display: ."
    if [ ! -s /etc/machine-id ]; then
        dbus-uuidgen > /etc/machine-id 2>/dev/null
        mkdir -p /var/lib/dbus
        ln -sf /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null
    fi
    # ────────────────────────────────────────────────────────────────────────

    exec dbus-launch --exit-with-session xfce4-session
' || echo -e "\n⚠ XFCE4 exited unexpectedly. Check: cat ~/.xsession-errors"
LAUNCHEREOF

    chmod +x ~/start-ubuntu.sh
    echo -e "  ${GREEN}✓${NC} Created ~/start-ubuntu.sh"

    # --- stop-ubuntu.sh ---
    cat > ~/stop-ubuntu.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping Ubuntu Desktop..."
pkill -f "termux.x11" 2>/dev/null; sleep 1; pkill -9 -f "termux.x11" 2>/dev/null
pkill -f "pulseaudio"  2>/dev/null; sleep 1; pkill -9 -f "pulseaudio"  2>/dev/null
pkill -f "xfce"        2>/dev/null; sleep 1; pkill -9 -f "xfce"        2>/dev/null
pkill -f "dbus"        2>/dev/null; sleep 1; pkill -9 -f "dbus"        2>/dev/null
echo "Desktop stopped."
STOPEOF

    chmod +x ~/stop-ubuntu.sh
    echo -e "  ${GREEN}✓${NC} Created ~/stop-ubuntu.sh"

    # --- Ubuntu-side desktop shortcuts ---
    cat > "${UBUNTU_ROOTFS}/tmp/ubuntu_shortcuts_setup.sh" << 'INNEREOF'
#!/bin/bash
mkdir -p /root/Desktop

cat > /root/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF

cat > /root/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Comment=Code Editor
Exec=code --no-sandbox
Icon=com.visualstudio.code
Type=Application
Categories=Development;
EOF

cat > /root/Desktop/Terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Comment=XFCE Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
EOF

cat > /root/Desktop/Files.desktop << 'EOF'
[Desktop Entry]
Name=Files
Comment=Thunar File Manager
Exec=thunar
Icon=system-file-manager
Type=Application
Categories=System;FileManager;
EOF

cat > /root/Desktop/Bluetooth.desktop << 'EOF'
[Desktop Entry]
Name=Bluetooth
Comment=Bluetooth Manager
Exec=blueman-manager
Icon=bluetooth
Type=Application
Categories=Settings;
EOF

chmod +x /root/Desktop/*.desktop
INNEREOF

    ubuntu_cmd "Creating desktop shortcuts..." /tmp/ubuntu_shortcuts_setup.sh
    rm -f "${UBUNTU_ROOTFS}/tmp/ubuntu_shortcuts_setup.sh"
}

# ============== COMPLETION ==============
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║         ✅  INSTALLATION COMPLETE!  ✅                        ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
COMPLETE
    echo -e "${NC}"

    echo -e "${WHITE}🐧 Your Ubuntu Desktop is ready!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}🚀 START DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/start-ubuntu.sh${NC}"
    echo ""
    echo -e "${WHITE}🛑 STOP DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/stop-ubuntu.sh${NC}"
    echo ""
    echo -e "${WHITE}🐧 UBUNTU SHELL (CLI only):${NC}"
    echo -e "   ${GREEN}proot-distro login ubuntu${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📦 INSTALLED INSIDE UBUNTU:${NC}"
    echo -e "   • XFCE4 Desktop + Thunar + Terminal"
    echo -e "   • Firefox Browser"
    echo -e "   • VS Code"
    echo -e "   • Python 3 + pip + venv"
    echo -e "   • Git + cURL + unzip"
    echo -e "   • OpenSSH (port 2222)"
    echo -e "   • Bluetooth (bluez + blueman)"
    echo ""
    echo -e "${CYAN}📦 INSTALLED IN TERMUX (host):${NC}"
    echo -e "   • Termux-X11 (display server)"
    echo -e "   • GPU Acceleration (Turnip/Zink)"
    echo -e "   • PulseAudio (sound)"
    echo -e "   • Wine/Hangover (.exe support)"
    echo ""
    echo -e "${WHITE}⚡ TIP: Open Termux-X11 app FIRST, then run start-ubuntu.sh${NC}"
    echo ""
}

# ============== MAIN ==============
main() {
    show_banner

    echo -e "${WHITE}  Installs Ubuntu 24.04 LTS desktop environment on Android.${NC}"
    echo -e "${WHITE}  Requires a stable internet connection throughout.${NC}"
    echo ""
    echo -e "${GRAY}  Estimated time: 25-45 minutes (depends on internet speed)${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start, or Ctrl+C to cancel...${NC}"
    # /dev/tty ensures input works even when script is piped via curl | bash
    read -r < /dev/tty

    step_update
    step_repos
    step_x11
    step_gpu_wine
    step_audio
    step_proot_ubuntu
    step_ubuntu_base
    step_ubuntu_desktop
    step_ubuntu_services
    step_launchers

    show_completion
}

# ============== RUN ==============
main
