# Raabta AI Living Experience, Prompt 2 of 4: Living orb widget

## Reference files (exact paths, relative to the repo root `Raabta-home-ux-clean`)
Kit folder on disk: `/Users/mohammadsayeed/Documents/FlutterDev/Projects/Raabta-home-ux-clean/docs/raabta_ai_nav_header`

- `docs/raabta_ai_nav_header/raabta_ai_living_refs/01_home_ai_button_idle.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/03_entrance_ready_idle.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/04_processing.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/05_responding_streaming.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/06_error_retry.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/07_orb_state_sheet.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/08_light_mode_ready.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/10_orb_anatomy.png`

Open and look at each image before Step 0. They show layout, states and timing only. Colors in the images are placeholders: the existing design kit tokens always win, never hardcode hex. If you cannot view the images, say so at the start of your Step 0 report and rely on the written description below; do not guess visual details. Do not add these images to `assets/` or `pubspec.yaml`.


## Reference
PNG 07 (orb state sheet), 01 (home AI button), 03 (ready), 04, 05, 06. Colors are placeholders. Use design kit tokens.

## Objective
Build ONE reusable animated AI identity widget and use it in the sparkle AI button, the assistant header and the assistant empty state. Do not create a second orb implementation anywhere.

## Step 0: Audit first
Report: whether the sparkle button already has any "alive" animation from the earlier nav prompt, what animation primitives or packages exist, and how to share one widget across sparkle button (small), header (small) and empty state (large). Propose the API (`RaabtaOrb(state, size)`). Reuse what exists.

## Step 1: Implement
States (enum): idle, listening, processing, responding, error, completion.
- idle: slow breathing, 3 to 4 second loop.
- listening: soft ring tightens while the user types or the field is focused.
- processing: slightly smaller orb, one gold orbit dot, glow up.
- responding: soft pulse rings while text arrives.
- error: desaturated and still. No red, no flashing.
- completion: ease back to idle in about 300 ms.

## Performance rules (important, battery and low end Android)
- One AnimationController per orb. Animate with transforms and opacity, or a small CustomPainter.
- Wrap in `RepaintBoundary`. Only the orb repaints, never the whole screen.
- No BackdropFilter or blur layers. Fake the glow with a gradient or cached shadow.
- No per frame allocations. No particle libraries unless one already exists in the project.
- Pause the controller when the app is backgrounded, the screen is not visible or reduced motion is on. Reduced motion shows a static orb with a simple state color change.
- The button keeps its current position, size and sparkle glyph; it only becomes a living orb (violet sphere, thin gold arc, soft halo) and stays subtle so Home stays calm.
- Dispose controllers correctly.

## Do NOT
Touch AI services, Firestore or routes. Add dependencies unless the audit proves it is needed.

## Acceptance
- Same widget used in 3 places, all 6 states visible in a debug preview.
- Light and dark both look right (PNG 08).
- Profile with the Flutter performance overlay on a mid range Android: no jank when idle.
- `flutter analyze` clean. Report files changed and limitations.

## Design language (Raabta premium, applies to everything in this prompt)
Match the PNGs in `raabta_ai_living_refs/` (now 10 screens, including 10 orb anatomy). Reuse the existing design kit tokens and glass card recipe; never hardcode hex.
- Surfaces: glass with a 1px hairline and a soft top highlight. In light mode use a visible violet hairline plus a soft coloured shadow so cards never look flat.
- Light: purple and cyan glow, ONE gold accent (the thin arc on the orb, the marker on range bars, warnings).
- Orb: layered sphere (purple core, cyan underglow, soft highlight), thin gold arc, cached halo. No face, no mascot, no particles, no sparkles, no neon.
- Bubbles: user message uses the brand purple gradient; assistant replies sit in glass cards with a small orb avatar.
- Composer: glass pill with a plus on the left and a gradient send button.
- Suggestion cards: glass with icon tiles tinted gold, purple or cyan.
- Motion: calm springs, 300 to 450 ms entrance, staggered 40 to 60 ms. No real blur layers (use a scrim), no continuous heavy animation.
- Copy: sentence case, plain words, no dashes as punctuation.
