#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 MOBILE HACKING LAB - Uninstaller v1.0
#
#  Reverses all changes made by install.sh:
#  - Removes installed packages
#  - Removes launcher scripts and config files
#  - Removes desktop shortcuts
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
        printf "\r  ${YELLOW}⚠${NC} ${message} ${GRAY}(skipped/not found)${NC}\n"
    fi
}

# ============== REMOVE PACKAGE ==============
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
    ║   🗑️  MOBILE HACKLAB UNINSTALLER     ║
    ║                                      ║
    ║       Tech Jarves - YouTube          ║
    ║                                      ║
    ╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
}

# ============== CONFIRMATION ==============
confirm_uninstall() {
    echo -e "${YELLOW}  ⚠  WARNING: This will remove all Mobile HackLab components:${NC}"
    echo ""
    echo -e "   • All hacking tools (nmap, hydra, sqlmap, metasploit, john...)"
    echo -e "   • XFCE4 desktop environment"
    echo -e "   • Firefox, VS Code, Git, Wine"
    echo -e "   • GPU drivers (mesa-zink, vulkan)"
    echo -e "   • PulseAudio"
    echo -e "   • All launcher scripts and desktop shortcuts"
    echo -e "   • GPU config entry in ~/.bashrc"
    echo ""
    echo -e "${RED}  This action cannot be undone.${NC}"
    echo ""
    # /dev/tty ensures input works even when script is piped via curl | bash
    read -rp "  Type 'yes' to confirm uninstall, or press Ctrl+C to cancel: " confirm < /dev/tty
    if [[ "$confirm" != "yes" ]]; then
        echo -e "\n${GREEN}  Uninstall cancelled.${NC}\n"
        exit 0
    fi
    echo ""
}

# ============== STEP 1: STOP RUNNING SERVICES ==============
step_stop_services() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Stopping running services...${NC}"
    echo ""

    pkill -f "termux.x11" 2>/dev/null; sleep 1; pkill -9 -f "termux.x11" 2>/dev/null
    pkill -f "xfce" 2>/dev/null; sleep 1; pkill -9 -f "xfce" 2>/dev/null
    pkill -f "pulseaudio" 2>/dev/null; sleep 1; pkill -9 -f "pulseaudio" 2>/dev/null
    pkill -f "dbus" 2>/dev/null; sleep 1; pkill -9 -f "dbus" 2>/dev/null

    echo -e "  ${GREEN}✓${NC} All HackLab services stopped"
}

# ============== STEP 2: REMOVE FILES AND SCRIPTS ==============
step_remove_files() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing launcher scripts and config...${NC}"
    echo ""

    local files=(
        "$HOME/start-hacklab.sh"
        "$HOME/stop-hacklab.sh"
        "$HOME/hacktools.sh"
        "$HOME/.config/hacklab-gpu.sh"
    )

    for f in "${files[@]}"; do
        if [ -f "$f" ]; then
            rm -f "$f"
            echo -e "  ${GREEN}✓${NC} Removed: ${GRAY}$f${NC}"
        else
            echo -e "  ${GRAY}–${NC} Not found: ${GRAY}$f${NC}"
        fi
    done

    # Remove Desktop shortcuts
    local desktop_files=(
        "$HOME/Desktop/Firefox.desktop"
        "$HOME/Desktop/VSCode.desktop"
        "$HOME/Desktop/Terminal.desktop"
        "$HOME/Desktop/Metasploit.desktop"
        "$HOME/Desktop/HackTools.desktop"
        "$HOME/Desktop/Windows_Explorer.desktop"
        "$HOME/Desktop/Wine_Config.desktop"
    )

    for f in "${desktop_files[@]}"; do
        if [ -f "$f" ]; then
            rm -f "$f"
            echo -e "  ${GREEN}✓${NC} Removed: ${GRAY}$f${NC}"
        fi
    done

    # Remove Desktop dir if empty
    if [ -d "$HOME/Desktop" ] && [ -z "$(ls -A "$HOME/Desktop" 2>/dev/null)" ]; then
        rmdir "$HOME/Desktop"
        echo -e "  ${GREEN}✓${NC} Removed empty Desktop directory"
    fi
}

