# CleanYourWatch - AI Assistant Prompt

Paste this prompt into your coding assistant (Antigravity CLI, Claude Code, Cursor, Codex) to interactively debloat and optimize your Wear OS smartwatch.

---

```markdown
I want to optimize and debloat my Wear OS smartwatch using the CleanYourWatch repository.
My watch is connected via Wireless ADB.

Follow these strict principles:
1. Work directly on the connected device via ADB step-by-step.
2. Auto-detect the connected watch model, manufacturer, and Android version.
3. Safety First:
   - Create a full backup in `backup/<model>_<timestamp>/` before modifying anything.
   - NEVER uninstall system packages. Use `pm disable-user --user 0` only.
   - Strictly check against `tools/guards.txt` and NEVER disable any protected core framework packages.
4. Interactive Profiling:
   - Ask me what services I actually use before disabling:
     * Voice Assistants (Google Assistant, Bixby)
     * Contactless Payments (Google Wallet, Mir Pay, Samsung Pay)
     * Health Tracking specifics (Do I need sleep, steps, ECG, continuous heart rate?)
     * Companion apps (Galaxy Buds, Home Assistant, WhatsApp, Music players)
5. Load the appropriate vendor profile from `profiles/<manufacturer>.txt` combined with `profiles/common.txt`.
6. Apply system performance tweaks:
   - Window animation scales at 0.5x
   - Disable background Wi-Fi and BLE location scanning (`wifi_scan_always_enabled=0`, `ble_scan_always_enabled=0`)
   - Disable crash reporting (`send_action_app_error=0`)
7. Output a concise summary of freed RAM and disabled services, and provide the command to restore everything in one click.
```
