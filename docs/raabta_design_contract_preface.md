# DESIGN CONTRACT (paste at the top of EVERY queued Cursor prompt)

Before writing any code for this feature:
1. Read docs/HUB_DESIGN_CONTRACT.md, docs/raabta_home_design_kit.md, docs/raabta_hub_design_kit.md, docs/raabta_hub_subscreen_kit.html, docs/raabta_post_flow_design_kit.html and the images in docs/kit_screenshots/.
2. Every new screen, card, sheet, row, badge or state in this feature MUST be assembled from the shared components listed in docs/HUB_DESIGN_CONTRACT.md. Do not create one-off widgets or a second version of an existing component.
3. If no existing pattern fits, STOP and report what is missing. Do not invent a style. I will add the pattern to the kit first.
4. Tokens only: ColorFamily, spacing, radius and typography from lib/core. No hardcoded hex, radius or text styles. Hub chrome is brand purple, at most one content hue, semantic colors only for status.
5. Dark, light, RTL, text scale 1.3 and 9 locales through the existing catalog. Skeletons instead of spinners; empty, zero-result, offline, error and flag-OFF states in kit style (flag-gated controls hidden, never disabled).
6. Compliance flags stay fail-closed. No payment or booking-confirmation wording. No star ratings or reviews.
7. When finished: add or update golden tests (dark and light), update the status of this feature in docs/raabta_hub_feature_coverage_matrix.md to B, and add a line to docs/HUB_DESIGN_CONTRACT.md if a new shared component was introduced.
