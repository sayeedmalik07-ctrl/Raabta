# Raabta Hub Design Contract

Authoritative reference for hub and sub-screen UI. Visual specs live in:

- `docs/raabta_home_design_kit.md` (global tokens, DomainCard, motion)
- `docs/raabta_hub_design_kit.md` (hub anatomy, per-vertical cards)
- `docs/raabta_hub_subscreen_kit.html` (filter sheets, detail scaffolds)
- `docs/kit_screenshots/` (reference PNGs)

## Rules

1. **Compose, don’t invent** — Use shared components below. No one-off cards, badges, or empty states.
2. **Tokens only** — `AppColors` family tokens, `AppSpacing` / `AppRadius`, `AppTypography` / `HubTypography`. No `Color(0x…)` in hub or feature presentation code.
3. **Hub chrome** — Brand purple for header, search, FAB, selected filters. At most one content hue per screen (gold = money/legal, teal = community). Semantic colors for status only.
4. **Honest data** — Hide empty badges, counts, and strips. No star ratings or review text.
5. **Flags fail-closed** — When a compliance flag is off, **remove** the control (no disabled placeholders). Layout must still look complete.
6. **States** — Skeletons (not spinners) on hub feeds; kit empty / zero-result / error / offline patterns.
7. **Locales** — All user-visible strings via feature catalogs (9 locales). RTL via `Directionality` / directional padding.
8. **Tests** — New shared hub widgets: `test/core/hub/hub_primitives_test.dart` + `hub_widgets_no_raw_color_test.dart`. Vertical hubs: golden + landing key tests under `test/screens/<vertical>/`.

## Market hub (Batch A–D)

| Surface | Implementation |
|---------|----------------|
| Landing T1 | `MarketplaceScreen` — shell tab **Market**; composes `HubLandingHeader`, `HubSummaryStripPadding` + `HubSummaryStripCard` (saved searches + my listings when data), `HubQuickActionTile` row, `hubSearchInputDecoration`, `buildHubFilterChip` (Leaving Qatar), category browse grid, `HubZeroResultRecoveryStrip`, `HubPostFab`, `HubLoadingPlaceholder`, `HubFeedFooterNotice`; load errors: `GlassErrorState` + retry (invalidate `marketplaceListingsProvider`) — **no** silent fallback catalog; feed uses shared **`MarketplaceListingCard`** (`lib/screens/marketplace/widgets/marketplace_listing_card.dart`) — photo-led like Housing, with trust row (`mp_trust_*`) on feed; true-empty feed uses `GlassEmptyState` with **`GlassEmptyStateAccent.brand`** when inviting first post |
| Category T2 | `CategoryListingsScreen` — `HubSubscreenScaffold` (category title + `mp_category_hub_subtitle`), brand **Post** in header → `/marketplace/post?category=:id`; pull-to-refresh; `HubLoadingPlaceholder` (listing silhouette) while loading; `GlassErrorState` + retry; `HomeSectionHeader` count row; grid `MarketplaceListingCard`; empty `GlassEmptyState` + brand post CTA; `HubFeedFooterNotice` when feed non-empty |
| Detail T3 | `MarketplaceListingDetailScreen` — `HubSubscreenScaffold` + sticky `MarketplaceListingDetailActionBar` (`HubDetailActionBar`): contact primary, make-offer secondary when `offersEnabled`; save/share icons; report in header when not owner. Body: trust `HubNoticeBanner`, condition via `MarketplaceStrings.conditionLabel`, `VehicleListingAttributesSection` when `hasSchemaAttributes` — **schema map unchanged** |
| Make offer T2 | `MarketplaceMakeOfferScreen` — gated by `complianceFlagsProvider.offersEnabled`; `MarketplaceListingOffersSection` shows **nothing** when flag OFF (fail-closed; no placeholder) |
| Chat T2 | `MarketplaceChatScreen` — `HubSubscreenScaffold` (listing title as subtitle); safety menu in header trailing; offer system bubbles use **brand** stroke/fill (not cyan); hub chrome alignment with classifieds banners |
| Post entry | `/marketplace/post` → `PostFlowScreen` (marketplace vertical) with **`PostFlowMarketplaceHubShell`** (`HubSubscreenScaffold`); photo-first and category-confirm steps use the same shell; schema load uses `PostFlowHubLoading` + `GlassErrorState` retry (invalidate `postCategoryFieldSchemaProvider`); prohibited-items and photo limits stay in post engine |

