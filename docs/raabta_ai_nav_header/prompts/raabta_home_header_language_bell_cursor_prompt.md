# Raabta Home Header: Language and Notification Buttons (audit first)

## Reference files (exact paths, relative to the repo root `Raabta-home-ux-clean`)
Kit folder on disk: `/Users/mohammadsayeed/Documents/FlutterDev/Projects/Raabta-home-ux-clean/docs/raabta_ai_nav_header`

- `docs/raabta_ai_nav_header/raabta_ai_living_refs/18_header_before_after.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/19_header_proposed_home.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/20_header_press_states.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/21_language_sheet.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/22_header_light_mode.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/23_header_rtl_and_states.png`

Open and look at each image before Step 0. They show layout, states and timing only. Colors in the images are placeholders: the existing design kit tokens always win, never hardcode hex. If you cannot view the images, say so at the start of your Step 0 report and rely on the written description below; do not guess visual details. Do not add these images to `assets/` or `pubspec.yaml`.


## Reference
PNGs in `raabta_ai_living_refs/`: 18 (current vs proposed), 19 (proposed Home), 20 (press states), 21 (language sheet), 22 (light mode), 23 (RTL and states). Colors in the PNGs are placeholders; use the design kit tokens, never hardcoded hex.

## Problem
In the current Home header the EN language button is a flat teal circle that does not look tappable (teal is used nowhere else on Home), the bell is a different style, the badge is a flat dot with no ring or cap, the place line shows an unfinished "Qatar . -" placeholder, "Good Evening" is title case while the app uses sentence case, and neither button reacts to touch. Bring the header to the same premium, alive standard as the nav and the AI button.

## Scope and limits
- UI and interaction layer only. No auth, Firestore, notification backend, push, routing or locale storage changes. No new collections.
- Keep the glass header card, avatar ring, position and overall height. Nothing below the header may move.
- Reuse the existing language switching and notifications screen.

## Step 0: Audit (report first, no code yet)
1. File and widgets for the header, language button, bell and badge; where the greeting, name and place text come from.
2. How language switching works today (what the EN button does on tap, list of supported languages and their order, how locale and RTL are applied) and whether a language sheet already exists.
3. Where the unread count comes from (existing provider or stream) and how it updates.
4. Existing press feedback, haptics and motion tokens in the design kit; reduced motion handling.
5. Why the place line shows "Qatar . -" (which field is empty) and what values it can have.
6. Proposed file list. Stop and wait for my OK only if the plan touches the notification service, locale storage or routing.

## Step 1: Implement
1. **Language button.** A glass pill (44 px high, visible hairline, top highlight) with a globe icon, the language code (EN, or one short mark per language) and a small chevron. Same visual family as the bell. Remove the teal colour; icon uses the violet accent from the kit. Keep the pill width stable across languages so the card does not jump.
2. **Language sheet.** Tap opens a bottom sheet (PNG 21): handle, title, a row per supported language showing its own name in its own script with the English name small underneath, the current one tinted with a check. Use the app's real language list and order. On select: light haptic, sheet closes, text cross-fades, RTL languages mirror the layout. Reuse the existing locale switching; add no new storage.
3. **Bell.** Same glass circle style, 44 px minimum touch target. Badge: hidden at zero, number up to 9, "9+" above, ring in the card colour so it never melts into the card, keep the existing semantic red/pink from the kit. Tap opens the existing notifications screen.
4. **Press states.** Both buttons scale to about 0.92 with a soft violet glow and tint within 80 ms, light haptic on tap (selectionClick), spring back in about 220 ms.
5. **New notification moment.** If the unread count increases while Home is visible: the bell tilts once (about 14 degrees, 450 ms) and the badge pops 1.0 to 1.25 to 1.0. Once per new item, never looping, never on first load. Reduced motion: no tilt, badge only.
6. **Text block.** Three lines: muted greeting in sentence case ("Good evening"), the name larger (guest fallback "Friend"), and the place with a small pin. Hide any empty segment and the separator; never show a dash placeholder. Keep the existing time based greeting logic. Name truncates with ellipsis; buttons never shrink below 44 px.
7. **Light mode.** Card gets a visible violet hairline and a soft coloured shadow; pill and bell use a tinted white fill with a hairline; verify contrast of the muted text and badge (PNG 22).
8. **RTL.** Use directional padding and alignment so the whole header mirrors in Arabic and Urdu (PNG 23). Verify in at least Arabic and one LTR Indic language.
9. **Accessibility.** Semantics labels: "Language, English" (localized) and "Notifications, 3 unread" (localized, count included). Support larger text sizes without clipping.

## Performance
Keep animations on the two buttons only. One short controller per button, implicit animations where possible, no blur layers, RepaintBoundary around the header, dispose controllers.

## Design language
Glass surfaces with hairline and top highlight, violet light, one gold accent only where it already exists. Calm springs, no sparkles or neon. Sentence case, no dashes as punctuation in user facing text.

## Acceptance
- EN looks like a button, bell matches it, both react instantly to touch.
- Language switch and notifications behave exactly as before; RTL mirrors correctly; no layout jump when the language changes.
- Badge states correct (0, 1 to 9, 9+); new notification moment fires once.
- Works in light and dark, reduced motion, large text, slow devices. `flutter analyze` clean, tests pass.
- Report modified files, test results and limitations.
