# Raabta AI Living Experience, Prompt 1 of 4: Audit, AI button tap, haptic and entrance

## Reference files (exact paths, relative to the repo root `Raabta-home-ux-clean`)
Kit folder on disk: `/Users/mohammadsayeed/Documents/FlutterDev/Projects/Raabta-home-ux-clean/docs/raabta_ai_nav_header`

- `docs/raabta_ai_nav_header/raabta_ai_living_refs/01_home_ai_button_idle.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/02_entrance_0_150ms.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/03_entrance_ready_idle.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/08_light_mode_ready.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/10_orb_anatomy.png`

Open and look at each image before Step 0. They show layout, states and timing only. Colors in the images are placeholders: the existing design kit tokens always win, never hardcode hex. If you cannot view the images, say so at the start of your Step 0 report and rely on the written description below; do not guess visual details. Do not add these images to `assets/` or `pubspec.yaml`.


## Reference
Open the PNGs in `raabta_ai_living_refs/` (01, 02, 03, 08, 10) before coding. They show target look and timing only. Colors in the PNGs are placeholders: use the existing design kit tokens, never hardcoded hex.

## Objective
Make opening the AI assistant feel instant, tactile and premium. This is an interaction layer change only. Do NOT rebuild the AI backend, change Firestore, add collections, add another AI agent, add duplicate API clients or add a parallel state management system.

## Context you must respect
- The bottom AI tab was removed. The ONLY entry is the purple sparkle AI button beside the search bar on Home (see PNG 01, it matches the current Home). Do not recreate an AI tab, FAB or second orb on Home.
- Bottom nav is Home, Market, Post (center), Community, Profile.
- The design kit tokens (colors, radius, motion ladder) already exist. Reuse them.
- Light and dark mode must both look right.

## Step 0: Audit (report first, no code yet)
Report briefly:
1. File and widget for the sparkle AI button and how it navigates to the assistant screen.
2. The assistant screen, its state management, streaming logic, error and retry handling.
3. Existing animation, haptic, audio and theme dependencies in pubspec.
4. Existing design kit motion tokens (durations, curves) I should reuse.
5. Any reduced motion handling already in the app.
6. Proposed file list and what each change touches. Stop and wait for my OK only if the plan touches the AI service, auth or Firestore.

## Step 1: Implement
1. On tap of the sparkle button: `HapticFeedback.lightImpact()` once, wrapped in try/catch. The button presses to about 0.94 and springs back.
2. Start the transition at 0 ms. Never wait for any API call before showing the UI.
3. Dim Home softly (about 75 percent) with a restrained teal glow from the button, per PNG 02. No blur layers.
4. Enter the assistant screen with a spring or eased curve. Stagger orb, greeting, suggestion area and composer by about 40 to 60 ms each. Total entrance about 300 to 450 ms.
5. Greeting uses the existing time based greeting logic. Do not hardcode a name; fall back to a neutral greeting for guests.
6. Do not auto focus the input.
7. Debounce taps (about 600 ms) so rapid taps cannot push duplicate routes or repeat haptics.
8. Reduced motion: if the platform flag is on, skip scale and glow, use a short fade only.
9. Suggestion chips: show only if an existing service already provides them. Otherwise hide the row.

## Do NOT
- Touch AI service, Firebase, auth or navigation structure beyond the sparkle AI button.
- Add new Firestore collections or fields.
- Add dependencies without justifying them in the audit.
- Use dashes as punctuation in user facing text.

## Acceptance
- Animation starts on the tap frame, no network wait.
- One haptic per tap, none on rapid repeat.
- Works in light and dark, with reduced motion, with keyboard closed, in RTL if the app supports it.
- `flutter analyze` clean, existing tests pass.
- Report modified files, tests run and limitations.

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

## Current Home reference (from the real app)
PNG 01 mirrors the live Home: glass header card (avatar ring, greeting, EN pill, bell), search bar with the purple sparkle button to its right, Today card, floating glass bottom nav with the raised centre Post button. Do not change any of this layout; only the sparkle button becomes the living orb and the entrance starts from it.
