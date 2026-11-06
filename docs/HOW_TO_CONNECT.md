# How to Connect Your Watch via Wireless ADB

Wear OS watches (Samsung Galaxy Watch, Google Pixel Watch, Xiaomi Watch, TicWatch, OnePlus Watch) do not have USB ports for direct cable connection. All debugging is done over Wi-Fi using Android Debug Bridge (ADB).

---

## 1. Prerequisites on Your Computer

Make sure `adb` is installed:
* **macOS**: `brew install android-platform-tools`
* **Linux**: `sudo apt install adb` (or your distribution's package manager)
* **Windows**: Download [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools) and add it to your PATH.

---

## 2. Enable Developer Options on Your Watch

1. On your watch, open **Settings** (⚙️).
2. Scroll to the bottom and tap **About watch** (or **About device**).
3. Tap **Software info** (on Samsung) or stay on About screen.
4. Tap **Software version** (or **Build number**) **7 times quickly** until you see the message *"Developer mode turned on"*.

---

## 3. Enable Wireless Debugging

> [!IMPORTANT]
> Your computer and your watch **must be connected to the same 2.4 GHz or 5 GHz Wi-Fi network**.
> While debugging, keep your watch on the charger or set Wi-Fi to **"Always on"** in watch Settings → Connections → Wi-Fi, because Wear OS automatically turns off Wi-Fi when Bluetooth to the phone is connected.

1. Go back to main **Settings** → open the newly appeared **Developer options** at the bottom.
2. Scroll down and turn on **ADB debugging**. Confirm the prompt.
3. Scroll further and tap **Wireless debugging** (toggle it ON).
4. Check the box *"Always allow on this network"* when prompted.

---

## 4. Pair and Connect

### Method A: Wear OS 4 / 5 (Android 13 / 14 / 15) with Pairing Code
Modern Wear OS uses dynamic TLS pairing:

1. In **Developer options** → **Wireless debugging**, tap **Pair new device** (or *Pair device with pairing code*).
2. You will see:
   - **Wi-Fi pairing code** (6 digits, e.g. `123456`)
   - **IP address & Port** (e.g. `192.168.1.150:41235`)
3. On your computer terminal, run:
   ```bash
   adb pair 192.168.1.150:41235
   # Enter the 6-digit pairing code when prompted
   ```
4. Now tap back to the **Wireless debugging** main screen and note the **IP address & Port** shown there (it will usually be a different port, e.g. `192.168.1.150:39841`).
5. Connect to it:
   ```bash
   adb connect 192.168.1.150:39841
   ```

### Method B: Older Wear OS (Port 5555)
If your watch shows a toggle *"Debug over Wi-Fi"*:
1. Turn on **Debug over Wi-Fi**.
2. Note the IP and port displayed (usually `192.168.1.xxx:5555`).
3. On your computer, run:
   ```bash
   adb connect 192.168.1.xxx:5555
   ```
4. Accept the *"Allow debugging from this computer?"* dialog on your watch screen.

---

## 5. Verify the Connection

Run:
```bash
adb devices -l
```
You should see your watch listed as `device`:
```text
List of devices attached
adb-RZAW803YHSM-04GEWW._adb-tls-connect._tcp device product:wisebl model:SM_R890
```

Now you are ready to run CleanYourWatch!
