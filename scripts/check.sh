#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ERRORS=0

echo "=================================="
echo "       NEXUS LINUX CHECKER"
echo "=================================="

check_file() {
    if [[ -s "$1" ]]; then
        echo "[OK] $1"
    else
        echo "[ERROR] Missing or empty: $1"
        ((ERRORS+=1))
    fi
}

check_contains() {
    local file="$1"
    local expected="$2"

    if grep -Fq -- "$expected" "$file"; then
        echo "[OK] Configuration: $expected"
    else
        echo "[ERROR] Missing configuration in $file: $expected"
        ((ERRORS+=1))
    fi
}

echo
echo "[1/5] Checking project files..."

check_file "README.md"
check_file "LICENSE"
check_file "docs/ARCHITECTURE.md"
check_file "scripts/build.sh"
check_file "scripts/check.sh"
check_file "config/package-lists/nexus-lite.list.chroot"

echo
echo "[2/5] Checking system configuration..."

check_file "config/includes.chroot/etc/hostname"
check_file "config/includes.chroot/etc/os-release"
check_file "config/includes.chroot/etc/issue"
check_file "config/includes.chroot/etc/motd"
check_file "config/includes.chroot/etc/apt/sources.list.d/debian.sources"
check_file "config/includes.chroot/etc/live/config.conf.d/10-user-setup.conf"

echo
echo "[3/5] Validating Nexus identity..."

if [[ -f "config/includes.chroot/etc/hostname" ]]; then
    check_contains "config/includes.chroot/etc/hostname" "nexus"
fi

if [[ -f "config/includes.chroot/etc/os-release" ]]; then
    check_contains "config/includes.chroot/etc/os-release" 'NAME="Nexus Linux"'
    check_contains "config/includes.chroot/etc/os-release" 'ID=nexus'
fi

if [[ -f "config/includes.chroot/etc/live/config.conf.d/10-user-setup.conf" ]]; then
    check_contains "config/includes.chroot/etc/live/config.conf.d/10-user-setup.conf" 'LIVE_USERNAME="nexus"'
fi

if [[ -e "config/includes.chroot/etc/live/config/user-setup.conf" ]]; then
    echo "[ERROR] Obsolete user-setup.conf path still exists."
    ((ERRORS+=1))
else
    echo "[OK] No obsolete user setup file."
fi

echo
echo "[4/5] Checking shell script syntax..."

while IFS= read -r -d '' file; do
    if bash -n "$file"; then
        echo "[OK] Syntax: $file"
    else
        echo "[ERROR] Syntax: $file"
        ((ERRORS+=1))
    fi
done < <(find scripts -type f -name "*.sh" -print0)

echo
echo "[5/5] Validating package list..."

PACKAGE_LIST="config/package-lists/nexus-lite.list.chroot"

if [[ -s "$PACKAGE_LIST" ]]; then
    if awk '
        /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
        {
            entry=$0
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", entry)

            if (entry !~ /^[A-Za-z0-9][A-Za-z0-9+.-]*$/) {
                print "[ERROR] Invalid package entry: " $0
                bad=1
            } else {
                count++
            }
        }
        END {
            if (count == 0) {
                print "[ERROR] No valid packages found."
                bad=1
            }
            exit bad
        }
    ' "$PACKAGE_LIST"; then
        echo "[OK] Package list is valid."
    else
        ((ERRORS+=1))
    fi
fi

echo
echo "=================================="

if [[ "$ERRORS" -eq 0 ]]; then
    echo "ALL CHECKS PASSED!"
    echo "Nexus Linux is ready for the next validation stage."
    exit 0
else
    echo "$ERRORS problem(s) found."
    exit 1
fi
