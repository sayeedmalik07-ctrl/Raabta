# Raabta Bottom Nav, Alive on Touch (audit first)

## Reference files (exact paths, relative to the repo root `Raabta-home-ux-clean`)
Kit folder on disk: `/Users/mohammadsayeed/Documents/FlutterDev/Projects/Raabta-home-ux-clean/docs/raabta_ai_nav_header`

- `docs/raabta_ai_nav_header/raabta_ai_living_refs/11_nav_idle_active_lens.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/12_nav_touch_down.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/13_nav_transition_lens_glide.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/14_nav_post_pressed.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/15_nav_light_mode.png`
- `docs/raabta_ai_nav_header/raabta_ai_living_refs/16_nav_motion_spec.png`

Open and look at each image before Step 0. They show layout, states and timing only. Colors in the images are placeholders: the existing design kit tokens always win, never hardcode hex. If you cannot view the images, say so at the start of your Step 0 report and rely on the written description below; do not guess visual details. Do not add these images to `assets/` or `pubspec.yaml`.


## Reference
Open PNGs in `raabta_ai_living_refs/`: 11 (idle), 12 (touch down), 13 (lens glide), 14 (Post pressed), 15 (light mode), 16 (motion spec). Colors in the PNGs are placeholders; use the existing design kit tokens, never hardcoded hex.

## Problem
The bottom nav feels flat, like a plain tab bar. It should react to touch and feel alive, in Raabta's own design language (glass, violet, one gold accent), without changing what it contains.

## Scope and limits
- Same destinations: Home, Market, Post (centre action), Community, Profile. No route, auth, Firestore or Post Engine changes. Do not change what the Post ladder contains.
- Interaction layer only. No new dependencies unless the audit proves one is needed.

## Step 0: Audit (report first, no code yet)
1. File and widget that build the bottom nav and the centre Post button; how the selected tab is stored and how navigation happens (IndexedStack, router, shell route).
2. Existing animation primitives, haptics usage, design kit motion tokens (durations, curves) and reduced motion handling.
3. Current icon set and whether filled/outline variants exist.
4. Whether the nav sits inside a RepaintBoundary and what rebuilds on tab change.
5. Proposed file list. Stop and wait for my OK only if the plan touches routing or state management.

## Step 1: Implement
1. **Sliding lens.** A glass pill (visible hairline, soft violet glow) sits under the active tab with a short glowing bar beneath. It replaces the small dot. On tab change it glides to the new tab with a spring (about 320 ms), stretching wider mid-way and settling to normal width. One animation controller drives it.
2. **Touch down.** The pressed tab scales to about 0.88 and a soft radial touch glow appears behind it, within about 80 ms of touch. Feedback must be instant even if the next screen is slow.
3. **Release.** Spring back (about 220 ms, slight overshoot). The new icon pops up about 5 px with a small overshoot (1.0 to 1.14 to 1.0, about 260 ms). Old icon cross-fades back to outline; new icon becomes a tinted fill (about 160 ms). Label turns violet.
4. **Haptic.** `HapticFeedback.selectionClick()` once per tab change (not on touch move, not when tapping the already selected tab). Wrap in try/catch.
5. **Re-tap on the active tab.** Small press and glow only, no navigation side effects beyond what exists today (for example scroll to top if that already exists).
6. **Centre Post button.** Use the same violet gradient as the rest of the app (the current blue tint is removed). Idle: very slow breathing glow (about 4 s). Press: scale 0.92, brighter glow, two soft rings expand and fade. The plus rotates 45 degrees into a cross while the Post ladder is open and rotates back on close. Light impact haptic once. While the ladder is open, other tabs dim slightly.
7. **Idle state.** Nothing moves except the Post button glow.
8. **Light mode.** Lens uses a tinted violet fill, a visible hairline and a soft coloured shadow instead of a dark glow. Keep contrast on inactive icons and labels.
9. **Reduced motion.** No stretch, pop or rings; use a quick fade and keep the haptic.
10. **RTL.** The lens must follow the mirrored tab order.

## Performance and accessibility
- One AnimationController for the lens; icons use implicit animations. No per frame allocations.
- Wrap the nav in a RepaintBoundary. Never rebuild the whole screen on a nav animation tick.
- No blur layers. Fake the glow with a cached gradient or shadow.
- Keep 48 dp minimum touch targets and correct Semantics labels and selected state for each tab.
- Dispose controllers properly.

## Design language
Glass surfaces with a hairline and top highlight, violet light, one gold accent only where it already exists. Calm springs, no sparkles or neon. Sentence case, no dashes as punctuation.

## Acceptance
- Visible instant response on touch, lens glides on change, Post button feels distinct but consistent in colour.
- Works in light and dark, with reduced motion, RTL, rapid tab switching, slow screens and app backgrounding.
- No route or state management regression. `flutter analyze` clean, tests pass.
- Report modified files, test results and limitations.
