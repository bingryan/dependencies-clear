#!/bin/sh
#
# Installation script for dclear and dclear-docker
#

REPO_URL="https://raw.githubusercontent.com/bingryan/dependencies-clear/main"
INSTALL_DIR=$(dirname "$0")
binpaths="/usr/local/bin /usr/bin"

# Track installation status
main_installed=""
docker_installed=""

# Function to download file from GitHub
download_file() {
    local url="$1"
    local output="$2"

    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$output" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$output" 2>/dev/null
    else
        return 1
    fi
}

# Function to install a binary
install_binary() {
    local source="$1"
    local name="$2"

    for binpath in $binpaths; do
        if cp "$source" "$binpath/$name" 2>/dev/null; then
            chmod +x "$binpath/$name"
            echo "✓ Installed $name to $binpath"
            return 0
        fi
    done
    return 1
}

# Check if running from local directory with dclear files
if [ -f "$INSTALL_DIR/dclear" ]; then
    # Local installation mode
    BIN_FILE="$INSTALL_DIR/dclear"
    BIN_DOCKER_FILE="$INSTALL_DIR/dclear-docker"
else
    # Remote installation mode - download to temp directory
    TMP_DIR=$(mktemp -d)
    BIN_FILE="$TMP_DIR/dclear"
    BIN_DOCKER_FILE="$TMP_DIR/dclear-docker"

    echo "Downloading dclear from GitHub..."
    if ! download_file "$REPO_URL/dclear" "$BIN_FILE"; then
        echo "Error: Failed to download dclear"
        rm -rf "$TMP_DIR"
        exit 1
    fi
    chmod +x "$BIN_FILE"

    echo "Downloading dclear-docker from GitHub..."
    download_file "$REPO_URL/dclear-docker" "$BIN_DOCKER_FILE"
    if [ -f "$BIN_DOCKER_FILE" ]; then
        chmod +x "$BIN_DOCKER_FILE"
    fi
fi

# Install main dclear script
if install_binary "$BIN_FILE" "dclear"; then
    main_installed="dclear"
fi

# Install dclear-docker script (optional)
if [ -f "$BIN_DOCKER_FILE" ]; then
    if install_binary "$BIN_DOCKER_FILE" "dclear-docker"; then
        docker_installed="dclear-docker"
    fi
fi

# Cleanup temp directory if it exists
if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
fi

# Check results
if [ -n "$main_installed" ]; then
    echo ""
    echo "Installation complete!"
    echo ""
    echo "Usage:"
    echo "  dclear              # Clean project dependencies"
    if [ -n "$docker_installed" ]; then
        echo "  dclear --docker     # Clean dependencies + Docker"
        echo "  dclear-docker       # Advanced Docker cleanup"
    fi
    echo ""
    exit 0
fi

# Installation failed
echo ""
echo "Error: Could not install dclear to any of: $binpaths"

if [ ! -w "/usr/local/bin" ] && [ ! -w "/usr/bin" ]; then
    echo ""
    echo "It seems that we do not have the necessary write permissions."
    echo "Try running this script as a privileged user:"
    echo ""
    echo "    curl -fsSL $REPO_URL/install.sh | sudo bash"
    echo ""
fi

exit 1
