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

has_cmd() { command -v "$1" &>/dev/null; }

install_pkgs() {
    if has_cmd apt; then
        sudo apt update -qq
        sudo apt install -y "$@"
    elif has_cmd dnf; then
        sudo dnf install -y "$@"
    elif has_cmd yum; then
        sudo yum install -y "$@"
    elif has_cmd pacman; then
        sudo pacman -S --noconfirm "$@"
    elif has_cmd zypper; then
        sudo zypper install -y "$@"
    elif has_cmd apk; then
        sudo apk add "$@"
    else
        return 1
    fi
    return 0
}

if has_cmd libreoffice || has_cmd soffice; then
    echo "[1/5] LibreOffice: found"
else
    echo "[1/5] Installing LibreOffice..."
    lo_pkg="libreoffice-impress libreoffice-draw"
    has_cmd pacman && lo_pkg="libreoffice-fresh"
    has_cmd apk && lo_pkg="libreoffice"
    install_pkgs $lo_pkg || echo "  -> Install LibreOffice manually from https://libreoffice.org"
fi

echo "[2/5] Installing poppler-utils (pdftoppm)..."
if has_cmd pdftoppm; then
    echo "  -> found"
else
    poppler_pkg="poppler-utils"
    has_cmd pacman && poppler_pkg="poppler"
    install_pkgs "$poppler_pkg" || echo "  -> Install poppler-utils manually for --faithful mode"
fi

echo "[3/5] Installing Microsoft-compatible fonts..."
font_pkg="fonts-liberation fonts-crosextra-carlito fonts-crosextra-caladea"
has_cmd pacman && font_pkg="ttf-liberation ttf-croscore"
install_pkgs $font_pkg 2>/dev/null && echo "  -> installed" || echo "  -> skipped (not critical)"

echo "[4/5] Installing ${SCRIPT_NAME}..."
mkdir -p "${INSTALL_DIR}"
if [ ! -f "${SCRIPT_SOURCE}" ]; then
    echo "Error: ${SCRIPT_SOURCE} not found. Run this script from the project folder."
    exit 1
fi
cp "${SCRIPT_SOURCE}" "${SCRIPT_TARGET}"
chmod +x "${SCRIPT_TARGET}"

echo "[5/5] Installing Python dependencies (python-pptx, img2pdf, pillow)..."
if has_cmd pip3; then
    pip3 install --user --break-system-packages python-pptx img2pdf 2>/dev/null \
        || pip3 install --user python-pptx img2pdf 2>/dev/null \
        || echo "  -> Run: pip3 install --user python-pptx img2pdf"
    echo "  -> done"
else
    echo "  -> pip3 not found. Install Python 3 and run: pip3 install --user python-pptx img2pdf"
fi

add_to_path() {
    local shell_rc
    case "$SHELL" in
        */zsh) shell_rc="${HOME}/.zshrc" ;;
        */bash) shell_rc="${HOME}/.bashrc" ;;
        */fish) shell_rc="${HOME}/.config/fish/config.fish" ;;
        *) shell_rc="${HOME}/.profile" ;;
    esac
    if ! echo "$PATH" | tr ':' '\n' | grep -qx "${INSTALL_DIR}"; then
        echo "[+] Adding ${INSTALL_DIR} to PATH in ${shell_rc}..."
        case "$SHELL" in
            */fish) echo "fish_add_path ${INSTALL_DIR}" >> "${shell_rc}" ;;
            *) echo "export PATH=\"\${PATH}:${INSTALL_DIR}\"" >> "${shell_rc}" ;;
        esac
        echo "  -> Please restart your terminal or run: source ${shell_rc}"
    else
        echo "[+] ${INSTALL_DIR} already in PATH"
    fi
}
add_to_path

echo ""
echo "============================================"
echo "  Installation complete!"
echo ""
echo "  Usage:"
echo "    pptx2pdf arquivo.pptx"
echo "    pptx2pdf *.pptx --delete"
echo "    pptx2pdf --fresh arquivo.pptx"
echo "    pptx2pdf --faithful arquivo.pptx"
echo "    pptx2pdf --help"
echo ""
echo "  Docs:  cat $(dirname "$0")/HOWTO.md"
echo "============================================"
