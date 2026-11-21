# Raabta AI Living Experience, Prompt 4 of 4 (OPTIONAL, run last): Opening sound

Only run this after Prompts 1 to 3 are built and confirmed. Skip entirely if you prefer a silent app.

## Step 0: Audit first
Check for an existing audio package and any existing sound or haptics setting in Profile or Settings. Report whether a quiet, original, licensed chime asset exists. If none exists, STOP and tell me; do not download or invent a sound from the internet.

## Step 1: Implement (only if an asset exists)
- One short, very quiet chime when the assistant opens. Never on keystrokes, never per frame, never on every message.
- Independent toggle for sound and for haptics, using the existing preferences mechanism (no new Firestore collection). Default sound OFF.
- Respect device silent mode and platform audio focus. Fail silently on any audio error.
- Preload lightly, release resources on dispose, and avoid delaying the entrance animation.
- Reuse an existing audio dependency. Add one only after justifying it.

## Acceptance
Sound never blocks or delays the UI, is off by default, can be toggled, and does nothing in silent mode. `flutter analyze` clean.
