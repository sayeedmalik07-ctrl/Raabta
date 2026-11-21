# Raabta AI Living Experience, Prompt 3 of 4: Responsive chat

## Reference files (exact paths, relative to the repo root `Raabta-home-ux-clean`)
Kit folder on disk: `/Users/mohammadsayeed/Documents/FlutterDev/Projects/Raabta-home-ux-clean/docs/raabta_ai_nav_header`

- `docs/raabta_ai_nav_header/raabta_ai_living_refs/03_entrance_ready_idle.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/04_processing.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/05_responding_streaming.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/06_error_retry.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/09_light_mode_chat.png`

Open and look at each image before Step 0. They show layout, states and timing only. Colors in the images are placeholders: the existing design kit tokens always win, never hardcode hex. If you cannot view the images, say so at the start of your Step 0 report and rely on the written description below; do not guess visual details. Do not add these images to `assets/` or `pubspec.yaml`.


## Reference
PNG 03, 04, 05, 06.

## Objective
Make the conversation feel responsive using the EXISTING AI service, streaming and history. No backend, auth or Firestore changes.

## Step 0: Audit first
Report how messages are modeled and rendered, whether the existing response path streams, how retry and errors work, how the composer handles keyboard and safe area, and whether suggestion chips or action cards are already supplied by any service. Propose the smallest change set.

## Step 1: Implement
1. Sent message slides up and fades in (about 180 ms).
2. Show a processing indicator immediately after send, driving the orb to `processing`.
3. If the existing path streams, reveal text progressively and set the orb to `responding`. If it does not stream, fade the finished answer in. Do not fake typing.
4. On completion, orb returns to idle. On failure, orb goes to `error` with a short message that says what happened and what to do, and a single Retry using the existing retry logic.
5. Send button: disabled when empty, loading state while waiting, blocks double submit.
6. Keep composer anchored above the keyboard, respect safe area, preserve scroll position and history.
7. Suggestion chips and action cards only where existing services supply them. Do not invent new data sources.
8. Keep animations on the new bubble only. Do not rebuild the whole list on each tick.
9. No added AI calls. Do not change prompts, caching or cost optimization behavior.

## Edge cases to verify
Slow network, API failure, offline, app backgrounded mid answer, rapid taps, keyboard open, long answers, RTL and Arabic, reduced motion.

## Acceptance
History and retry behave exactly as before. No new collections, agents or clients. `flutter analyze` clean, tests pass. Report files, results and limitations.

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