### Shared components (Market must compose)

| Component | File | Props / notes | When to use |
|-----------|------|---------------|-------------|
| `HubLandingHeader` | `lib/core/widgets/hub/hub_landing_header.dart` | title, subtitle, back, trailing | T1 hub chrome (Batch B) |
| `HubSummaryStripPadding` + `HubSummaryStripCard` | `hub_landing_header.dart`, `hub_summary_strip_card.dart` | cards with real counts only | Saved searches / my listings strip |
| `HubQuickActionTile` | `lib/core/widgets/hub/hub_quick_action_tile.dart` | icon, label, `onTap` | Sell, Saved, Favorites, Meetup shortcuts |
| `buildHubFilterChip` | `lib/core/widgets/hub/hub_filter_chip.dart` | label, selected, `onSelected` | Leaving Qatar and hub filters |
| `HubLoadingPlaceholder` | `lib/core/widgets/hub/hub_loading_placeholder.dart` | `HubLoadingPlaceholderKind` | Feed skeleton (replace spinner on landing) |
| `HubPostFab` / centre post | `lib/core/widgets/hub/hub_post_fab.dart` | per contract | Post entry from hub |
| `HubDetailActionBar` | `lib/core/widgets/hub/hub_detail_action_bar.dart` | primary, secondary, save, share | Listing detail sticky actions |
| `HubNoticeBanner` / `HubFeedFooterNotice` | `lib/core/widgets/hub/` | message, optional action | Compliance, trust lines |
| `HubZeroResultRecoveryStrip` | `lib/core/widgets/hub/hub_zero_result_recovery_strip.dart` | filters / undo | Search with no results |

**Rule:** New Market features compose these (and existing classifieds safety widgets). **Do not** add a second listing-card type; extend **`MarketplaceListingCard`** in place and document props here first.

| Shared listing | File | Props | When to use |
|----------------|------|-------|-------------|
| `MarketplaceListingCard` | `lib/screens/marketplace/widgets/marketplace_listing_card.dart` | `listing`, `locale`, `isSaved`, `onSave`, `onTap`, optional `onBoost`, `onGetQr`, `isSponsored`, `compactGrid`, `showTrustBadges` | T1 feed, T2 category grid, post preview (`showTrustBadges: false` in preview) |

### Queued features (documentation only — use shared components when built)

Each item below should ship using the named component and the kit section in `docs/raabta_hub_design_kit.md` / `raabta_hub_subscreen_kit.html`; **no new one-off cards**.

| Queued prompt | Component to compose | Kit |
|---------------|------------------------|-----|
| Make Offer flag ON | `HubDetailActionBar` + offer flow + `MarketplaceListingOffersSection` | SUB Chat, HUB states |
| Condition scale + tested-working flag | Shared listing/detail attribute row + schema display widgets | HUB 4, SUB Listing detail |
| Prohibited-items guard | `HubNoticeBanner` in post flow shell | Post flow kit |
| Safe meetup spots | `HubQuickActionTile` or detail info card via shared hub cards | HUB 4, SUB |
| Price-fairness badge | Shared hub badge pattern (extend `StatusBadge` / hub badge set) | HUB 4 |
| Used-phone card | Shared listing card variant (one implementation) | HUB 4 |
| Vehicle inspection link | Trust row / `HubNoticeBanner` on detail | SUB Listing detail |
| Donate-instead link | Inline text button in detail or notice | HUB 16 |
| Warranty Shield import | Schema/trust block on detail | SUB Listing detail |
| Registration scan prefill | Post flow schema step (existing `PostFlowScreen`) | Post flow kit |
| Transfer checklist | `HubNoticeBanner` or guide list pattern | SUB Guide / detail |
| Response badge | `HubSourceTierBadge` or hub feed chrome (if product approves) | HUB 4 |
| Perceived-performance overhaul | `HubLoadingPlaceholder` + list deferral; no new data layer | HOME motion ladder |

## Visa & Documents hub (Batch A onward — guide hub)

Guide hub (not a listings hub): **gold** ([`AppColors.goldFamilyMain`](lib/core/colors/app_colors.dart)) for legal freshness, law-updated chips, and deadline/legal emphasis; **brand purple** for navigation chrome and primary taps; **semantic** colors only for urgency (red / amber / green deadline rails). Legal **content** and `legal_sources` **data** are immutable in modernization batches — presentation only.

