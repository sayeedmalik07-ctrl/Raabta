# Raabta notification sounds

Custom audio is **not bundled** yet. Add these files before the signature chime plays on device:

| Platform | Path | Format |
|----------|------|--------|
| iOS (app bundle) | `ios/Runner/raabta_notification.caf` | CAF, &lt; 1.5 s |
| iOS urgent | `ios/Runner/raabta_urgent.caf` | CAF, &lt; 2 s |
| Android | `android/app/src/main/res/raw/raabta_notification.mp3` | MP3 or WAV |
| Android urgent | `android/app/src/main/res/raw/raabta_urgent.mp3` | MP3 or WAV |
| Optional source | `assets/sounds/raabta_notification.caf` | Reference copy |

After adding iOS files, open `ios/Runner.xcworkspace` in Xcode and ensure both `.caf` files are included in the **Runner** target (Copy Bundle Resources).

Sound design brief: short (under 1.5 s), modern two-to-three-note chime or soft swoosh + tone — purple/gold/cyan premium fintech feel (Zomato-style instant recognition). Urgent channel should feel more alert but still on-brand.

Raabta respects system silent/DND; these sounds only play when the OS allows notification audio.
