
#!/usr/bin/env bash
set -Eeuo pipefail

# Nexus Linux - Build Script

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=================================="
echo "       NEXUS LINUX BUILDER"
echo "=================================="

# Check root permissions
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Run this script as root."
    echo "Example: sudo bash scripts/build.sh"
    exit 1
fi

# Check live-build installation
if ! command -v lb >/dev/null 2>&1; then
    echo "ERROR: live-build is not installed."
    echo "Install it with: apt install live-build"
    exit 1
fi

# Check package list
PACKAGE_LIST="config/package-lists/nexus-lite.list.chroot"

if [[ ! -s "$PACKAGE_LIST" ]]; then
    echo "ERROR: Nexus Lite package list not found."
    exit 1
fi

echo "[1/2] Configuring Debian Live..."

lb config \
    --distribution stable \
    --architectures amd64 \
    --binary-images iso-hybrid \
    --archive-areas "main contrib non-free non-free-firmware"

echo "[2/2] Building Nexus Linux..."
lb build

echo "=================================="
echo "       BUILD FINISHED"
echo "=================================="
echo "Check the project directory for the generated ISO."
