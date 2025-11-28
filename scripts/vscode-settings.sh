#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║           VS Code Settings Backup & Restore Script                         ║
# ║           by Chris Domains - Chrinux-AI                                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

VSCODE_SETTINGS_DIR="$HOME/.config/Code/User"
BACKUP_DIR="$(dirname "$0")/vscode-backup"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║       🎨 VS Code Settings Manager - Chrinux-AI               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

backup_settings() {
    echo -e "${BLUE}📦 Backing up VS Code settings...${NC}"
    mkdir -p "$BACKUP_DIR"

    if [ -f "$VSCODE_SETTINGS_DIR/settings.json" ]; then
        cp "$VSCODE_SETTINGS_DIR/settings.json" "$BACKUP_DIR/settings.json"
        echo -e "${GREEN}✓ settings.json backed up${NC}"
    fi

    if [ -f "$VSCODE_SETTINGS_DIR/keybindings.json" ]; then
        cp "$VSCODE_SETTINGS_DIR/keybindings.json" "$BACKUP_DIR/keybindings.json"
        echo -e "${GREEN}✓ keybindings.json backed up${NC}"
    fi

    # Backup extensions list
    code --list-extensions > "$BACKUP_DIR/extensions.txt" 2>/dev/null
    echo -e "${GREEN}✓ Extensions list saved${NC}"

    echo -e "${GREEN}✅ Backup complete! Files saved to: $BACKUP_DIR${NC}"
}

restore_settings() {
    echo -e "${BLUE}🔄 Restoring VS Code settings...${NC}"

    if [ -f "$BACKUP_DIR/settings.json" ]; then
        mkdir -p "$VSCODE_SETTINGS_DIR"
        cp "$BACKUP_DIR/settings.json" "$VSCODE_SETTINGS_DIR/settings.json"
        echo -e "${GREEN}✓ settings.json restored${NC}"
    else
        echo -e "${RED}✗ settings.json not found in backup${NC}"
    fi

    if [ -f "$BACKUP_DIR/keybindings.json" ]; then
        cp "$BACKUP_DIR/keybindings.json" "$VSCODE_SETTINGS_DIR/keybindings.json"
        echo -e "${GREEN}✓ keybindings.json restored${NC}"
    fi

    # Restore extensions
    if [ -f "$BACKUP_DIR/extensions.txt" ]; then
        echo -e "${BLUE}📦 Installing extensions...${NC}"
        while IFS= read -r extension; do
            code --install-extension "$extension" --force 2>/dev/null
        done < "$BACKUP_DIR/extensions.txt"
        echo -e "${GREEN}✓ Extensions restored${NC}"
    fi

    echo -e "${GREEN}✅ Restore complete! Restart VS Code to apply changes.${NC}"
}

install_extensions() {
    echo -e "${BLUE}📦 Installing recommended extensions...${NC}"

    extensions=(
        # Themes & Icons
        "zhuangtongfa.material-theme"
        "pkief.material-icon-theme"
        "miguelsolorio.fluent-icons"

        # Visual Enhancements
        "oderwat.indent-rainbow"
        "aaron-bond.better-comments"
        "usernamehw.errorlens"
        "naumovs.color-highlight"
        "mechatroner.rainbow-csv"

        # Productivity
        "formulahendry.auto-rename-tag"
        "formulahendry.auto-close-tag"
        "christian-kohler.path-intellisense"
        "streetsidesoftware.code-spell-checker"
        "wayou.vscode-todo-highlight"
        "gruntfuggly.todo-tree"

        # Git
        "eamodio.gitlens"
        "mhutchie.git-graph"

        # Web Development
        "ritwickdey.liveserver"
        "esbenp.prettier-vscode"
        "dbaeumer.vscode-eslint"
        "bmewburn.vscode-intelephense-client"

        # Python
        "ms-python.python"
        "ms-python.vscode-pylance"
        "ms-python.black-formatter"

        # Shell
        "foxundermoon.shell-format"
        "timonwong.shellcheck"

        # AI
        "github.copilot"
        "github.copilot-chat"
    )

    for ext in "${extensions[@]}"; do
        echo -e "${CYAN}Installing: $ext${NC}"
        code --install-extension "$ext" --force 2>/dev/null
    done

    echo -e "${GREEN}✅ All extensions installed!${NC}"
}

show_help() {
    print_header
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  backup    - Backup current VS Code settings"
    echo "  restore   - Restore settings from backup"
    echo "  install   - Install recommended extensions"
    echo "  all       - Restore settings and install extensions"
    echo "  help      - Show this help message"
    echo ""
}

# Main
print_header

case "$1" in
    backup)
        backup_settings
        ;;
    restore)
        restore_settings
        ;;
    install)
        install_extensions
        ;;
    all)
        restore_settings
        install_extensions
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Run with: backup, restore, install, all, or help"
        echo ""
        show_help
        ;;
esac
