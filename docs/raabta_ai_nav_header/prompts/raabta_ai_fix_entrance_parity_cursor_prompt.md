# Raabta AI Entrance: Fix to Match the Kit Exactly (PNG 02 and PNG 03), audit first

## Reference files (exact paths, relative to the repo root `Raabta-home-ux-clean`)
Kit folder on disk: `/Users/mohammadsayeed/Documents/FlutterDev/Projects/Raabta-home-ux-clean/docs/raabta_ai_nav_header`

- `docs/raabta_ai_nav_header/raabta_ai_living_refs/02_entrance_0_150ms.png` (target for the first 150 ms)
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/03_entrance_ready_idle.png` (target for the settled assistant screen, dark)
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/08_light_mode_ready.png` (same screen in light mode)
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/01_home_ai_button_idle.png` and `10_orb_anatomy.png` (Home button and orb construction)

Open and study every image before Step 0. The images are a 390 x 844 reference. Colors in them are placeholders: use the existing design kit tokens, never hardcode hex. If you cannot view the images, say so first and rely on the written spec below.

## Problem
The entrance was implemented, but the result does not match PNG 02 (0 to 150 ms) and PNG 03 (ready, idle). This is a visual parity fix only. Do NOT change the AI backend, streaming, auth, Firestore, routing structure or any other screen.

## Step 0: Compare before changing anything (report a table, no code yet)
1. Run the app on the iOS simulator. Temporarily set `timeDilation = 8` (remove it before finishing) and capture the Home to assistant transition at about 0 ms, 100 ms, 300 ms and the settled state.
2. Compare each capture with PNG 02 and PNG 03, side by side, element by element.
3. Report a table with columns: Element, Kit spec, Current implementation, File and widget, Fix. Include every mismatch, even small ones (size, spacing, order, opacity, timing, missing layers).
4. Wait for my OK only if a fix needs a change outside the assistant screen, the Home sparkle button or the transition.

## Spec to match: PNG 02 (0 to 150 ms)
- Home stays fully visible behind and is NOT blurred and NOT replaced. Use a plain scrim: radial gradient centred on the sparkle button (about 89 percent across, 22 percent down), violet glow at the centre fading to the dark background tone at about 52 percent radius, overall dim about 75 to 80 percent.
- The sparkle button is pressed: scale about 0.94 with a soft violet glow.
- Four soft ripple rings expand from the button centre, about 80, 170, 290 and 430 px diameter, 1.5 px violet hairlines with opacities about 0.6, 0.38, 0.22, 0.1 (fading as they grow).
- A 70 px orb (violet sphere, thin gold arc, halo) appears at the vertical middle of the screen (about 47 percent down), horizontally centred, at about 0.6 scale and 0.75 opacity, rising toward its final spot.
- One light haptic at 0 ms. Nothing waits for the network.

## Spec to match: PNG 03 (ready, idle)
Layout top to bottom (use proportional layout, not hardcoded 390 x 844 pixels):
1. Header row: glass back button (40 px, radius 14) on the left; centre group with a 26 px orb, "Raabta" (16 px bold) and "Your Qatar assistant" (12 px muted) beneath; glass more button (40 px, radius 14) on the right. No bottom nav on this screen.
2. Hero block starting about 78 px below the header, centred: a 104 px orb with a thin gold arc (partial ring, about 9 percent outside the sphere, starting near 210 degrees) and a soft halo; around it two static hairline rings (about 240 px outer, violet at about 22 percent opacity; about 172 px inner, blue at about 22 percent opacity). Only the orb breathes; the rings stay still.
3. Greeting: "Good evening, <name>" at about 29 px bold with slight negative letter spacing; guests use the existing neutral fallback ("Friend"). Beneath it, 16 px muted centred line: "Ask about your rights, bills, housing or jobs".
4. Suggestion cards above the composer (about 96 px from the bottom): a two column row then one full width row, 9 px gaps. Each card is glass, radius 18, with a 32 px tinted icon tile (gold, violet, teal) and a 14.5 px bold label. Example labels: "Check my gratuity", "Is my rent fair?", "Send money home". Rule: show the cards only when an existing service supplies them; if none, hide the row. When shown they must match this style.
5. Composer: glass pill about 54 px high, radius 28, 14 px side margins and about 24 px bottom margin; violet plus icon at the left, "Message Raabta" placeholder (16 px muted), and a 40 px send button at the right in its disabled glass state. Input is NOT auto focused.
6. Background: dark navy with a soft violet glow at the top right and a faint blue glow at the bottom left.

Timing: entrance is about 300 to 450 ms in total; stagger orb, greeting, subline, suggestion cards, composer by 40 to 60 ms each; spring or eased curve; reduced motion falls back to a short fade.

## Step 1: Fix
Fix every mismatch from the table, reusing the existing widgets and the single orb widget (do not create a second orb). Keep existing providers, services and routes. Keep one animation controller for the orb and wrap it in a RepaintBoundary. No blur layers, no new dependencies unless justified in Step 0.

## Step 2: Verify
1. Re-capture the same frames at `timeDilation = 8` and confirm each row of the table is resolved; then remove `timeDilation`.
2. Verify the settled screen in dark (PNG 03) and light (PNG 08), on a small phone and a large phone, with the keyboard closed.
3. Check reduced motion, rapid repeated taps on the sparkle button (no duplicate routes or haptics), and a slow network (UI still appears instantly).
4. Optional: add one golden test for the settled ready screen in dark and light if the repo already uses golden tests.
5. `flutter analyze` clean and existing tests pass.

## Report
The final comparison table with every row marked fixed, modified files, test results and any remaining differences with the reason.

## Design language
Glass surfaces with hairline and top highlight, violet light, one gold accent only (the orb arc). Calm springs, no sparkles or neon, no dashes as punctuation in user facing text.
