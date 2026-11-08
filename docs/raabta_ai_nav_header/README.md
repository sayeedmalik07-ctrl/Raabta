# Raabta AI Living Experience, how to use

1. This whole folder lives at `docs/raabta_ai_nav_header/` in the Raabta repo. Do NOT put the PNGs in `assets/` or `pubspec.yaml`; they are reference only and must not ship in the app bundle.
2. Run prompts in order: P1 (audit, AI button, haptic, entrance), P2 (orb), P3 (chat), P4 (sound, optional).
3. In each prompt, tell Cursor which PNGs to open. PNG colors are placeholders; the design kit tokens always win.
4. The PNGs show layout, states and timing only. They are not pixel specs.

PNG list: 01 home AI button (current Home), 02 entrance, 03 ready, 04 processing, 05 responding, 06 error, 07 orb states, 08 light ready, 09 light chat, 10 orb anatomy, 11 nav idle, 12 nav touch down, 13 nav lens glide, 14 Post pressed, 15 nav light, 16 nav motion spec, 17 Home fixes, 18 header before and after, 19 proposed header, 20 header press states, 21 language sheet, 22 header light, 23 header RTL and states.

## Added 1 Nov 2026: alive nav and Home fixes
- `raabta_nav_alive_touch_cursor_prompt.md` uses PNGs 11 to 16 (nav idle, touch down, lens glide, Post pressed, light mode, motion spec).
- `raabta_home_small_fixes_cursor_prompt.md` uses PNG 17 (Post colour, search hint, sparkle button press state and one-time coach mark).
- Both are audit first and independent of P1 to P4; they can run before or after them.

## Added 1 Nov 2026: Home header
- `raabta_home_header_language_bell_cursor_prompt.md` uses PNGs 18 to 23 (current vs proposed, proposed Home, press states, language sheet, light mode, RTL and states).
- Audit first and independent of the other prompts. If you also run the Home small fixes prompt, run it first or together, since both touch the top of Home.


## Recommended run order (one prompt per Cursor chat, test and commit after each)
1. `prompts/raabta_home_small_fixes_cursor_prompt.md` (PNG 17, 01)
2. `prompts/raabta_home_header_language_bell_cursor_prompt.md` (PNG 18 to 23)
3. `prompts/raabta_nav_alive_touch_cursor_prompt.md` (PNG 11 to 16)
4. `prompts/raabta_ai_p1_audit_ai_button_entrance_haptic_cursor_prompt.md` (PNG 01, 02, 03, 08, 10)
5. `prompts/raabta_ai_p2_orb_widget_cursor_prompt.md` (PNG 01, 03 to 07, 10)
6. `prompts/raabta_ai_p3_chat_interactions_cursor_prompt.md` (PNG 03 to 06, 09)
7. `prompts/raabta_ai_p4_optional_sound_cursor_prompt.md` (optional, last)

## How to run each prompt
1. Open a new Cursor chat. Paste the prompt text, and attach the PNGs listed above to the chat.
2. Cursor first returns a Step 0 audit. Read it, then reply "approved, proceed" or bring the audit back for review if it proposes anything outside scope.
3. After the build, test on the simulator and iPhone in light and dark, then commit before starting the next prompt.
4. The PNG colors are placeholders. The design kit tokens in the code always win.

## Why each prompt lists exact image paths
Every prompt has a "Reference files" block with repo-root-relative paths (`docs/raabta_ai_nav_header/raabta_ai_living_refs/...`). If you move the folder, update that path in the prompts (find and replace). Also attach the same PNGs directly to the Cursor chat as a fallback.

## Fix prompt (added after first implementation)
- `prompts/raabta_ai_fix_entrance_parity_cursor_prompt.md` compares the built entrance with PNG 02 and 03 (and 08 for light), lists every mismatch in a table, then fixes them. Run it in a new Cursor chat after P1 to P3; attach PNG 02, 03, 08, 01 and 10.

- `prompts/raabta_ai_fix_entrance_parity_v2_cursor_prompt.md` supersedes the first parity fix prompt. It lists the 8 mismatches found in the 7 Nov 2026 screenshots (assistant screen, sparkle button, nav indicator) and asks Cursor to confirm them in a table before fixing. Attach PNG 01, 02, 03, 08, 10 and 11.
