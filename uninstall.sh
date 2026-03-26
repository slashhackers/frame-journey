#!/bin/bash
set -e

echo "🎢 Frame Journey – Uninstaller"
echo "------------------------------------------"

INSTALL_DIR="$HOME/.local/share/frame-journey"
BIN_DIR="$HOME/.local/bin"
BINARY_NAME="frame-journey"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

status_ok() { echo -e "${GREEN}✅ $1${NC}"; }
status_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

remove_path_persistence() {
    local shell_profile=""
    case "$SHELL" in
        */zsh)  shell_profile="$HOME/.zshrc" ;;
        */bash) shell_profile="$HOME/.bashrc" ;;
        *)      return ;;
    esac

    if [ -f "$shell_profile" ]; then
        if grep -q "# Frame Journey CLI" "$shell_profile"; then
            status_info "Cleaning up PATH configuration in $shell_profile..."
            
            # Temporary file approach is most portable across macOS and Linux
            grep -v "# Frame Journey CLI" "$shell_profile" | \
            grep -v "export PATH=\"\$HOME/.local/bin:\$PATH\"" > "$shell_profile.tmp"
            
            mv "$shell_profile.tmp" "$shell_profile"
            status_ok "PATH configuration removed."
        fi
    fi
}

# 1. Remove binary symlink
if [ -L "$BIN_DIR/$BINARY_NAME" ]; then
    status_info "Removing symlink: $BIN_DIR/$BINARY_NAME"
    rm "$BIN_DIR/$BINARY_NAME"
    status_ok "Symlink removed."
else
    status_info "Symlink not found, skipping."
fi

# 2. Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
    status_info "Removing installation directory: $INSTALL_DIR"
    rm -rf "$INSTALL_DIR"
    status_ok "Files removed."
else
    status_info "Installation directory not found, skipping."
fi

# 3. Path cleanup
remove_path_persistence

echo "------------------------------------------"
status_ok "🎢 Frame Journey has been uninstalled successfully."
status_info "Please run: ${BLUE}source ~/.zshrc${NC} (or ~/.bashrc) to refresh your shell."
echo "------------------------------------------"
