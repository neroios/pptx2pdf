#!/bin/bash
set -e

SCRIPT_NAME="pptx2pdf"
INSTALL_DIR="${HOME}/.local/bin"

echo "Uninstalling ${SCRIPT_NAME}..."

rm -f "${INSTALL_DIR}/${SCRIPT_NAME}"
echo "Removed: ${INSTALL_DIR}/${SCRIPT_NAME}"

echo "Done. You may also want to uninstall LibreOffice if no longer needed."