| Surface | Implementation (target) |
|---------|-------------------------|
| Landing T1 | `VisaHomeScreen` (`/visa`) — [`AnimatedAuroraBackground`](lib/core/widgets/animated_background.dart) + [`HubLandingHeader`](lib/core/widgets/hub/hub_landing_header.dart); hub search row ([`hubSearchInputDecoration`](lib/core/widgets/hub/hub_search_decoration.dart) + overflow menu: emergency help, add deadline); **Quick actions** — row of four [`HubQuickActionTile`](lib/core/widgets/hub/hub_quick_action_tile.dart) (scan, vault, scroll to tracker, Know Qatar); gold-accent **next deadline** hero from [`documentDeadlinesProvider`](lib/providers/visa_providers.dart) — empty → add-first; with data → headline + optional vault line + single **Start renewal** CTA (opens matching guide or tracker); **Guides** — vertical list [`HubGuideCard`](lib/core/widgets/hub/hub_guide_card.dart) (`VisaStrings` per `visaCategories`, law-updated chip from `lastLegalUpdateProvider`); [`HubFeedFooterNotice`](lib/core/widgets/hub/hub_feed_footer_notice.dart); full [`DeadlineTrackerWidget`](lib/screens/visahelp/deadline_tracker.dart) below |
| Guide step T1 | `VisaGuideScreen` (`/visa/guide/:categoryId`) — [`HubSubscreenScaffold`](lib/core/widgets/hub/hub_subscreen_scaffold.dart); subtitle = steps·ETA from `visaCategories`; [`TruthEngineSourceLine`](lib/core/widgets/truth_engine_source_line.dart); optional official links row; gold-accent expandable step cards + doc chips + brand **Ask AI** CTA; [`HubFeedFooterNotice`](lib/core/widgets/hub/hub_feed_footer_notice.dart); **skeleton** load ([`HubLoadingPlaceholder`](lib/core/widgets/hub/hub_loading_placeholder.dart)), not spinner |
| Deadline Tracker T1 | `DeadlineTrackerWidget` — summary **filter-chip** row (horizontal scroll, [`HubLayoutTokens.filterChipHeight`](lib/core/widgets/hub/hub_layout_tokens.dart), semantic 16% tint per kit `TrustBadge`); [`HubDeadlineUrgencyRow`](lib/core/widgets/hub/hub_deadline_urgency_row.dart) for list rows; [`HubLoadingPlaceholder`](lib/core/widgets/hub/hub_loading_placeholder.dart) + [`GlassErrorState`](lib/core/widgets/glass_error_state.dart) + [`GlassEmptyState`](lib/core/widgets/glass_empty_state.dart); tokens only (no raw `Color(0x…)`); guide link uses `context.push('/visa/guide/…')` — **Batch D**; **do not** change notification or Firestore logic |
| Vault T2 | `DocumentVaultScreen` (`/document-vault`) — [`HubSubscreenScaffold`](lib/core/widgets/hub/hub_subscreen_scaffold.dart); [`hubSearchInputDecoration`](lib/core/widgets/hub/hub_search_decoration.dart) + [`buildHubFilterChip`](lib/core/widgets/hub/hub_filter_chip.dart); list rows [`GlassCard`](lib/core/glass/glass_card.dart); loading [`HubLoadingPlaceholder`](lib/core/widgets/hub/hub_loading_placeholder.dart); empty [`GlassEmptyState`](lib/core/widgets/glass_empty_state.dart); [`DocumentVaultStrings`](lib/features/document_vault/l10n/document_vault_strings.dart) for chrome; **Batch E**; **no** storage or deletion logic changes |
| Scanner T2 | `ScannerStudioScreen` (`/scanner`) — [`HubSubscreenScaffold`](lib/core/widgets/hub/hub_subscreen_scaffold.dart) (replaces `GlassScreenScaffold` app bar); recent docs loading [`HubLoadingPlaceholder`](lib/core/widgets/hub/hub_loading_placeholder.dart); [`scannerAccent`](lib/features/quick_actions/scanner/widgets/scanner_primitives.dart) → `AppColors.brandFamilyMain` (no raw hex); **Batch E**; **no** viewfinder/OCR/PDF pipeline edits |
| Leaving Qatar T1 | `LeavingQatarScreen` — three **distinct** exit-gate affordances (Exit permit, Travel ban, Traffic); presentation only |
| Know Qatar / info T2 | `KnowQatarScreen` + redirects — information cards with **source line** pattern |

