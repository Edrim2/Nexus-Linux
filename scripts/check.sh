
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ERRORS=0

check_file() {
    if [[ -s "$1" ]]; then
        echo "[OK] $1"
    else
        echo "[ERROR] Missing or empty: $1"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "=================================="
echo "       NEXUS LINUX CHECKER"
echo "=================================="

# Required project files
check_file "README.md"
check_file "LICENSE"
check_file "docs/ARCHITECTURE.md"
check_file "config/package-lists/nexus-lite.list.chroot"
check_file "scripts/build.sh"

# Validate shell scripts
echo
echo "Checking shell scripts..."

while IFS= read -r -d '' file; do
    if bash -n "$file"; then
        echo "[OK] Syntax: $file"
    else
        echo "[ERROR] Shell syntax: $file"
        ERRORS=$((ERRORS + 1))
    fi
done < <(find scripts -type f -name "*.sh" -print0)

# Validate package list
echo
echo "Checking package list..."

PACKAGE_LIST="config/package-lists/nexus-lite.list.chroot"

if [[ -s "$PACKAGE_LIST" ]]; then
    if grep -Eq '^[[:space:]]*[a-zA-Z0-9][a-zA-Z0-9+.-]*[[:space:]]*$' "$PACKAGE_LIST"; then
        echo "[OK] Package list contains package entries."
    else
        echo "[ERROR] No valid package entries found."
        ERRORS=$((ERRORS + 1))
    fi
fi

echo
echo "=================================="

if [[ "$ERRORS" -eq 0 ]]; then
    echo "All basic checks passed!"
    exit 0
else
    echo "$ERRORS problem(s) found."
    exit 1
fi