# ============== STEP 3: REMOVE WINE SYMLINKS ==============
step_remove_symlinks() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing Wine symlinks...${NC}"
    echo ""

    local prefix="/data/data/com.termux/files/usr/bin"
    local symlinks=("wine" "winecfg")

    for sym in "${symlinks[@]}"; do
        local target="$prefix/$sym"
        if [ -L "$target" ]; then
            rm -f "$target"
            echo -e "  ${GREEN}✓${NC} Removed symlink: ${GRAY}$target${NC}"
        else
            echo -e "  ${GRAY}–${NC} Symlink not found: ${GRAY}$target${NC}"
        fi
    done

    # Clean up Python packages
    echo ""
    echo -e "  ${YELLOW}⏳${NC} Removing Python security libraries..."
    pip uninstall -y requests beautifulsoup4 > /dev/null 2>&1
    echo -e "  ${GREEN}✓${NC} Python packages removed"
}

# ============== STEP 4: REMOVE SECURITY AND NETWORK TOOLS ==============
step_remove_tools() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing security and network tools...${NC}"
    echo ""

    local tools=(
        "metasploit:Metasploit Framework"
        "hydra:Hydra"
        "john:John the Ripper"
        "sqlmap:SQLMap"
        "nmap:Nmap"
        "netcat-openbsd:Netcat"
        "whois:Whois"
        "dnsutils:DNS Utilities"
        "tracepath:Tracepath"
        "hangover-wine:Wine (Hangover)"
        "hangover-wowbox64:Box64 Wrapper"
    )

    for entry in "${tools[@]}"; do
        local pkg="${entry%%:*}"
        local name="${entry##*:}"
        remove_pkg "$pkg" "$name"
    done
}

# ============== STEP 5: REMOVE DESKTOP AND APPS ==============
step_remove_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Removing desktop environment and apps...${NC}"
    echo ""

    local pkgs=(
        "xfce4:XFCE4 Desktop"
        "xfce4-terminal:XFCE4 Terminal"
        "thunar:Thunar File Manager"
        "mousepad:Mousepad Editor"
        "termux-x11-nightly:Termux-X11"
        "xorg-xrandr:XRandR"
        "pulseaudio:PulseAudio"
        "firefox:Firefox"
        "code-oss:VS Code"
        "mesa-zink:Mesa Zink"
        "mesa-vulkan-icd-freedreno:Turnip Driver"
        "mesa-vulkan-icd-swrast:Software Vulkan"
        "vulkan-loader-android:Vulkan Loader"
        "git:Git"
        "wget:Wget"
        "curl:cURL"
    )

    for entry in "${pkgs[@]}"; do
        local pkg="${entry%%:*}"
        local name="${entry##*:}"
        remove_pkg "$pkg" "$name"
    done
}

# ============== STEP 6: CLEAN ~/.bashrc AND REPOS ==============
step_cleanup() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Cleaning up repositories and shell config...${NC}"
    echo ""

    # Remove hacklab-gpu.sh line from ~/.bashrc
    if grep -q "hacklab-gpu.sh" "$HOME/.bashrc" 2>/dev/null; then
        # Use a temp file to avoid in-place sed issues in Termux
        grep -v "hacklab-gpu.sh" "$HOME/.bashrc" > "$HOME/.bashrc.tmp" && mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
        echo -e "  ${GREEN}✓${NC} Removed hacklab-gpu.sh from ~/.bashrc"
    else
        echo -e "  ${GRAY}–${NC} No hacklab entry found in ~/.bashrc"
    fi

    # Remove repositories
    (pkg remove x11-repo -y > /dev/null 2>&1) &
    spinner "$!" "Removing X11 Repository..."

    (pkg remove tur-repo -y > /dev/null 2>&1) &
    spinner "$!" "Removing TUR Repository..."

    # Final package cleanup
    (yes | pkg autoremove -y > /dev/null 2>&1) &
    spinner "$!" "Autoremoving orphaned packages..."
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

    echo -e "${WHITE}  Mobile HackLab has been removed from your device.${NC}"
    echo ""
    echo -e "${YELLOW}  Tip: Restart Termux to apply all changes.${NC}"
    echo ""
    echo -e "${GRAY}  Note: git, wget and curl were removed as part of the lab."
    echo -e "  Reinstall them anytime with: pkg install git wget curl${NC}"
    echo ""
}

# ============== MAIN ==============
main() {
    show_banner
    confirm_uninstall

    step_stop_services
    step_remove_files
    step_remove_symlinks
    step_remove_tools
    step_remove_desktop
    step_cleanup

    show_completion
}

# ============== RUN ==============
main