### Shared components (Visa & Documents must compose)

| Component | File | Props / notes | When to use |
|-----------|------|---------------|-------------|
| `HubGuideCard` | `lib/core/widgets/hub/hub_guide_card.dart` | `icon`, `title`, optional `lawUpdatedLabel`, optional `metaLine`, `accentColor`, `onTap`, `layout` (`list` default = kit row + chevron; `compact` for grids) | **Six** guide rows on Visa landing; compact grids elsewhere |
| `HubDeadlineUrgencyRow` | `lib/core/widgets/hub/hub_deadline_urgency_row.dart` | `HubDeadlineUrgencyTier` → `hubDeadlineUrgencyColor`, `title`, optional `subtitle` | Deadline list rows; urgency rail matches kit green / amber / red semantic ladder |
| `LegalFreshnessIndicator` | `lib/features/legal_sources/presentation/widgets/legal_freshness_indicator.dart` | `locale` | Hub / guide “law updated” when driven by `lastLegalUpdateProvider` |
| `TruthEngineSourceLine` | `lib/core/widgets/truth_engine_source_line.dart` | source metadata | Step guides — **Source:** + last verified |
| `HubSubscreenScaffold` | `lib/core/widgets/hub/hub_subscreen_scaffold.dart` | title, subtitle, body | Guide and Tier-2 shells |
| `HubLoadingPlaceholder` | `lib/core/widgets/hub/hub_loading_placeholder.dart` | silhouette | Feed/tool loading — **not** `CircularProgressIndicator` on hub surfaces |

**Rule:** New Visa & Documents UI **composes** these (and existing `GlassEmptyState`, `GlassErrorState`, `HubFeedFooterNotice` where applicable). **Do not** add a second guide-tile or deadline-row implementation; extend **`HubGuideCard`** / **`HubDeadlineUrgencyRow`** in place and document new props here first.

### Queued features (documentation only — Visa & Documents)

| Queued prompt | Component to compose | Kit |
|---------------|------------------------|-----|
| Attestation Route Planner | `HubSubscreenScaffold` + `TruthEngineSourceLine` + `GlassPrimaryButton` / tool row | SUB Guide / Tool |
| Start-by deadline upgrade | `HubDeadlineUrgencyRow` + existing tracker providers (presentation) | SUB Guide |
| Driving License fee calculator and quiz | Existing `/driving` tool screens — align chrome with `HubSubscreenScaffold` / tool pattern only | SUB Tool |
| Deadline Tracker extension (types, notifications) | `HubDeadlineUrgencyRow` + tracker UI; **logic** requires product + approval | SUB Guide |
| Law audit fixes | Content/source data — out of design-batch scope | — |
| Ask My Documents | **Parked** — do not design or implement | — |

## Shared components (`lib/core/widgets/hub/`)

| Component | Use |
|-----------|-----|
| `HubLandingHeader` | Hub title + subtitle + back + optional trailing |
| `HubSummaryStripPadding` + `HubSummaryStripCard` | “What needs me” strip (real data only) |
| `HubQuickActionTile` | Four-across quick actions |
| `buildHubFilterChip` / `HubAdvancedFilterToggle` | Filter row + advanced sheet entry |
| `HubBusinessCard` | Business feed |
| `HubJobCard` | Jobs feed |
| `HubServiceCard` | Services provider / request feed |
| `HubLoadingPlaceholder` | Feed skeleton (`listing`, `businessCard`, `serviceCard`, `serviceCardRequest`, `formTool`) |
| `HubFeedFooterNotice` / `HubNoticeBanner` | Compliance footer / inline notice |
| `HubPostFab` | Post entry (hubs with posting) |
| `HubDetailActionBar` | Sticky detail primary / secondary / save / share |
| `HubZeroResultRecoveryStrip` | Filter relax + undo |
| `HubPickerSheet` + `buildHubChoiceChip` | Category / area pickers |
| `HubSourceTierBadge` | Jobs source tier |
| `HubContentTrustTierBadge` | Community content trust (not job source tier) |
| `HubPostCard` | Community feed / Ask Qatar / group posts |
| `HubCommunitySheet` | Community moderation & context sheets |
| `HubCommunityModerationNotice` | Calm inline moderation copy |
| `communityHubAccent` | Teal social accent getter |
| `HubGuideCard` | Visa / Documents (and other) guide hub tiles |
| `HubDeadlineUrgencyRow` | Deadline lists — semantic urgency rail |

