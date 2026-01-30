#!/bin/bash
#
# claude-search installer
# Installs claude-search to ~/.claude/bin/
#

set -e

INSTALL_DIR="$HOME/.claude/bin"
SCRIPT_NAME="claude-search"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Uninstall function
uninstall() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  claude-search uninstaller"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo

    # Remove the script
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        rm "$INSTALL_DIR/$SCRIPT_NAME"
        echo "✓ Removed $INSTALL_DIR/$SCRIPT_NAME"
    else
        echo "  Script not found at $INSTALL_DIR/$SCRIPT_NAME"
    fi

    # Find and offer to clean shell config
    for config in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
        if [ -f "$config" ] && grep -q '.claude/bin' "$config" 2>/dev/null; then
            echo
            echo -e "${YELLOW}Found PATH entry in $config${NC}"
            read -p "  Remove PATH from $config? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Remove the claude/bin PATH lines
                if [[ "$(uname)" == "Darwin" ]]; then
                    sed -i '' '/# Claude Code tools/d' "$config"
                    sed -i '' '/\.claude\/bin/d' "$config"
                else
                    sed -i '/# Claude Code tools/d' "$config"
                    sed -i '/\.claude\/bin/d' "$config"
                fi
                echo -e "✓ ${GREEN}Removed from $config${NC}"
            fi
        fi
    done

    # Remove bin dir if empty
    if [ -d "$INSTALL_DIR" ] && [ -z "$(ls -A "$INSTALL_DIR")" ]; then
        rmdir "$INSTALL_DIR"
        echo "✓ Removed empty directory $INSTALL_DIR"
    fi

    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}Uninstall complete!${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "  Restart your terminal or run: source ~/.zshrc"
    exit 0
}

# Check for --uninstall flag
if [[ "$1" == "--uninstall" ]] || [[ "$1" == "-u" ]]; then
    uninstall
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  claude-search installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is required but not installed.${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "✓ Python $PYTHON_VERSION found"

# Check if Claude Code directory exists
if [ ! -d "$HOME/.claude" ]; then
    echo -e "${YELLOW}Warning: ~/.claude directory not found.${NC}"
    echo "  Claude Code may not be installed."
    echo "  Creating directory anyway..."
fi

# Create install directory
mkdir -p "$INSTALL_DIR"
echo "✓ Install directory: $INSTALL_DIR"

# Determine script location (local file or download)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/$SCRIPT_NAME" ]; then
    # Local install from cloned repo
    cp "$SCRIPT_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"
    echo "✓ Installed from local file"
else
    # Download from GitHub
    echo "Downloading from GitHub..."
    curl -fsSL "https://raw.githubusercontent.com/akariev/claude-search/main/claude-search" \
        -o "$INSTALL_DIR/$SCRIPT_NAME"
    echo "✓ Downloaded from GitHub"
fi

# Make executable
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
echo "✓ Made executable"

# Determine shell config file
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    # On macOS, prefer .bash_profile for login shells
    if [[ "$(uname)" == "Darwin" ]] && [ -f "$HOME/.bash_profile" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    else
        SHELL_CONFIG="$HOME/.bashrc"
    fi
else
    SHELL_CONFIG="$HOME/.profile"
fi

PATH_EXPORT='export PATH="$HOME/.claude/bin:$PATH"'

# Check if already in PATH
if echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "✓ $INSTALL_DIR is already in PATH"
elif grep -q '.claude/bin' "$SHELL_CONFIG" 2>/dev/null; then
    echo "✓ PATH already configured in $SHELL_CONFIG"
    echo "  Run: source $SHELL_CONFIG"
else
    echo
    echo -e "${YELLOW}Add to PATH?${NC}"
    echo "  Will add to: $SHELL_CONFIG"
    echo
    read -p "  Add PATH automatically? [Y/n] " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        # Add newline and PATH export to shell config
        echo "" >> "$SHELL_CONFIG"
        echo "# Claude Code tools" >> "$SHELL_CONFIG"
        echo "$PATH_EXPORT" >> "$SHELL_CONFIG"
        echo -e "✓ ${GREEN}Added to $SHELL_CONFIG${NC}"
        echo
        echo "  To use now, run:"
        echo -e "  ${GREEN}source $SHELL_CONFIG${NC}"
    else
        echo
        echo "  To add manually, add this line to $SHELL_CONFIG:"
        echo -e "  ${GREEN}$PATH_EXPORT${NC}"
    fi
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Installation complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
echo "Usage:"
echo "  claude-search \"search term\"      # Basic search"
echo "  claude-search \"term\" -i          # Interactive mode"
echo "  claude-search --help              # Show all options"
echo
