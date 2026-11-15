
#!/usr/bin/env bash
set -Eeuo pipefail

# Nexus Linux - Build System

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

DEBIAN_SUITE="${DEBIAN_SUITE:-trixie}"
ARCHITECTURE="amd64"

echo "=================================="
echo "       NEXUS LINUX BUILDER"
echo "=================================="

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Run this script as root."
    echo "Example: sudo bash scripts/build.sh"
    exit 1
fi

if ! command -v lb >/dev/null 2>&1; then
    echo "ERROR: live-build is not installed."
    echo "Install: apt install live-build"
    exit 1
fi

if [[ ! -s config/package-lists/nexus-lite.list.chroot ]]; then
    echo "ERROR: Nexus Lite package list is missing."
    exit 1
fi

echo "[1/3] Cleaning previous build..."
lb clean

echo "[2/3] Configuring Debian Live..."

lb config \
    --distribution "$DEBIAN_SUITE" \
    --architectures "$ARCHITECTURE" \
    --binary-images iso-hybrid \
    --archive-areas "main contrib non-free non-free-firmware"

echo "[3/3] Building Nexus Linux..."

lb build

echo "=================================="
echo "       BUILD FINISHED"
echo "=================================="