## Money hub — tool scaffold (Batch A)

**Chrome:** `HubSubscreenScaffold` (aurora + `HubLandingHeader`). **Accent:** `AppColors.goldFamilyMain` for refresh and tool status strips (money vertical). **Honesty:** corridor disclaimers stay on `CorridorDisclaimerBanner`; stale/live semantics stay on `MoneyLiveChip` / provider truth cards — do not restyle cached data as live.

| Component | File | Notes |
|-----------|------|--------|
| `MoneyToolScreenScaffold` | `lib/core/widgets/hub/money_tool_screen_scaffold.dart` | Gold `RefreshIndicator`; slots: disclaimer → hero → status → source; scroll body; header trailing composes with refresh (e.g. report transfer). |
| `MoneyToolStatusRow` | same | Gold-tint strip for indicative / verification one-liners. |
| `MoneyToolHeroSendAmount` | same | Optional large QAR send amount (`MoneyAnimatedFigure`) for send-first tools. |

| Surface | Implementation |
|---------|------------------|
| Remittance comparator T2 | `CorridorComparatorScreen` — `MoneyToolScreenScaffold`; `CorridorDisclaimerBanner` in disclaimer slot; `MoneyToolStatusRow` (`mc_tool_indicative_line`); `HubFeedFooterNotice` at scroll end; subtitles `mc_tool_subtitle` / `mc_tool_indicative_line` in `MoneyComparatorStrings`. |

| Landing T1 | `MoneyScreen` — `MoneyHubShell`: `HubLandingHeader` (`showBack: false` when not a pushed route) + `hubSearchInputDecoration` (filters Dashboard live-rates grid by code / country / English name) + tab bar **Dashboard / Markets / Branches** (`MoneyHubStrings` `shell_*`); gold accent via `moneyHubAccent` (`AppColors.goldFamilyMain`); tool grid accents unified to gold. **Branches** tab embeds `ExchangeLocatorPanel` (+ `HubFeedFooterNotice`) so the exchange-house list is visible in-hub; `locatorTab` query selects sub-tab (0–3). **Router:** `/exchange-locator` (root only) redirects to `/money?tab=2&locatorTab=` (maps legacy `?tab=` → `locatorTab`). Branch/company detail routes stay `/exchange-locator/...`. |

**Batch C — Money tools (T2):** `MoneyToolScreenScaffold`; optional `customBody` when nested `TabBar`/`TabBarView` (no duplicate outer refresh). `CostOfLivingScreen` — disclaimer slot + `HubFeedFooterNotice`; `PersonalBudgetScreen` — disclaimer + share in header trailing + footer; `GoldDashboardScreen` — subtitled header, gold `TabBar` indicator.

**Batch D — Exchange Locator (Money vertical):** **Money Hub → Branches** embeds `ExchangeLocatorPanel` + `HubFeedFooterNotice` (same chrome as kit); nested pull-to-refresh per sub-tab. **Deep links:** `/exchange-locator` redirects to `/money?tab=2` (query `tab` on legacy URL maps to `locatorTab`). **`BranchDetailScreen` / `CompanyDetailScreen`** — `MoneyToolScreenScaffold` + pull-to-refresh; branch share in `headerTrailing` with gold refresh; gold `TabBar` / `RefreshIndicator` in embedded panel & branch tabs; `LiveRatesLinkButton` uses gold (link to Money Hub rates).

## Services hub (Batch A–D baseline)

