#!/bin/bash
#
# PermGuard Installer
# One-line install: curl -sL https://raw.githubusercontent.com/SaharshPamecha/permguard/main/install.sh | sudo bash
#

set -e

REPO_URL="https://raw.githubusercontent.com/SaharshPamecha/permguard/main"
INSTALL_DIR="/usr/local/bin"
TOOL_NAME="permguard"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              PERMGUARD INSTALLER                          ║"
echo "║       Fleet Script Permission Auditor & Enforcer         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [[ $EUID -ne 0 ]]; then
   echo "⚠️  Warning: This installer needs root privileges"
   echo "   Run: curl -sL ... | sudo bash"
   exit 1
fi

echo "📦 Installing permguard..."
echo ""

if command -v curl &> /dev/null; then
    curl -fsSL "${REPO_URL}/cli/permguard" -o "${INSTALL_DIR}/${TOOL_NAME}"
elif command -v wget &> /dev/null; then
    wget -q "${REPO_URL}/cli/permguard" -O "${INSTALL_DIR}/${TOOL_NAME}"
else
    echo "❌ Error: curl or wget is required"
    exit 1
fi

chmod +x "${INSTALL_DIR}/${TOOL_NAME}"

if "${INSTALL_DIR}/${TOOL_NAME}" help &>/dev/null; then
    echo ""
    echo "✅ Installation successful!"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "   Get started:"
    echo ""
    echo "   # Scan for permission issues"
    echo "   permguard scan"
    echo ""
    echo "   # Apply fixes (requires root)"
    echo "   sudo permguard enforce /opt"
    echo ""
    echo "   # Generate compliance report"
    echo "   permguard report"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "   Documentation: https://github.com/SaharshPamecha/permguard"
    echo "   Live Demo:     https://permguard.vercel.app"
    echo ""
else
    echo "❌ Installation verification failed"
    exit 1
fi
