#!/bin/bash
set -e

SCRIPT_NAME="pptx2pdf"
INSTALL_DIR="${HOME}/.local/bin"

echo "Uninstalling ${SCRIPT_NAME}..."

rm -f "${INSTALL_DIR}/${SCRIPT_NAME}"
echo "Removed: ${INSTALL_DIR}/${SCRIPT_NAME}"

echo ""
echo "Optional: remove Python dependencies if no longer needed:"
echo "  pip3 uninstall python-pptx img2pdf -y"
echo ""
echo "Optional: remove LibreOffice if no longer needed:"
echo "  (use your package manager, e.g. sudo pacman -Rns libreoffice-fresh)"
echo ""
echo "Done."
