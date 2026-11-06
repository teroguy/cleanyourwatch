# Contributing to CleanYourWatch

We welcome contributions! Whether you have a Samsung Galaxy Watch, Google Pixel Watch, Xiaomi Watch, TicWatch, OnePlus Watch, or an unsupported Wear OS model, your contribution helps other users get better battery life and performance.

---

## Adding Support for a New Watch Model

If your watch manufacturer does not have a profile yet in `profiles/`:

1. Connect your watch via ADB (see [docs/HOW_TO_CONNECT.md](docs/HOW_TO_CONNECT.md)).
2. Run `tools/clean.sh` once. It will:
   - Identify your watch model and manufacturer.
   - Create a complete dump in `backup/<model>_<timestamp>/`:
     - `packages_all.txt`
     - `getprop.txt`
3. Inspect the packages:
   - Identify manufacturer bloatware, store demos, redundant telemetry, and OEM duplicate apps.
   - Cross-check against `tools/guards.txt` to make sure no core services are included.
4. Create a new file in `profiles/<manufacturer>.txt` (e.g. `profiles/fossil.txt` or `profiles/suunto.txt`).
5. Test it on your device and verify that all necessary features (notifications, steps, sleep, payments) work.
6. Open a Pull Request with your new profile and a brief test summary!

---

## Reporting Issues & Brick Prevention

* **Safety first**: If you discover that disabling a specific package causes instability, reboots, or sensor failures, open an issue immediately or submit a PR adding it to `tools/guards.txt`.
* When reporting an issue, please include:
  - Watch model (e.g., `Samsung Galaxy Watch 6 Classic 47mm BT`)
  - Wear OS and Android version
  - The package that caused the issue
  - Expected vs actual behavior
