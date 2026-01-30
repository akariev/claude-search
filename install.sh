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

# Check if already in PATH
if echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "✓ $INSTALL_DIR is already in PATH"
else
    echo
    echo -e "${YELLOW}Add to PATH:${NC}"
    echo "  Add this line to your ~/.zshrc or ~/.bashrc:"
    echo
    echo -e "  ${GREEN}export PATH=\"\$HOME/.claude/bin:\$PATH\"${NC}"
    echo
    echo "  Then run: source ~/.zshrc (or ~/.bashrc)"
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
