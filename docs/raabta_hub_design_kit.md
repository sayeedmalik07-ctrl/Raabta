# Raabta Hub Screen Design Kit v1 (reference for Cursor)

Companion to docs/raabta_home_design_kit.md (v2.1). Hubs INHERIT everything there: color families, premium card recipe (dark and light), DomainCard, icon system, touch/motion ladder, accessibility thresholds, hue budget. This kit adds only what is specific to hub screens. Visual specimen: raabta_hub_design_kit.html (icons are text placeholders).

Hubs covered: Housing, Jobs, Business, Services, Market (Marketplace), Visa & Documents, Money Hub, Community.

## 1. Hub principles
1. One job per hub, one primary action. Hubs are "browse + act" screens, not dashboards.
2. Same anatomy everywhere (section 3), so a user who learns Housing already knows Jobs.
3. Continuity with Home: the Explore Raabta tile family (brand purple) is the hub's chrome color. Content accents add at most ONE more hue (gold for money/legal, teal for community).
4. Photos and facts lead on listing cards. Color is for status and trust, not decoration.
5. Honest data: every count, badge and status line comes from real data; hide anything empty.
6. Trust is visible but calm: source tier, freshness, response speed. NEVER star ratings or free-text reviews.
7. Compliance-safe: transaction-like flows can be switched OFF by fail-closed flags. When a flag is off, HIDE the control (never show a disabled or broken button) and layout must still look complete.
8. Perceived speed: skeletons instead of spinners; optimistic UI only for reversible taps (save/favorite), never for offers, quotes, applications or status changes.

## 2. Color per hub
| Hub | Chrome (header, active tab, primary button) | Content accent | Notes |
|---|---|---|---|
| Housing, Jobs, Business, Services, Market | brand | none (photo-led cards); semantic badges only | gold only for price-fairness info badge |
| Visa & Documents | brand | gold (legal/rights: deadlines, "law updated" chips) | |
| Money Hub | brand | gold (rates, money tools) | green/amber/red only as status |
| Community | brand | teal (social: pulse strip, groups, events) | trust-tier chips: Official=brand, Verified=green, Community=neutral |
Hue budget still applies: brand + one content hue + semantic status per screen.

## 3. Hub anatomy (top to bottom)
1. Hub header: title 24sp/800, one-line subtitle 13sp secondary, search field 44 high + filter button. Sticky on scroll with a token-border scrim (no white hairline).
2. Section tabs/segmented control (only hubs that have them: Services Providers|Requests, Money Dashboard|Markets|Branches, Community sections, Jobs Verified employers|Community posts).
3. Summary strip ("what needs me"): max 3 compact cards from REAL data (saved searches with new matches, my listings, applications under review, next deadline). Hide the strip if all empty.
4. Quick action row: 4 tiles (DomainCard compact, brand), tools and entry points the hub owns.
5. Filter chips row: horizontal pills (pills are allowed here, they are filters). Selected = brand tint + brand text. First item is a "Filters (n)" button when advanced filters exist.
6. Feed: cards by variant (section 4). 12 gap, 16 side padding.
7. Notice banner (information-only / host non-affiliation), quiet, 12sp, always at the end of the feed, not between cards.
8. Post FAB (existing Post Speed Dial): 56dp, bottom-right in LTR and bottom-left in RTL, scroll padding so it never covers the last card. Not shown on hubs without posting (Visa & Documents, Money Hub).
Spacing: section gap 24, in-section gap 12, card padding 14-16, radius per Home kit (card 22-24, tile 16).

## 4. Component specs
**HubHeader:** as above. Back arrow only when the hub is not a bottom-nav destination.
**SummaryStrip card:** icon chip 36, label 12sp secondary, value 14sp/700 (real data only), tap opens the filtered list. Pulse dot only for genuinely new items.
**QuickActionTile:** DomainCard compact vertical, label max 2 lines.
**FilterChip:** height 36, radius 999, 13sp/600; selected state animates 120ms.
**ListingCard (photo-led, Housing/Market):** 16:10 media with radius 20 top; save heart top-right (haptic, optimistic); optional corner tag on media; body: price 18sp/800, title 15sp/600 (2 lines), meta row (zone/area, "Listed 2d ago") 12sp, attribute row (icons + short values, max 4), trust badge row (max 3 badges).
  - Housing attrs: beds, baths, area, furnished. Housing badges: Verified listing, Fair price (gold, informational), Seen on site, Neighbourhood verified.
  - Market attrs: condition (defined scale), tested-working flag, distance. Badges: Price check, Meet in a public place.
