#!/usr/bin/env bash
# ==============================================================================
# CleanYourWatch - System Performance & Battery Tweaks
# https://github.com/teroguy/cleanyourwatch
# ==============================================================================
set -euo pipefail

DEVICE="${1:-}"

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

echo "⚡ Applying performance & battery tweaks to: $DEVICE"

# 1. Faster UI Animations (0.5x scale)
echo -n "   Setting UI animation scale to 0.5x ... "
adb -s "$DEVICE" shell settings put global window_animation_scale 0.5
adb -s "$DEVICE" shell settings put global transition_animation_scale 0.5
adb -s "$DEVICE" shell settings put global animator_duration_scale 0.5
echo "OK"

# 2. Disable Background Wi-Fi & BLE Scanning for Location
echo -n "   Disabling always-on background Wi-Fi scanning ... "
adb -s "$DEVICE" shell settings put global wifi_scan_always_enabled 0
echo "OK"

echo -n "   Disabling always-on background BLE scanning ... "
adb -s "$DEVICE" shell settings put global ble_scan_always_enabled 0
echo "OK"

# 3. Disable Background App Crash & Error Reporting
echo -n "   Disabling automatic app error crash reporting ... "
adb -s "$DEVICE" shell settings put global send_action_app_error 0
echo "OK"

echo "✅ Tweaks applied successfully!"
