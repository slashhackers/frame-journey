#!/bin/bash
set -e

echo "🎢 Frame Journey – Professional Installer"
echo "------------------------------------------"

# Detect OS
OS="$(uname -s)"
INSTALL_DIR="$HOME/.local/share/frame-journey"
BIN_DIR="$HOME/.local/bin"
BINARY_NAME="frame-journey"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper for status messages
status_ok() { echo -e "${GREEN}✅ $1${NC}"; }
status_fail() { echo -e "${RED}❌ $1${NC}"; }
status_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

install_dependencies() {
    case "$OS" in
        Linux*)
            status_info "Detected Linux. Checking for apt..."
            if command -v apt >/dev/null 2>&1; then
                sudo apt update && sudo apt install -y ffmpeg curl ca-certificates
            else
                status_fail "Apt not found. Please install ffmpeg manually."
                exit 1
            fi
            ;;
        Darwin*)
            status_info "Detected macOS. Checking for Homebrew..."
            if ! command -v brew >/dev/null 2>&1; then
                status_info "Homebrew not found. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install ffmpeg
            ;;
        *)
            status_fail "Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

verify_dependencies() {
    if ! command -v ffmpeg >/dev/null 2>&1; then
        status_info "FFmpeg not found. Attempting to install..."
        install_dependencies
    fi
    
    if command -v ffmpeg >/dev/null 2>&1; then
        status_ok "FFmpeg is installed: $(ffmpeg -version | head -n 1)"
    else
        status_fail "Failed to install FFmpeg. Please install it manually."
        exit 1
    fi
}

install_files() {
    # If we're not running from inside the repo, clone it first
    if [ ! -d "bin" ] || [ ! -d "libexec" ]; then
        status_info "Remote execution detected. Cloning repository..."
        TEMP_DIR=$(mktemp -d)
        git clone --quiet https://github.com/slashhackers/frame-journey.git "$TEMP_DIR"
        SOURCE_DIR="$TEMP_DIR"
    else
        SOURCE_DIR="."
    fi

    status_info "Installing files to $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
    
    # Copy project structure
    cp -R "$SOURCE_DIR/bin" "$SOURCE_DIR/libexec" "$SOURCE_DIR/config" "$INSTALL_DIR/" 2>/dev/null || true
    
    chmod +x "$INSTALL_DIR/bin/$BINARY_NAME"
    chmod +x "$INSTALL_DIR/libexec"/**/*.sh
    
    [ -n "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
    status_ok "Files installed successfully."
}

setup_symlink() {
    status_info "Setting up symlink in $BIN_DIR..."
    mkdir -p "$BIN_DIR"
    ln -sf "$INSTALL_DIR/bin/$BINARY_NAME" "$BIN_DIR/$BINARY_NAME"
    status_ok "Symlink created: $BIN_DIR/$BINARY_NAME -> $INSTALL_DIR/bin/$BINARY_NAME"
}

check_path() {
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        status_info "Warning: $BIN_DIR is not in your PATH."
        status_info "To fix this, add the following line to your ~/.zshrc or ~/.bashrc:"
        echo -e "${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
        status_info "Then run: source ~/.zshrc (or ~/.bashrc)"
    else
        status_ok "$BIN_DIR is already in your PATH."
    fi
}

# --- Main Execution ---

verify_dependencies
install_files
setup_symlink
check_path

echo "------------------------------------------"
status_ok "🎢 Frame Journey has been installed successfully!"
echo "You can now run it using: $BINARY_NAME <input_video>"
