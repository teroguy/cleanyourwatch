#!/usr/bin/env bash
# ==============================================================================
# CleanYourWatch - Universal Package Restoration
# https://github.com/teroguy/cleanyourwatch
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BACKUP_DIR="${1:-}"

if [ -z "$BACKUP_DIR" ]; then
    # Pick the most recent backup folder
    LATEST_BACKUP=$(find "$REPO_ROOT/backup" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -r | head -n 1 || true)
    if [ -n "$LATEST_BACKUP" ]; then
        BACKUP_DIR="$LATEST_BACKUP"
    fi
fi

if [ -z "$BACKUP_DIR" ] || [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Error: No backup directory found or specified."
    echo "Usage: $0 [PATH_TO_BACKUP_DIR]"
    exit 1
fi

BACKUP_FILE="$BACKUP_DIR/packages_enabled.txt"
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: $BACKUP_FILE not found in $BACKUP_DIR"
    exit 1
fi

DEVICE="${2:-}"
if [ -z "$DEVICE" ]; then
    DEVICE=$(adb devices -l | grep -E "wisebl|SM[-_]R[0-9]+|watch|pixel|wear" | awk '{print $1}' | head -n 1 || true)
    if [ -z "$DEVICE" ]; then
        DEVICE=$(adb devices | grep -v "List of devices" | grep "device$" | head -n 1 | awk '{print $1}' || true)
    fi
fi

if [ -z "$DEVICE" ]; then
    echo "❌ Error: No Wear OS device found via ADB."
    exit 1
fi

echo "🔄 Restoring packages on device $DEVICE from:"
echo "   $BACKUP_DIR"

RESTORED=0
while read -r line; do
    pkg=$(echo "$line" | sed 's/^package://' | tr -d '\r\n ')
    if [ -n "$pkg" ]; then
        echo -n "Enabling: $pkg ... "
        res=$(adb -s "$DEVICE" shell pm enable "$pkg" 2>&1 || true)
        if [[ "$res" == *"enabled"* || "$res" == *"new state: enabled"* ]]; then
            echo "OK"
            ((RESTORED++))
        else
            echo "SKIPPED ($res)"
        fi
    fi
done < "$BACKUP_FILE"

echo "--------------------------------------------------------"
echo "✅ Restoration complete! Re-enabled: $RESTORED packages."
