# Wear OS Battery Optimization Guide

Debloating background services gives an immediate boost to RAM and responsiveness, but maximum battery life also comes from hardware and sensor configuration. Here are recommended settings for any Wear OS watch.

---

## 1. Display Settings (Largest Battery Factor)

* **Always-On Display (AOD)**:
  * Turning AOD **OFF** saves 20% to 35% of daily battery.
  * If you prefer keeping AOD on, use watch faces with low On-Pixel Ratio (OPR < 10%) and mostly true black backgrounds (`#000000` turns off OLED pixels).
* **Tilt-to-Wake (Raise wrist to wake)**:
  * Accelerometers continuously poll for wrist movements. Turn off Tilt-to-Wake if you frequently move your hands at a desk, and use *Touch-to-wake* or physical buttons instead.
* **Screen Timeout**:
  * Set to **15 seconds** (Settings → Display → Screen timeout).

---

## 2. Radios & Connectivity

* **Wi-Fi**:
  * Keep Wi-Fi on **Automatic** (or turn off when not needed). The watch automatically routes data via Bluetooth LE through your smartphone.
  * *CleanYourWatch* disables hidden background Wi-Fi and Bluetooth scanning (`wifi_scan_always_enabled=0`, `ble_scan_always_enabled=0`).
* **Location / GPS**:
  * Turn GPS on only during outdoor sports workouts. For daily steps, the internal pedometer does not require GPS.
* **NFC**:
  * NFC consumes minimal standby power, but if you don't use Mir Pay or Google Wallet, you can toggle it off in Settings → Connections → NFC.

---

## 3. Sensors & Health Tracking

* **Heart Rate Measurement**:
  * Changing continuous measurement to **"Every 10 minutes while still"** cuts sensor power by ~60% while still capturing accurate resting heart rate and sleep metrics.
* **Continuous SpO2 (Blood Oxygen) during sleep**:
  * Nighttime blood oxygen tracking pulses the red/infrared LED sensor continuously. Keep enabled only if tracking potential sleep apnea.
* **Auto-detect Workouts**:
  * In Samsung Health / Fitbit / Mi Fitness settings, turn off auto-detection for workouts you rarely do (elliptical, rowing, etc.) and keep only *Walking* or *Running*.

---

## 4. Voice Assistants

* **"Hey Google" / Bixby Hotword detection**:
  * Always-on microphone listening is one of the biggest CPU wakelock sources on Exynos and Snapdragon wearable chips.
  * CleanYourWatch disables unused voice assistants. If you keep Assistant, turn off hotword detection and assign it to a long-press of the home key.
