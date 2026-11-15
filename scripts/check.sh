
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ERRORS=0

echo "=================================="
echo "       NEXUS LINUX CHECKER"
echo "=================================="

# Check required files
check_file() {
    if [[ -s "$1" ]]; then
        echo "[OK] $1"
    else
        echo "[ERROR] Missing or empty: $1"
        ERRORS=$((ERRORS + 1))
    fi
}

echo
echo "Checking project files..."

check_file "README.md"
check_file "LICENSE"
check_file "docs/ARCHITECTURE.md"
check_file "config/package-lists/nexus-lite.list.chroot"
check_file "scripts/build.sh"

# Check shell scripts
echo
echo "Checking shell scripts..."

while IFS= read -r -d '' file; do
    if bash -n "$file"; then
        echo "[OK] Syntax: $file"
    else
        echo "[ERROR] Syntax: $file"
        ERRORS=$((ERRORS + 1))
    fi
done < <(find scripts -type f -name "*.sh" -print0)

# Check package list
echo
echo "Checking package list..."

PACKAGE_LIST="config/package-lists/nexus-lite.list.chroot"

if [[ -s "$PACKAGE_LIST" ]]; then
    if grep -Eq '^[[:space:]]*[a-zA-Z0-9][a-zA-Z0-9+.-]*[[:space:]]*$' "$PACKAGE_LIST"; then
        echo "[OK] Package entries found."
    else
        echo "[ERROR] No valid package entries found."
        ERRORS=$((ERRORS + 1))
    fi
fi

# Final result
echo
echo "=================================="

if [[ "$ERRORS" -eq 0 ]]; then
    echo "All checks passed!"
    exit 0
else
    echo "$ERRORS problem(s) found."
    exit 1
fi
