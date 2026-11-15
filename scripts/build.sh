
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

# Check root permissions
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Run this script as root."
    echo "Example: sudo bash scripts/build.sh"
    exit 1
fi

# Check dependencies
if ! command -v lb >/dev/null 2>&1; then
    echo "ERROR: live-build is not installed."
    echo "Install it with: apt install live-build"
    exit 1
fi

# Check required configuration
if [[ ! -s config/package-lists/nexus-lite.list.chroot ]]; then
    echo "ERROR: Nexus Lite package list is missing."
    exit 1
fi

echo "[1/4] Cleaning previous build..."
lb clean

echo "[2/4] Configuring Debian Live..."

lb config \
    --distribution "$DEBIAN_SUITE" \
    --architectures "$ARCHITECTURE" \
    --binary-images iso-hybrid \
    --archive-areas "main contrib non-free non-free-firmware"

echo "[3/4] Building Nexus Linux..."

lb build

echo "[4/4] Verifying generated ISO..."

shopt -s nullglob
ISO_FILES=( ./*.iso )

if [[ ${#ISO_FILES[@]} -eq 0 ]]; then
    echo "ERROR: No ISO file was generated."
    exit 1
fi

for iso in "${ISO_FILES[@]}"; do
    if [[ ! -s "$iso" ]]; then
        echo "ERROR: ISO file is empty: $iso"
        exit 1
    fi

    echo "[OK] ISO generated: $iso"
    ls -lh "$iso"
done

echo "=================================="
echo "       BUILD FINISHED"
echo "=================================="
echo "Nexus Linux ISO build completed."
