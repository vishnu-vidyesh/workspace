#!/bin/bash

# Define the grepf function
GREPF_FUNCTION='
grepf() {
    # Show help if no args or --help/-h
    if [[ $# -eq 0 || "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: grepf PATTERN [FILE(S)|DIR] [grep-OPTIONS]"
        echo "Search for PATTERN in .v files (recursive with -r)."
        echo ""
        echo "Examples:"
        echo "  grepf \"RS_STATIC_BYPASS\"       # Search in current dir .v files"
        echo "  grepf \"pattern\" -r .           # Recursive search"
        echo "  grepf \"foo\" -i *.v             # Case-insensitive in specific .v files"
        return 0
    fi

    # Actual grep command
    local pattern="$1"
    shift
    grep "$pattern" --include="*.v" "$@"
}
'

# Check if grepf already exists in ~/.bashrc
if ! grep -q "grepf()" ~/.bashrc; then
    echo "Adding grepf to ~/.bashrc..."
    echo "$GREPF_FUNCTION" >> ~/.bashrc
    source ~/.bashrc
    echo "Installed! Try: grepf --help"
else
    echo "grepf already exists in ~/.bashrc. Skipping install."
fi
