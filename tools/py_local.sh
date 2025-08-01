#!/bin/bash

# Configuration
PYTHON_VERSION="3.10.13"  # Change to desired version
INSTALL_DIR="$HOME/.local/python-${PYTHON_VERSION}"
BUILD_DIR="/tmp/python-build-${PYTHON_VERSION}"

echo "======================================"
echo " Installing Python $PYTHON_VERSION locally"
echo "======================================"

# Create installation directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Download Python
echo "Downloading Python ${PYTHON_VERSION}..."
curl -L -O "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz" || {
    echo "Failed to download Python"; exit 1
}

# Extract and build
echo "Extracting and building Python..."
tar xzf "Python-${PYTHON_VERSION}.tgz"
cd "Python-${PYTHON_VERSION}"

./configure --prefix="$INSTALL_DIR" --enable-optimizations
make -j$(nproc)
make install

# Add to PATH
if ! grep -q "$INSTALL_DIR/bin" "$HOME/.bashrc"; then
    echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$HOME/.bashrc"
    echo "Added Python to PATH in .bashrc"
fi

# Verify installation
source "$HOME/.bashrc"
echo ""
echo "Installation complete!"
echo "Python ${PYTHON_VERSION} installed to: $INSTALL_DIR"
echo "Restart your terminal or run: source ~/.bashrc"
echo "Verify with: python3 --version"
