# Raabta Home Design Kit v2 (reference for Cursor) — supersedes v1

Source of truth for Home chip/card styling. Reuse existing lib/core tokens wherever a value exists (brand purple #6C3FC5, gold #FFB627, cyan #00D4FF). Visual specimen: raabta_home_design_kit.html (icons there are text placeholders, not the final icon family).

## 1. Principles
1. Color carries meaning. Few hues, each with a job. HUE BUDGET: at most 3 hues visible on one screen (brand purple + gold + teal), plus semantic green/amber/red only for status.
2. Calm surfaces, concentrated color: surface tint is low (8% dark / 5% light); strong color lives only in the icon chip, micro-line and status dot.
3. Hierarchy by spacing and size; identity by family; life by real data and touch response.
4. One shape language: card 24, tile 16, icon chip 14 (squircle), pills only for filters/status.
5. Never fake data. Light mode has its own recipe, not inverted dark.

## 2. Color families (dark / light / lightDeep)
lightDeep = text color and gradient end in light mode.

| Family | Meaning | Used on | dark | light | lightDeep |
|---|---|---|---|---|---|
| brand | Raabta, primary action | Hero, primary buttons, active nav, Explore Raabta core services, Know Qatar | #9B7BFF | #6C3FC5 | #4A2A96 |
| gold | Money and rights | ALL 4 Truth Engines (one family, differ by icon only), money tools | #FFB627 | #E39A00 | #8A5A00 |
| teal | Lifestyle and utility | Qatar Life, Daily Essentials, Prayer | #2DD4BF | #12A596 | #0A6B61 |
| green (semantic) | Protected / OK | ScamShield calm, success dots | #2ED3A0 | #12A877 | #0A6F4D |
| amber (semantic) | Due soon | expiring warranty, bill due | #FF9F43 | #E8801A | #9A520A |
| red (semantic) | Alert | ScamShield alert (reuse existing severity color if present) | #FF5A5F | #E03545 | #A81B2B |

Semantic colors never decorate; they appear only as dot/micro-line/border when status is real. Measure contrast and darken any value that fails section 8.

## 3. Premium card recipe
Dark:
- Surface: 150deg gradient white 9% to 2.5%, over family tint 8% on the navy base
- Border 1px white 10%, plus inner top highlight (inset 0 1px 0 white 20%)
- Icon chip: family @22% squircle, duotone icon in family color, glow family @35% blur 18
Light:
- Surface: 160deg gradient #FFFFFF to family tint 6%
- Border 1px family @14%, inner top highlight white
- Shadow: family @16% blur 16 y4 + rgba(15,23,42,.06) blur 24 y8
- Icon chip: solid gradient 145deg light to lightDeep, WHITE duotone icon, shadow family @35% blur 10 y4
- No BackdropFilter in light mode
Both: title 16sp/700, optional sublabel 12sp/400 secondary, micro-line 12sp/500. Top-aligned content, label NOT pinned alone at the bottom with dead space above.

## 4. Shape and spacing
Radius: hero 28, card 24, tile 16, icon chip 14. Spacing 4/8/12/16/24/32; card padding 16; grid gap 12; section gap 32.
PRESERVE existing hierarchy: Truth Engines cards larger/more glow than Qatar Life (keep current sizes and glow values).

## 5. Icon system
- One duotone rounded family (recommended: Phosphor Duotone via phosphor_flutter, or Solar). One stroke weight everywhere. 24px glyph inside a 44px squircle (40 on compact tiles).
- Truth Engines and ScamShield get the most distinctive glyphs (scales, left-right arrows, house with line, shield with plus, shield with check). Same size and weight as the rest.
- Replace the three current icon styles (colored circles, teal circles, tiny icon plus color bar) with this one.
- Adding a package requires my approval after Step 0 audit.

## 6. Micro-line rules
Only from data already loaded on Home; no new network calls/listeners (flag them). Never show salary, gratuity or money figures on Home; use status words. Empty state = useful prompt, never "0". Tones: neutral, live (family color + pulse dot), attention (amber/red).

## 7. Touch and motion ladder
| Level | Behavior | Spec |
|---|---|---|
| L1 Press | spring scale + haptic | 0.97, 120ms, HapticFeedback.selectionClick |
| L2 Bloom | glow spreads from touch point | radial family gradient @35%, 300ms fade |
| L3 Transition | icon chip morphs into destination header | container transform (animations package) or Hero fallback |
| L4 Ambient | pulse dot, ONLY for real live status | 1600ms, opacity .35 to 1 |
| L5 Data | count-up numerics once, one shimmer pass when live data arrives | 600ms / 900ms |
| L6 Icon animation | tiny Rive/Lottie on 4 Truth Engines + ScamShield, plays on press or first view | under 30KB each, static fallback |
| Search | on focus: AI orb glows and placeholder cycles useful prompts; on typing: orb pulses softly | no AI call for placeholders |
Entrance: fade + 8px rise, 280ms, 40ms stagger, once per session. Reduce motion (MediaQuery.disableAnimations): skip everything except a color change on press. One shared ticker for all pulse dots; RepaintBoundary per chip.

## 8. Accessibility
Text >= 4.5:1, icons/borders >= 3:1, card boundary visible in both themes. Test text scale 1.3, Arabic/Urdu RTL, longest locale string. Min touch target 48dp.

## 9. Reference code
```dart
@immutable
class ColorFamily {
  final Color dark, light, lightDeep;
  const ColorFamily(this.dark, this.light, this.lightDeep);
  Color main(Brightness b) => b == Brightness.dark ? dark : light;
  Color text(Brightness b) => b == Brightness.dark ? dark : lightDeep;
}

BoxDecoration premiumCard(ColorFamily f, Brightness b) {
  final c = f.main(b);
  if (b == Brightness.dark) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color.alphaBlend(c.withOpacity(0.08), const Color(0x17FFFFFF)),
                 Color.alphaBlend(c.withOpacity(0.08), const Color(0x06FFFFFF))]),
      border: Border.all(color: Colors.white.withOpacity(0.10)),
    );
  }
  return BoxDecoration(
    borderRadius: BorderRadius.circular(24),
    gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Colors.white, Color.alphaBlend(c.withOpacity(0.06), Colors.white)]),
    border: Border.all(color: c.withOpacity(0.14)),
    boxShadow: [
      BoxShadow(color: c.withOpacity(0.16), blurRadius: 16, offset: const Offset(0, 4)),
      const BoxShadow(color: Color(0x0F0F172A), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );
}
```

## 10. Home component specs (added in v2.1; visuals in the HTML kit)
All follow sections 1-8. Sample copy in the HTML is illustrative; real text comes from existing logic.

**Header:** glass card radius 24; avatar 44 with 2px brand ring; greeting (secondary) over name; "Qatar · temp" line; language pill; bell 38 with red count badge (semantic red). Greeting falls back to a time-aware line with no "Friend" placeholder once a name exists.

**Search + AI orb:** 44 pill field, 44 orb with brand gradient. On focus the orb gets a ring and soft pulse; idle placeholder cycles 3-4 useful localized prompts (no AI call).

**Today hero (one adaptive card, radius 28):** tag "Today" + time estimate; ONE filled brand-gradient primary button; optional ghost secondary (outlined brand).
- Setup state: ring with REAL completion %, title "Finish setup in 60 seconds", up to 3 step chips (radius 12, brand outline), primary button "Finish setup".
- Populated state: top priority from existing TodaysFocusCard logic, compact Expat Score ring on the right, primary action + "View score".
Ring = conic gradient brand to gold on a neutral track; inner disc = surface color. No second Expat Score card or duplicate "Today" labels beside it.

**Expat Score card:** header "Your Expat Score" + "View details"; 88px ring with score; status line ("Growing strong" + trend arrow) and one improvement hint; 5 category bars (Career, Housing, Financial, Community, Documents) in ONE hue (brand gradient fill), value right-aligned. Never one color per category (hue budget).

**Explore Raabta (core services):** 3-column grid, tile radius 20, min height 96, brand family icon chip 40, label max 2 lines (12.5sp/600). Show all tiles as a visible grid (no hidden horizontal scroll). Below: quiet outlined "See all services" button (ghost, not a loud gradient).

**For you (AI personalization):** header row "For you" + "Ask Raabta" link.
- Before setup: ONE slim brand card with a sparkle chip, a slow sheen sweep (4.5s, off under reduce-motion), text "Your picks are on the way" plus how to unlock.
- After setup: horizontal rail of pick cards (210 wide). Family follows the pick's domain (gold = rights/money, teal = lifestyle). Every pick shows a "Because ..." line explaining why it appears. No pick without a real reason; no fake urgency.

**Send money home (latest rates, replaces the scrolling ticker):** gold family card. Title + "Indicative" badge; currency segment (pills are allowed here, they are a filter) defaulting to the user's home currency; big rate number (34sp/800); line "1 QAR = X CCY" with weekly change (up = family text color, down = amber, never red); 7-day sparkline; "Updated N min ago"; text link "Compare exchange houses". Always labelled indicative; if data is stale or unavailable show the last value with its timestamp, never a blank.
