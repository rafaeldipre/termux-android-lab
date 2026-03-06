#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  🗑️  UBUNTU DESKTOP - Uninstaller v1.0
#
#  Reverses all changes made by install.sh:
#  - Stops running desktop sessions
#  - Removes Ubuntu 24.04 rootfs (proot-distro)
#  - Removes launcher scripts and GPU config
#  - Removes Termux host packages
#  - Restores ~/.bashrc
#
#  Author: Tech Jarves
#  YouTube: https://youtube.com/@TechJarves
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=6
CURRENT_STEP=0

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

    BAR="${RED}"
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
        # On uninstall, "not found" is acceptable — show as skipped, not error
        printf "\r  ${GRAY}–${NC} ${message} ${GRAY}(not installed)${NC}\n"
    fi
}

# ============== HELPER ==============
remove_pkg() {
    local pkg=$1
    local name="${2:-$pkg}"
    (pkg remove "$pkg" -y > /dev/null 2>&1) &
    spinner "$!" "Removing ${name}..."
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${RED}"
    cat << 'BANNER'
    ╔══════════════════════════════════════╗
    ║                                      ║
    ║  🗑️  UBUNTU DESKTOP UNINSTALLER      ║
    ║                                      ║
    ║       Tech Jarves - YouTube          ║
    ║                                      ║
    ╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
}

# ============== CONFIRMATION ==============
confirm_uninstall() {
    echo -e "${YELLOW}  ⚠  WARNING: This will permanently remove:${NC}"
    echo ""
    echo -e "   • Ubuntu 24.04 rootfs (~3-5 GB)"
    echo -e "   • All files stored inside Ubuntu"
    echo -e "   • Termux packages: mesa, vulkan, pulseaudio, wine, termux-x11..."
    echo -e "   • Launcher scripts: ~/start-ubuntu.sh, ~/stop-ubuntu.sh"
    echo -e "   • GPU config: ~/.config/ubuntu-desktop-gpu.sh"
    echo -e "   • GPU env entry in ~/.bashrc"
    echo ""
    echo -e "${RED}  This action cannot be undone.${NC}"
    echo ""
    read -rp "  Type 'yes' to confirm, or Ctrl+C to cancel: " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo -e "\n${GREEN}  Uninstall cancelled.${NC}\n"
        exit 0
    fi
    echo ""
}

# ============== STEP 1: STOP SERVICES ==============
step_stop_services() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Stopping running services...${NC}"
    echo ""

    pkill -f "termux.x11" 2>/dev/null; sleep 1; pkill -9 -f "termux.x11" 2>/dev/null
    pkill -f "xfce"        2>/dev/null; sleep 1; pkill -9 -f "xfce"        2>/dev/null
    pkill -f "pulseaudio"  2>/dev/null; sleep 1; pkill -9 -f "pulseaudio"  2>/dev/null
    pkill -f "dbus"        2>/dev/null; sleep 1; pkill -9 -f "dbus"        2>/dev/null
    pkill -f "proot"       2>/dev/null; sleep 1; pkill -9 -f "proot"       2>/dev/null

    echo -e "  ${GREEN}✓${NC} All desktop services stopped"
}

# ============== STEP 2: REMOVE UBUNTU ROOTFS ==============
step_remove_ubuntu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing Ubuntu 24.04 rootfs...${NC}"
    echo ""

    local rootfs_dir="$HOME/.local/share/proot-distro/installed-rootfs/ubuntu"
    if [ -d "$rootfs_dir" ]; then
        (proot-distro remove ubuntu > /dev/null 2>&1) &
        spinner "$!" "Removing Ubuntu rootfs (~3-5 GB)..."
    else
        echo -e "  ${GRAY}–${NC} Ubuntu rootfs not found, skipping"
    fi
}

# ============== STEP 3: REMOVE LAUNCHER FILES ==============
step_remove_files() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing launcher scripts and config...${NC}"
    echo ""

    local files=(
        "$HOME/start-ubuntu.sh"
        "$HOME/stop-ubuntu.sh"
        "$HOME/.config/ubuntu-desktop-gpu.sh"
    )

    for f in "${files[@]}"; do
        if [ -f "$f" ]; then
            rm -f "$f"
            echo -e "  ${GREEN}✓${NC} Removed: ${GRAY}$f${NC}"
        else
            echo -e "  ${GRAY}–${NC} Not found: ${GRAY}$f${NC}"
        fi
    done
}

# ============== STEP 4: REMOVE WINE SYMLINKS ==============
step_remove_symlinks() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing Wine symlinks...${NC}"
    echo ""

    local prefix="/data/data/com.termux/files/usr/bin"
    for sym in wine winecfg; do
        local target="$prefix/$sym"
        if [ -L "$target" ]; then
            rm -f "$target"
            echo -e "  ${GREEN}✓${NC} Removed symlink: ${GRAY}$target${NC}"
        else
            echo -e "  ${GRAY}–${NC} Symlink not found: ${GRAY}$target${NC}"
        fi
    done
}

# ============== STEP 5: REMOVE TERMUX PACKAGES ==============
step_remove_packages() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing Termux host packages...${NC}"
    echo ""

    local packages=(
        "hangover-wine:Hangover Wine"
        "hangover-wowbox64:Box64 Wrapper"
        "mesa-vulkan-icd-freedreno:Turnip Driver"
        "mesa-vulkan-icd-swrast:Software Vulkan"
        "vulkan-loader-android:Vulkan Loader"
        "mesa-zink:Mesa Zink"
        "pulseaudio:PulseAudio"
        "termux-x11-nightly:Termux-X11"
        "xorg-xrandr:XRandR"
        "proot-distro:proot-distro"
        "wget:wget"
        "tur-repo:TUR Repository"
        "x11-repo:X11 Repository"
    )

    for entry in "${packages[@]}"; do
        local pkg="${entry%%:*}"
        local name="${entry##*:}"
        remove_pkg "$pkg" "$name"
    done

    (yes | pkg autoremove -y > /dev/null 2>&1) &
    spinner "$!" "Autoremoving orphaned packages..."
}

# ============== STEP 6: CLEAN ~/.bashrc ==============
step_cleanup_bashrc() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Restoring ~/.bashrc...${NC}"
    echo ""

    if grep -q "ubuntu-desktop-gpu.sh" "$HOME/.bashrc" 2>/dev/null; then
        grep -v "ubuntu-desktop-gpu.sh" "$HOME/.bashrc" > "$HOME/.bashrc.tmp" \
            && mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
        echo -e "  ${GREEN}✓${NC} Removed GPU config entry from ~/.bashrc"
    else
        echo -e "  ${GRAY}–${NC} No Ubuntu Desktop entry found in ~/.bashrc"
    fi
}

# ============== COMPLETION ==============
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║         ✅  UNINSTALL COMPLETE!  ✅                           ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
COMPLETE
    echo -e "${NC}"

    echo -e "${WHITE}  Ubuntu Desktop has been completely removed.${NC}"
    echo ""
    echo -e "${YELLOW}  Tip: Restart Termux to fully apply all changes.${NC}"
    echo ""
}

# ============== MAIN ==============
main() {
    show_banner
    confirm_uninstall

    step_stop_services
    step_remove_ubuntu
    step_remove_files
    step_remove_symlinks
    step_remove_packages
    step_cleanup_bashrc

    show_completion
}

# ============== RUN ==============
main
