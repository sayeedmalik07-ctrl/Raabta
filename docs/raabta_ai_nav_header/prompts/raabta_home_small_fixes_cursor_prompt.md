# Raabta Home Small Fixes (audit first)

## Reference files (exact paths, relative to the repo root `Raabta-home-ux-clean`)
Kit folder on disk: `/Users/mohammadsayeed/Documents/FlutterDev/Projects/Raabta-home-ux-clean/docs/raabta_ai_nav_header`

- `docs/raabta_ai_nav_header/raabta_ai_living_refs/17_home_fixes_ai_button_and_search.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/01_home_ai_button_idle.png`

Open and look at each image before Step 0. They show layout, states and timing only. Colors in the images are placeholders: the existing design kit tokens always win, never hardcode hex. If you cannot view the images, say so at the start of your Step 0 report and rely on the written description below; do not guess visual details. Do not add these images to `assets/` or `pubspec.yaml`.


## Reference
PNG 17 (`raabta_ai_living_refs/17_home_fixes_ai_button_and_search.png`) and PNG 01 for the current Home. Colors are placeholders; use design kit tokens.

## Scope
Three small, UI only fixes on Home. No auth, Firestore, routing or AI backend changes. No new collections.

## Step 0: Audit (report first)
1. Where the search bar hint, the sparkle AI button and the centre Post button colours are defined.
2. Existing preference or local storage mechanism for one-time UI flags (reuse it; do not add a new collection).
3. Existing localization keys for the search hint and any AI button label.
4. Proposed file list.

## Fix 1: Centre Post button colour
The centre "+" currently looks blue-violet while the rest of the app is violet. Use the design kit's primary violet gradient tokens so it matches the Finish setup button and active nav colour. (If the blue was deliberate in the kit, report that and keep it; otherwise unify.)

## Fix 2: Search hint truncated ("docum...")
- Replace the long hint with a shorter one that fits on small phones in all languages: "Search jobs, housing, docs" (localize it for every supported language; check Arabic, Urdu, Hindi, Tamil and other RTL/long languages).
- Single line with ellipsis as a safety net only. The sparkle button must keep its position and size.
- Do not change search behaviour or suggestions.

## Fix 3: Sparkle AI button discoverability
- Keep position, size and sparkle glyph.
- Clear pressed state: scale to about 0.94 with a soft glow, light haptic, instant response.
- Add Semantics label "Ask Raabta" (localized) and a tooltip for long press.
- One-time coach mark on the first Home visit: small glass bubble under the button, "Ask Raabta anything" with a short second line (for example "Rights, bills, housing and jobs"). Dismiss on tap, on opening the assistant, or after about 5 seconds. Never show it again once dismissed (store the flag with the existing preference mechanism). Do not show it over onboarding or a blocking dialog.
- Respect reduced motion (fade only).

## Design language
Glass surfaces with hairline, violet light, one gold accent. Sentence case, no dashes as punctuation. Light and dark both verified.

## Acceptance
Hint fits in every supported language, Post button colour matches the kit, coach mark shows once and persists correctly, accessibility label present. `flutter analyze` clean, tests pass. Report files changed and limitations.
