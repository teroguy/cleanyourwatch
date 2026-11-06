# CleanYourWatch ⌚

<p align="center">
  <b>Your smartwatch, minus the bloat.</b><br>
  Strip telemetry, heavy background services, and battery drains from any Wear OS smartwatch over Wi-Fi.<br>
  <b>No root · No cables · Nothing uninstalled · One-line instant restore</b>
</p>

<p align="center">
  <a href="README.ru.md">🇷🇺 Читать на русском</a> · <a href="#supported-watches">Supported Watches</a> · <a href="#quick-start">Quick Start</a> · <a href="#how-it-works">How It Works</a> · <a href="#restoring">Restoring</a>
</p>

---

## ⚡ What You Get

| | Stock Wear OS | With CleanYourWatch |
|---|---|---|
| **RAM Usage** | 80–90% full, frequent background app kills | **75–100+ MB freed RAM** for apps you actually use |
| **Interface Speed** | Micro-stutters and delayed swipe response | **Instant 0.5x UI response**, buttery-smooth animations |
| **Standby Drain** | Radios poll for Wi-Fi/BLE in background | **Dormant sleep**, unnecessary wakelocks eliminated |
| **Telemetry & Ads** | Privacy Sandbox, DiagMon, OEM analytics active | **Zero telemetry**, diagnostic daemons silenced |
| **Safety & Reversibility** | Modding risks bootloops | **100% reversible** with automatic backup & restore script |

> [!NOTE]
> **Preserved by design**: Step tracking, sleep monitoring, heart rate, phone call sync, notifications, and contactless payments (**Google Wallet** and **Mir Pay**) remain fully functional!

---

## ⌚ Supported Watches

| Manufacturer | Models | Status | Profile |
|---|---|---|---|
| **Samsung** | Galaxy Watch 4 / 5 / 6 / 7 / Ultra (One UI Watch) | ✅ Tested & Verified | [`profiles/samsung.txt`](profiles/samsung.txt) |
| **Google** | Pixel Watch 1 / 2 / 3 | ✅ Supported | [`profiles/google.txt`](profiles/google.txt) |
| **Xiaomi** | Xiaomi Watch 2 / 2 Pro | ✅ Supported | [`profiles/xiaomi.txt`](profiles/xiaomi.txt) |
| **Mobvoi** | TicWatch Pro 3 / 5 / Enduro | ✅ Supported | [`profiles/mobvoi.txt`](profiles/mobvoi.txt) |
| **OnePlus / Oppo** | OnePlus Watch 2 / 2R, Oppo Watch X | ✅ Supported | [`profiles/oneplus.txt`](profiles/oneplus.txt) |
| **Other Wear OS** | Fossil Gen 6, Montblanc, Suunto, etc. | 🔍 Discovery Mode | Universal Common Profile |

---

## 🚀 Quick Start

### Step 1: Connect your watch over Wi-Fi
1. Turn on **Developer options** on your watch (tap *Build number* 7 times in *About watch*).
2. Enable **ADB debugging** and **Wireless debugging**.
3. Pair or connect your computer via ADB (detailed walkthrough: **[docs/HOW_TO_CONNECT.md](docs/HOW_TO_CONNECT.md)**):
   ```bash
   adb connect <WATCH_IP>:<PORT>
   ```

### Step 2: Run CleanYourWatch

Clone this repository and run the automated optimization script:

```bash
git clone https://github.com/teroguy/cleanyourwatch.git
cd cleanyourwatch
./tools/clean.sh
```

The script will automatically:
1. Detect your watch model and manufacturer.
2. Create a complete system backup in `backup/<model>_<timestamp>/`.
3. Check safety guards in `tools/guards.txt` (to guarantee bootloop prevention).
4. Safely disable OEM bloatware and background telemetry via `pm disable-user`.
5. Apply performance tweaks (0.5x animations, disabling background Wi-Fi/BLE scanning).

---

## 🤖 Using with AI Assistants

You can run CleanYourWatch interactively with **Antigravity CLI**, **Claude Code**, or **Cursor**:
1. Open this repository in your assistant.
2. Paste the instructions from **[`PROMPT.md`](PROMPT.md)**.
3. The assistant will discover your watch, ask which features you need (smart home, voice assistants, specific fitness tracking), and tailor the optimization directly to your lifestyle.

---

## 🛡️ How It Works

* **Safe disabling (`pm disable-user --user 0`)**: No files or APKs are deleted from `/system`. Packages are merely frozen for user 0. If you ever update firmware or factory reset, everything remains intact.
* **Safety Guards (`tools/guards.txt`)**: A hard-coded guard list prevents touching essential Wear OS components (rotary/bezel inputs, Bluetooth daemon, core SystemUI, and sensor frameworks).
* **Vendor Profiles**: Automatic detection loads manufacturer-specific profiles (e.g. Bixby and Knox for Samsung, Mobvoi Appstore for TicWatch).

---

## 🔄 Restoring Your Watch

If you ever want to re-enable all original packages, run the restore script:

```bash
./tools/restore.sh
```

Or restore a specific snapshot directly from its generated backup:
```bash
./backup/<your_watch_model_date>/restore.sh
```

---

## 📚 Guides & Documentation

* **[How to Connect via Wireless ADB](docs/HOW_TO_CONNECT.md)** — Step-by-step connection guide for Wear OS 3, 4, and 5.
* **[Wear OS Battery Optimization Guide](docs/BATTERY_GUIDE.md)** — Best practices for AOD, tilt-to-wake, sensors, and display settings.
* **[Contributing Guide](CONTRIBUTING.md)** — How to submit dumps and add profiles for new watch brands.

---

## License

MIT © [CleanYourWatch Contributors](https://github.com/teroguy/cleanyourwatch)
