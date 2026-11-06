#!/usr/bin/env bash
# ==============================================================================
# CleanYourWatch - Smart Wear OS Debloat & Optimization
# https://github.com/teroguy/cleanyourwatch
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GUARDS_FILE="$SCRIPT_DIR/guards.txt"
PROFILES_DIR="$REPO_ROOT/profiles"

# --- 1. Find Connected Device ---
DEVICE="${1:-}"

if [ -z "$DEVICE" ]; then
    # Look for devices with wear characteristics or known watch models
    DEVICE=$(adb devices -l | grep -E "wisebl|SM[-_]R[0-9]+|watch|pixel|wear" | awk '{print $1}' | head -n 1 || true)
    
    if [ -z "$DEVICE" ]; then
        # Fallback to the first non-TV active adb device
        DEVICE=$(adb devices | grep -v "List of devices" | grep "device$" | grep -v ":5555" | head -n 1 | awk '{print $1}' || true)
    fi

    if [ -z "$DEVICE" ]; then
        # If still empty, grab any attached device
        DEVICE=$(adb devices | grep -v "List of devices" | grep "device$" | head -n 1 | awk '{print $1}' || true)
    fi
fi

if [ -z "$DEVICE" ]; then
    echo "❌ Error: No Wear OS device found via ADB."
    echo "Make sure Wireless Debugging is enabled on your watch and connected."
    echo "Usage: $0 [DEVICE_ID_OR_IP:PORT]"
    exit 1
fi

echo "⌚ Target device: $DEVICE"

# --- 2. Query Device Info ---
MANUFACTURER=$(adb -s "$DEVICE" shell getprop ro.product.manufacturer 2>/dev/null | tr -d '\r\n' | tr '[:upper:]' '[:lower:]' || echo "unknown")
MODEL=$(adb -s "$DEVICE" shell getprop ro.product.model 2>/dev/null | tr -d '\r\n' || echo "unknown")
RELEASE=$(adb -s "$DEVICE" shell getprop ro.build.version.release 2>/dev/null | tr -d '\r\n' || echo "unknown")

echo "📱 Manufacturer: $MANUFACTURER"
echo "🔍 Model:        $MODEL"
echo "⚙️  Android/OS:   Wear OS (Android $RELEASE)"
echo "--------------------------------------------------------"

# --- 3. Create Full System Backup ---
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SAFE_MODEL=$(echo "$MODEL" | tr ' /' '_')
BACKUP_DIR="$REPO_ROOT/backup/${SAFE_MODEL}_${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"

echo "📦 Creating system backup in: backup/${SAFE_MODEL}_${TIMESTAMP}/"

adb -s "$DEVICE" shell pm list packages > "$BACKUP_DIR/packages_all.txt" 2>/dev/null || true
adb -s "$DEVICE" shell pm list packages -e > "$BACKUP_DIR/packages_enabled.txt" 2>/dev/null || true
adb -s "$DEVICE" shell pm list packages -d > "$BACKUP_DIR/packages_disabled.txt" 2>/dev/null || true
adb -s "$DEVICE" shell getprop > "$BACKUP_DIR/getprop.txt" 2>/dev/null || true
adb -s "$DEVICE" shell settings list global > "$BACKUP_DIR/settings_global.txt" 2>/dev/null || true
adb -s "$DEVICE" shell settings list secure > "$BACKUP_DIR/settings_secure.txt" 2>/dev/null || true
adb -s "$DEVICE" shell settings list system > "$BACKUP_DIR/settings_system.txt" 2>/dev/null || true

# Generate standalone restore script inside the backup directory
cat << 'EOF' > "$BACKUP_DIR/restore.sh"
#!/usr/bin/env bash
set -euo pipefail
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICE="${1:-}"

if [ -z "$DEVICE" ]; then
    DEVICE=$(adb devices | grep -v "List of devices" | grep "device$" | head -n 1 | awk '{print $1}')
fi

echo "Restoring packages on device $DEVICE from $BACKUP_DIR..."
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
done < "$BACKUP_DIR/packages_enabled.txt"

echo "Restoration complete. Re-enabled: $RESTORED packages."
EOF
chmod +x "$BACKUP_DIR/restore.sh"

echo "✅ Backup completed successfully."
echo "--------------------------------------------------------"

# --- 4. Select Profile Lists ---
COMMON_LIST="$PROFILES_DIR/common.txt"
VENDOR_LIST="$PROFILES_DIR/${MANUFACTURER}.txt"

TARGET_LISTS=()
if [ -f "$COMMON_LIST" ]; then
    TARGET_LISTS+=("$COMMON_LIST")
fi

if [ -f "$VENDOR_LIST" ]; then
    echo "📋 Loaded vendor profile: profiles/${MANUFACTURER}.txt"
    TARGET_LISTS+=("$VENDOR_LIST")
else
    echo "⚠️  No pre-configured profile found for manufacturer '$MANUFACTURER'."
    echo "ℹ️  Only common Wear OS debloat will be applied."
    echo "ℹ️  Please consider contributing your backup folder to https://github.com/teroguy/cleanyourwatch!"
fi

# Load Safety Guards into an associative array / lookup
declare -A GUARDS
if [ -f "$GUARDS_FILE" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        clean_guard=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        [[ -z "$clean_guard" || "$clean_guard" =~ ^# ]] && continue
        GUARDS["$clean_guard"]=1
    done < "$GUARDS_FILE"
fi

# --- 5. Perform Debloat ---
echo "🚀 Starting safe package disabling (pm disable-user)..."
DISABLED_COUNT=0
GUARDED_COUNT=0
SKIPPED_COUNT=0

for list_file in "${TARGET_LISTS[@]}"; do
    echo "--- Applying: $(basename "$list_file") ---"
    while IFS= read -r line || [ -n "$line" ]; do
        pkg=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

        # Guard Check
        if [[ -n "${GUARDS[$pkg]:-}" ]]; then
            echo "🛡️  PROTECTED by guard list: $pkg (skipped)"
            ((GUARDED_COUNT++))
            continue
        fi

        echo -n "Disabling: $pkg ... "
        res=$(adb -s "$DEVICE" shell pm disable-user --user 0 "$pkg" < /dev/null 2>&1 || true)
        if [[ "$res" == *"disabled"* || "$res" == *"new state: disabled"* ]]; then
            echo "OK"
            ((DISABLED_COUNT++))
        else
            echo "SKIPPED/NOT_FOUND ($res)"
            ((SKIPPED_COUNT++))
        fi
    done < "$list_file"
done

echo "========================================================"
echo "🎉 Debloat finished!"
echo "   Disabled packages: $DISABLED_COUNT"
echo "   Guarded packages:  $GUARDED_COUNT"
echo "   Skipped/Not found: $SKIPPED_COUNT"
echo "========================================================"

# --- 6. Prompt or Auto-Apply Tweaks ---
read -p "Apply system performance and battery tweaks now? (y/n) [default: y]: " APPLY_TWEAKS || APPLY_TWEAKS="y"
APPLY_TWEAKS="${APPLY_TWEAKS:-y}"
if [[ "$APPLY_TWEAKS" =~ ^[Yy]$ ]]; then
    "$SCRIPT_DIR/apply_tweaks.sh" "$DEVICE"
fi

echo ""
echo "✨ All done! Your watch is now clean and optimized."
echo "💡 To restore everything anytime, run: tools/restore.sh or backup/${SAFE_MODEL}_${TIMESTAMP}/restore.sh"