**JobCard (text-led):** employer logo/initial 40, title 16sp/700, employer + location 12sp, SOURCE TIER badge (Verified employer = green, Community post = neutral), freshness line ("Posted 2d ago"), salary only when provided (never invented). Detail CTA reads "Apply on employer site" with an external-link glyph for aggregated listings; application status chips only for Raabta-native listings.
**ServiceCard:** Provider: avatar 44, name, service type, rate-card line ("From QAR 80"), badges (ID verified, Replies within 1h). Request: title ("Needs: ..."), area, posted time, replies count, "Open request" badge.
**BusinessCard:** logo square 48, name, category, open-now status (green dot + closing time), services chips (max 3). Contact CTAs follow the business type (Book an appointment / Request a quote / Message), each hidden when its flag is off.
**GuideCard (Visa & Documents):** gold icon chip 44, title, "6 steps · 10 min", "Law updated Oct 2026" chip (from legal_sources), chevron. Deadline card on top: gold, real date from Document Vault, ONE primary button.
**MoneyTool tile (Money Hub):** 3-column grid of DomainCards (gold family): Gold Intelligence, Send money home, Cost of Living, Personal Budget, Zakat, Bill Tracker, Bill Splitter. Rates hero reuses the "Send money home" card from the Home kit.
**PostCard (Community):** avatar, name, trust-tier chip, body (max 4 lines + "more"), meta row (replies, accepted-answer check, Helper Temperature chip), quiet "Why am I seeing this?" link. Moderation and report live in the overflow menu.
**TrustBadge:** height 22, radius 8, 10.5sp/700, tinted background 16% (green = verified/OK, gold = money info, brand = Raabta-derived signal, neutral = plain fact). Max 3 per card. Response badge text: "Usually replies within X" only above the minimum sample size.
**NoticeBanner:** neutral 6% tint, radius 14, 11.5sp. Text from existing localized compliance strings.
**DetailActionBar (listing detail):** sticky bottom, safe-area padded: primary button + save + share. Primary by vertical and flags: Message (default), Make offer (Market, flag), Request viewing (Housing, flag), Apply on employer site (aggregated jobs), Request a quote (Services, flag). If the primary is flag-off, fall back to Message; if chat is also gated, show no bar.
**States:** Skeleton (shape-matched, shimmer 1.4s), Empty (icon chip + title + body + "Save this search"), Zero-result recovery strip ("Showing nearby areas. Zone filter relaxed." + undo), Offline banner (last updated time), Error (retry), Flag-off (control hidden, no placeholder).

## 5. Per-hub spec
| Hub | Summary strip (real data only) | Quick actions | Filter chips | Card | Hub-specific modules |
|---|---|---|---|---|---|
| Housing | Saved searches (new), My listings | Post a property, Saved searches, Tenancy rights, Move-in cost | Rent/Buy, Zone, Price, Bedrooms, Furnished | ListingCard | Link to Tenancy Truth Engine; listing history/days on market on detail; viewing request only if flag on |
| Jobs | Applications (Raabta-native only), Saved jobs | Offer calculator, Check an agency, Employer record, My CV | Sector, Location, Posted, Salary | JobCard | Two sections never mixed: Verified employers vs Community posts; Employer Track Record link; no hiring-probability percentages |
| Business | My business completeness | Add business, Saved, Open now, Near me | Category, Open now, Area | BusinessCard | Per-type contact CTA (flag-gated); business ads off unless flag on |
| Services | My requests (open) | Post a request, Offer a service, Saved, Near me | Category, Area, Verified only | ServiceCard | Providers/Requests tabs; quote comparison only if flag on; non-review trust signals only |
| Market | Saved searches, My listings | Sell an item, Saved, Favorites, Safe meetup spots | Category, Condition, Price, Near me | ListingCard | Prohibited-items guard in post flow; Make offer only if flag on; no payment wording ever (price agreement only) |
| Visa & Documents | Next deadline (from Vault) | Scan document, Document Vault, Deadline tracker | none (guide hub) | GuideCard | 6 guides: Iqama Renewal, Exit Permit, Family Visa, Change of Employer (link out to Sponsorship Truth Engine, no duplicate content), Medical, Qatar ID; "law updated" source line per guide |
| Money Hub | none (rates hero instead) | tools grid | none | MoneyTool + rates hero | Tabs Dashboard / Markets / Branches; exchange-house list on Branches; indicative-rate labels |
| Community | Community Pulse (counts) | Ask Qatar, Events, Lost & Found, Groups | per section | PostCard | Section tabs: Feed, Groups, Ask Qatar, News, Events, Lost & Found; trust-tier chips; moderation notices; Share to Raabta check |
Verify in audit which modules above are actually built; never design UI for unbuilt features.

## 6. Compliance and trust rules (all hubs)
- Fail-closed flags: offers, viewings, quotes, business appointments/quotes, paid boosts, business ads are OFF by default. Hide controls; no "coming soon" teasers.
- No payment or booking-confirmation language anywhere. "Agreed price" never implies payment.
- No star ratings, review text, or "best" claims. Use factual signals (source tier, verified, freshness, response speed, listing history).
- External jobs: always show source and "Apply on employer site". Never imply Raabta submitted an application.
- Host/non-affiliation and information-only notices stay visible per existing strings; legal outputs show source and last-verified date.
- Sensitive amounts (salary, gratuity) never appear on hub cards or notification previews.

## 7. Motion and touch
Reuse Home kit section 7. Hub specifics: entrance stagger only for the first screenful; save heart = spring + haptic + optimistic fill with quiet rollback; tab switch cross-fade 160ms; filter chip selection 120ms; sticky header gains scrim after 8px scroll; pull-to-refresh uses brand-tinted indicator; all motion off under reduce-motion.

## 8. Data honesty
Summary strips, badges and counts need real providers. Empty = hide. Freshness always shown on listings. Zero results: relax ONE filter, say what changed, offer "Save this search".

## 9. Localization and RTL
All hub strings via existing catalog, 9 locales. Check chips, badges and price lines at the longest locale and text scale 1.3. FAB flips to bottom-left in RTL; carousels and tab order mirror; keep digits and currency codes legible (LTR runs inside RTL text).

## 10. Reuse map (audit must confirm real names)
GlassCard/GlassChip, DomainCard (Home kit), existing skeleton/shimmer component, ContentTrustTier chip (Community), Post Engine dynamic field renderer and listing models (do not unify the 5 listing models), Saved Search entry, zero-result recovery component, Post Speed Dial FAB, ScamShield safety tips, compliance notice widgets.