| Surface | Implementation |
|---------|----------------|
| Landing T1 | `ServicesHomeScreen` — header, search (“What do you need help with?”), Providers/Requests segment, summary strip (hidden when empty), Describe card, **12** `ServicesHubFrontGroupGrid` tiles, `ServicesHubAllServicesRow` → `/services/all`, optional `ServicesHubVerifiedStrip`, `ServiceHubListingCard` feed, footer, FAB (**no** quick-action row or filter chips on landing) |
| Detail T3 | `ServiceListingDetailScreen` — `ServiceHubSubscreenScaffold` + `HubLandingHeader`, notice, `ServiceHubListingCard` summary, `ServiceRequestQuotesSection` (when `quotesEnabled`), `ServiceListingDetailActionBar` |
| Quote submit / chat | `ServiceSubmitQuoteScreen`, `ServiceQuoteChatScreen` — hub field skin, brand accents |
| Post entry | `/services/post` → `PostFlowScreen` (`PostVertical.services`) with `PostFlowServicesHubShell`, host notice, `PostFlowHubLoading`; legacy `post_service_listing_screen` deprecated |
| Long tail T3 | `ServiceCategoryScreen`, `MyServiceListingsScreen` — `ServiceHubSubscreenScaffold`, `ServicesHubBrowseSegment`, `HubNoticeBanner`, `ServiceCategoryLeafChipRow` (~7 leaves + More sheet), `HubPostFab`, pull-to-refresh, inline empty copy (providers vs requests), `ServiceHubListingCard` feed |
| All services T2 | `ServicesAllServicesScreen` — search, **`HubNoticeBanner`**, **12 front-group rows** (`ServiceSubcategoryTile` compact): filters via `matchingFrontGroupIds` / `frontGroupMatchesQuery`, leaf previews via `previewLeavesForFrontGroup`, tap uses `primaryCategoryIdForFrontGroupTap` → `/services/category/:id` |
| Taxonomy T2 | 24 categories × 184 sub-services → one `ServiceCategoryScreen` (+ `?serviceName=`); hub **`ServicesHubFrontGroupGrid`** (12) + **`ServicesHubAllServicesRow`** → `ServicesAllServicesScreen`; audit `docs/services_taxonomy_hub_audit.csv` |
| Quote T2 | `ServiceSubmitQuoteScreen`, `ServiceQuoteChatScreen` — hub subscreen scaffold |

## Services taxonomy — presentation (Batch A)

Browse taxonomy for the hub is **static Dart** (`lib/screens/services/data/service_taxonomy.dart`) — **zero Firestore reads**. Posting category paths use **`post_schemas`** (Firestore + Hive cache) — unchanged.

| Field | Purpose |
|-------|---------|
| `ServiceCategory.id` | **Immutable** leaf-group key (24 values). Never rename — listings and saved search `categoryId` point here. |
| `frontGroupId` | One of **12** `ServiceFrontGroupIds` — maps the 24 categories into landing tiles (`lib/screens/services/data/service_front_groups.dart`). |
| `presentationOrder` | Sort within the 24 rows and within a front-group bucket (1–24, unique). |
| `isPopular` | Optional hub highlight (Batches may surface; no extra reads). |
| `searchAliases` | English synonyms for **local** taxonomy search only (`searchServiceTaxonomy`). |

**Adding a service group or leaf** (after Batch A): edit `service_taxonomy.dart` and the mapping in `docs/raabta_services_modernization_decision.md` §5; extend `ServicesStrings` for new UI labels. **No new route or screen** for a new leaf — still `ServiceCategoryScreen` + `?serviceName=`.

**Queued hub components** (compose; file paths assigned in landing/category batches):

| Component | Role |
|-----------|------|
| `FrontGroupTile` | One of 12 landing groups → navigates or expands mapped categories |
| `CategoryChips` | `ServiceCategoryLeafChipRow` + `ServiceCategoryLeafChips.showMoreSheet` — ~7 leaf chips + “More” |
| `DescribeCard` | “Describe what you need” — AI optional, local search first (F) |
| `ServiceCard` / `HubServiceCard` | Provider + request feed cards (existing) |

| Queued prompt | Notes |
|---------------|--------|
| Request a Quote (flag ON) | Uses existing quote routes + `HubDetailActionBar` |
| Provider rate cards | Presentation on detail / listing |
| Non-review trust signals | Badges only; no star text |
| Skill Exchange Board | Flag OFF default; composes hub cards |
| Response badge | Feed chrome only |
| Lead-gen decision | Out of scope until product call |

## Community hub (Batch A — shared primitives)

**Chrome:** brand purple (`AppColors.brandFamilyMain` / `brandFamilyText`) for headers, selected filters, primary taps, and sheet chrome. **Content accent:** teal (`communityHubAccent` → `AppColors.tealFamilyMain`) for pulse strips, social avatars, and helper-temperature chips only — not hub chrome.

