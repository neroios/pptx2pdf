#!/bin/bash
set -e

INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_NAME="pptx2pdf"
SCRIPT_SOURCE="$(dirname "$0")/${SCRIPT_NAME}.py"
SCRIPT_TARGET="${INSTALL_DIR}/${SCRIPT_NAME}"

echo "============================================"
echo "  pptx2pdf - Cross-Platform PPTX/PDF Converter"
echo "============================================"
echo ""

# ---- Detect distro and install LibreOffice if missing ----
install_libreoffice() {
    echo "[1/3] Installing LibreOffice..."
    if command -v apt &>/dev/null; then
        sudo apt update -qq && sudo apt install -y libreoffice-impress libreoffice-draw
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y libreoffice-impress libreoffice-draw
    elif command -v yum &>/dev/null; then
        sudo yum install -y libreoffice-impress libreoffice-draw
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm libreoffice-fresh
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y libreoffice-impress libreoffice-draw
    elif command -v apk &>/dev/null; then
        sudo apk add libreoffice
    else
        echo "Warning: Could not detect package manager."
        echo "Please install LibreOffice manually from https://libreoffice.org"
        read -rp "Press Enter after installing LibreOffice..."
    fi
}

if command -v libreoffice &>/dev/null || command -v soffice &>/dev/null; then
    echo "[1/3] LibreOffice: found"
else
    install_libreoffice
fi

# ---- Copy script ----
echo "[2/3] Installing ${SCRIPT_NAME}..."
mkdir -p "${INSTALL_DIR}"

if [ ! -f "${SCRIPT_SOURCE}" ]; then
    echo "Error: ${SCRIPT_SOURCE} not found. Run this script from the project folder."
    exit 1
fi

cp "${SCRIPT_SOURCE}" "${SCRIPT_TARGET}"
chmod +x "${SCRIPT_TARGET}"

# ---- Add to PATH if not already ----
add_to_path() {
    local shell_rc
    case "$SHELL" in
        */zsh) shell_rc="${HOME}/.zshrc" ;;
        */bash) shell_rc="${HOME}/.bashrc" ;;
        */fish) shell_rc="${HOME}/.config/fish/config.fish" ;;
        *) shell_rc="${HOME}/.profile" ;;
    esac

    if ! echo "$PATH" | tr ':' '\n' | grep -qx "${INSTALL_DIR}"; then
        echo "[3/3] Adding ${INSTALL_DIR} to PATH in ${shell_rc}..."
        case "$SHELL" in
            */fish)
                echo "fish_add_path ${INSTALL_DIR}" >> "${shell_rc}"
                ;;
            *)
                echo "export PATH=\"\${PATH}:${INSTALL_DIR}\"" >> "${shell_rc}"
                ;;
        esac
        echo "  -> Please restart your terminal or run: source ${shell_rc}"
    else
        echo "[3/3] ${INSTALL_DIR} already in PATH"
    fi
}

add_to_path

echo ""
echo "============================================"
echo "  Installation complete!"
echo "  Usage:  ${SCRIPT_NAME} arquivo.pptx"
echo "          ${SCRIPT_NAME} *.pptx ./pdfs --delete"
echo "          ${SCRIPT_NAME} arquivo.pdf"
echo "============================================"
