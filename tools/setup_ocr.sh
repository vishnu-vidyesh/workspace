#!/bin/bash

# Create the directory if it doesn't exist
mkdir -p "$HOME/bin/py"

# Create virtual environment
python3 -m venv "$HOME/bin/py/venv"

# Activate virtual environment and install requirements
source "$HOME/bin/py/venv/bin/activate"
pip install pillow pytesseract pyperclip
deactivate

# Create the OCR script
cat > "$HOME/bin/py/ocr" << 'EOL'
#!/bin/bash
# Activate virtual environment
source "$HOME/bin/py/venv/bin/activate"

# OCR Python script
python3 - << 'EOF'
import pytesseract
from PIL import Image, ImageGrab
import io
import sys
import os
import subprocess

def check_clipboard_tools():
    """Check if required clipboard tools are installed"""
    if os.getenv('WAYLAND_DISPLAY'):
        return subprocess.run(['which', 'wl-paste'], capture_output=True).returncode == 0
    else:
        return subprocess.run(['which', 'xclip'], capture_output=True).returncode == 0

def get_clipboard_image():
    """Get image from clipboard with proper tool detection"""
    try:
        if os.getenv('WAYLAND_DISPLAY'):
            # Wayland implementation
            result = subprocess.run(['wl-paste', '--list-types'], capture_output=True, text=True)
            if 'image/png' in result.stdout:
                img_data = subprocess.run(['wl-paste', '--type', 'image/png'], capture_output=True)
                return Image.open(io.BytesIO(img_data.stdout))
        else:
            # X11 implementation
            img = ImageGrab.grabclipboard()
            if img is not None:
                return img
        return None
    except Exception as e:
        print(f"Clipboard access error: {e}")
        return None

def main():
    print("Text Extraction from Image")
    print("1. Use image from clipboard")
    print("2. Specify image file path")
    choice = input("Choose option (1/2): ").strip()

    img = None
    if choice == '1':
        if not check_clipboard_tools():
            print("Error: Install wl-clipboard (Wayland) or xclip (X11) first")
            return
        img = get_clipboard_image()
    elif choice == '2':
        file_path = input("Enter image file path: ").strip('"\'')
        img = Image.open(file_path) if os.path.exists(file_path) else None
    else:
        print("Invalid choice!")
        return

    if img is not None:
        text = pytesseract.image_to_string(img)
        print("\nExtracted Text:")
        print("="*50)
        print(text.strip())
        print("="*50)

if __name__ == "__main__":
    main()
EOF
EOL

# Make the script executable
chmod +x "$HOME/bin/py/ocr"

# Add to PATH if not already present
if [[ ":$PATH:" != *":$HOME/bin/py:"* ]]; then
    echo "export PATH=\"\$HOME/bin/py:\$PATH\"" >> "$HOME/.bashrc"
    echo "Added $HOME/bin/py to PATH in .bashrc"
fi

# Add virtualenv activation to .bashrc if not present
if ! grep -q "source \$HOME/bin/py/venv/bin/activate" "$HOME/.bashrc"; then
    echo "source \$HOME/bin/py/venv/bin/activate" >> "$HOME/.bashrc"
    echo "Added virtualenv activation to .bashrc"
fi

# Install system dependencies
echo "Installing system dependencies..."
sudo apt update
sudo apt install -y tesseract-ocr wl-clipboard xclip python3-venv

echo ""
echo "Setup complete!"
echo "You can now run the OCR tool by typing 'ocr' in your terminal"
echo "You may need to restart your terminal or run 'source ~/.bashrc'"
