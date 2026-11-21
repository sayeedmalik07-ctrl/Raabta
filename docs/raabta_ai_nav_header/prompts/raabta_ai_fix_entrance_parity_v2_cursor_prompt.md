# Raabta AI Screen and Home Parity Fix, v2 (from real screenshots, audit first)

## Reference files (exact paths, relative to the repo root `Raabta-home-ux-clean`)
Kit folder on disk: `/Users/mohammadsayeed/Documents/FlutterDev/Projects/Raabta-home-ux-clean/docs/raabta_ai_nav_header`

- `docs/raabta_ai_nav_header/raabta_ai_living_refs/03_entrance_ready_idle.png` (assistant screen, dark)
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/08_light_mode_ready.png` (assistant screen, light)
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/02_entrance_0_150ms.png` (first 150 ms of the entrance)
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/01_home_ai_button_idle.png` and `10_orb_anatomy.png` (sparkle button and orb construction)
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/11_nav_idle_active_lens.png` (nav indicator)

Open every image before Step 0. They are a 390 x 844 reference; use proportional layout. Colors are placeholders: use the design kit tokens, never hardcode hex. If you cannot view the images, say so first.

## Context
The kit was implemented. Screenshots of the running app (7 Nov 2026) show the Home header, search hint, language pill and lens nav largely correct, but the assistant screen and the Home sparkle button still differ from the kit. Do NOT change AI backend, streaming, auth, Firestore, routing structure, the existing suggestion data sources or any other screen. Existing product content (suggestion items, next steps, mode subtitle, voice button) must be kept; only its look and placement change to match the kit.

## Known mismatches seen in the screenshots (verify each in Step 0, then find any others)
Assistant screen vs PNG 03:
1. Header: built is left aligned with a large orb avatar, "Raabta AI" and subtitle "Qatar Labour Rights + General Help", and a plain three dot icon. Kit: centre group with a 26 px orb, "Raabta" (16 px bold) and a 12 px muted subtitle; right button is a glass 40 px, radius 14 button like the back button. If the subtitle is a real mode indicator, keep its text as the subtitle (one line, ellipsis); do not invent a replacement.
2. Hero orb: built is roughly two thirds of the kit size and is wrapped in a solid teal ring. Kit: 104 px orb (proportional), thin partial gold arc, soft halo, and two static hairline rings behind it (about 240 px outer, violet at about 22 percent opacity; about 172 px inner, blue at about 22 percent). Remove the teal ring. Only the orb breathes.
3. Greeting hierarchy: built shows a small title case "Good Evening, Friend", then a second large headline "How can I help you today?", then a muted line. Kit: the greeting is the headline (about 29 px bold, sentence case "Good evening, Friend") with one muted 16 px line beneath. Use the kit hierarchy. Keep the existing muted line "Ask anything about life and work in Qatar" as that line; drop the extra headline, and mention the change in your report.
4. Suggestion sections: built uses teal section labels ("Start with your situation", "Helpful next steps") and flat full width rows with same colour sparkle icons. Kit: glass cards, radius 18, 32 px tinted icon tiles (gold, violet, teal, one tint per card), 14.5 px bold labels, 9 px gaps; use the two column plus one full width layout when the labels fit, otherwise full width rows. Section labels become small muted sentence case text (no teal). Keep the existing items, data source and navigation, and keep the external link arrow on "Helpful next steps" cards.
5. Composer: built shows the placeholder "Explain my contract" in bright bold text and an enabled violet send button while the field is empty. Kit: muted placeholder, send button in its disabled glass state until there is text. If "Explain my contract" is a rotating example prompt, show it as a muted hint and keep the behaviour. Keep the voice button but style it as a glass circle with the same height as the pill (54 px) and aligned to it.
6. Overall spacing, background glow (soft violet top right, faint blue bottom left) and no bottom nav on this screen: confirm they match.

Home vs PNG 01 and 11:
7. Sparkle button: built shows a plain violet circle with no visible sparkle glyph and no gold arc or halo. Kit: keep the white four point sparkle glyph (with the small second star), add the thin partial gold arc and soft halo, 54 px, same position and size as before. Confirm it is not overlapping the header card and is aligned to the right margin.
8. Nav indicator: the glowing bar under the active tab sits on top of the label, so "Home" reads as underlined. Kit: the bar (about 28 x 4 px) sits below the label inside the lens with a few px gap. Also check for faint arc shapes along the top edge of the nav bar (leftover clipped glow or ripple layers) and remove them.

## Step 0: Report first (no code yet)
1. Run the app on the iOS simulator, capture the Home screen and the assistant screen in dark and light, and capture the Home to assistant transition at about 0 ms, 100 ms, 300 ms with `timeDilation = 8` (remove it afterwards).
2. Produce a table: Element, Kit spec, Current implementation, File and widget, Fix. Include rows 1 to 8 above (confirmed or corrected) and every additional mismatch, including the entrance frames compared with PNG 02 (scrim, four ripple rings, 70 px rising orb, pressed button).
3. Wait for my OK only if a fix needs changes outside the assistant screen, the sparkle button, the transition or the nav indicator.

## Step 1: Fix
Fix every row. Reuse the single orb widget and the existing suggestion widgets (restyle, do not duplicate). One animation controller for the orb, RepaintBoundary around it, no blur layers, no new dependencies unless justified in Step 0.

## Step 2: Verify
1. Re-capture the same screens and frames; confirm each table row is resolved.
2. Check dark and light, a small and a large phone, keyboard open and closed, reduced motion, rapid taps on the sparkle button (no duplicate routes or haptics), slow network (UI still appears instantly), RTL (Arabic).
3. `flutter analyze` clean and existing tests pass.

## Report
Final table with every row marked fixed, modified files, test results and any remaining differences with the reason.

## Design language
Glass surfaces with hairline and top highlight, violet light, one gold accent only (the orb arc). Calm springs, no sparkles or neon beyond the existing glyph, sentence case, no dashes as punctuation in user facing text.