| Component | File | Props / notes | When to use |
|-----------|------|---------------|-------------|
| `communityHubAccent` / `communityHubAccentText` | `lib/core/widgets/hub/community_hub_accent.dart` | getters | Teal social accent; never replace brand chrome |
| `HubContentTrustTierBadge` | `hub_content_trust_tier_badge.dart` | `label`, `HubContentTrustTier` | Official, Verified, Community, AI-derived on PostCard (**W** labels until product strings land) |
| `HubPostCard` | `hub_post_card.dart` | author, body, trust tier, meta, helper temp, why link, overflow | **One** community feed card — extend in place; Batches B–C wire feeds |
| `HubCommunitySheet` / `HubCommunitySheetBullet` | `hub_community_sheet.dart` | title, child; bullet rows | Why am I seeing this, moderation menus (compose `HubPickerSheet`) |
| `HubCommunityModerationNotice` | `hub_community_moderation_notice.dart` | message, optional `Edit` action | Calm rephrase / block inline notices |
| `HubLoadingPlaceholder` | `hub_loading_placeholder.dart` | `HubLoadingSilhouette.postCard` | Community feed skeleton |
| `GlassEmptyState` | `glass_empty_state.dart` | `GlassEmptyStateAccent.teal` | Community empty states (teal/brand **HomeIconBadge** chip + CTA brand pill) |
| `CommunityHubIcons` | `community_hub_icons.dart` | `sectionChip`, `emptyStateChip`, `ctaLeading`, `actionGlyph` | Section headers, empties, CTAs, social actions — teal social + brand chrome |

| Landing T1 | `CommunityScreen` — `HubLandingHeader` (`showBack: false`), `hubSearchInputDecoration`, teal `CommunityPulseStrip`, civic report chip (brand stroke), **6** `buildHubFilterChip` section tabs (Feed first), `TabBarView`; **Feed** uses `HubPostCard` + `HubLoadingPlaceholder.postCard` + teal `GlassEmptyState`; **Groups** without duplicate search/trending block; `HubPostFab` → Groups tab; `HubFeedFooterNotice`; refresh `brandFamilyMain` |
| Group detail T2 | `GroupScreen` — `HubSubscreenScaffold`, `GroupPostCard` composes `HubPostCard` + comments; `HubLoadingPlaceholder.postCard`; teal empty |
| Ask Qatar / News / Events / L&F T2 | Embedded: `CommunitySectionPrimitives` headers + `buildHubFilterChip` + brand refresh; standalone routes use `HubSubscreenScaffold`; News rows use `HubPostCard` + Official tier when Government |
| Ask Qatar question T2 | `AskQatarQuestionScreen` — `HubSubscreenScaffold`, brand refresh, post-card skeleton |
| Batch E — polish | Goldens (`test/screens/community/community_hub_golden_test.dart`), RTL + text-scale smoke tests, `community_hub_widgets_no_raw_color_test.dart` (no `Color(0x` / no `cyanGlow` under `lib/screens/community` & `lib/features/community`); pulse strip shows skeleton when counts are zero; **brand** chrome + **teal** social accents only |

**Rule:** Community screens **compose** shared hub components. `GroupPostCard` wraps `HubPostCard` — do not fork a second post card.

### Queued features (documentation only — Community)

| Queued prompt | Component to compose | Kit |
|---------------|----------------------|-----|
| Trust-tier labels (W) | `HubContentTrustTierBadge` on `HubPostCard` | HUB 4, 19 |
| Investment moderation interstitial (W) | `HubCommunityModerationNotice` + dialog chrome | HUB 19 |
| Skill Exchange Board | `HubPostCard` / `HubQuickActionTile` | HUB 19 |
| Admin-only articles (I) | **Do not design** | — |
| Remaining Community research items | Extend shared set first; report if no pattern | HUB 19 |

## Compliance flags (presentation)

| Flag | Services behavior |
|------|-------------------|
| `quotesEnabled` | Hide quote section, submit-quote secondary, and `/quote` UI affordances |

## When you add a component

1. Add the widget under `lib/core/widgets/hub/`.
2. Document it in this file.
3. Extend `hub_primitives_test.dart` and no-raw-color tests.
4. Update `docs/raabta_hub_feature_coverage_matrix.md` for the affected feature row.
