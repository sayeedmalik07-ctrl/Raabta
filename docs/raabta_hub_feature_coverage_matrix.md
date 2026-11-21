# Raabta Hub Feature Coverage Matrix (design-kit coverage check, 26 Oct 2026)

Purpose: every feature in each core hub, built or not, mapped to a design-kit component and a tier, so modernization never meets a screen the kit has no pattern for. Built from the project history; Cursor's audit must confirm what is actually in the app.

Status codes: B = confirmed built · W = prompt written, run not confirmed · C = chosen in research, prompt/build not verified · I = idea or parked · X = rejected, shelved or removed (do NOT design).
Tiers: T1 = hub landing, listing/detail, post flow, primary tools (within 2 taps of Home or nav) · T2 = other hub sub-screens · T3 = long tail (history, settings, legal, admin).
Kit refs: HUB = raabta_hub_design_kit.md (section number) · SUB = raabta_hub_subscreen_kit.html pattern · POST = raabta_post_flow_design_kit.html · HOME = Home kit.

## Cross-hub (shared by several hubs)
| Feature | Status | Tier | Kit |
|---|---|---|---|
| Hub landing anatomy (header, search, strip, quick actions, filters, feed, notice) | B | T1 | HUB 3 |
| Centre Post button (nav) opening the 5 verticals; old Speed-Dial FAB removed; drafts moved to Profile | B | T1 | POST, HUB 11 |
| 5 schema posting flows, dynamic field renderer, category picker (tree + search), photo picker, current-location default, Zone/Street/Building entry | B | T1 | POST, HUB 11 |
| Listing detail screens (extended schema attributes: Housing, Vehicle, Electronics, others) | B | T1 | SUB Listing detail, HUB 13 |
| Chat per vertical + Report + Block + Blocked Users screen + platform-hopping reminder | B | T2 | SUB Chat, HUB 14 |
| Structured actions: Make Offer (Market), Schedule Viewing (Housing), Request Quote (Services), Application Status (Jobs, native only); all behind Decision 25 flags except Application Status | B | T2 | SUB Chat, HUB 14 |
| Saved Search Alerts + management screen | B | T2 | SUB Saved, HUB 15 |
| My Activity (pending actions) in Profile | B | T2 | SUB Saved, HUB 15 |
| Owner listing management (my listings, pending items overview, QR for listing, report) | B/C | T2 | SUB Saved, HUB 15 |
| Trust badges and tiers (Verified, Official, Community), response-rate badge | W | T1 | HUB 4, 16 |
| Skeletons + optimistic UI (reversible taps only) | W | T1 | HUB 1, 7 |
| Conversational search, voice input, zero-result recovery | W | T1 | HUB 4 (strip), HOME search |
| Compliance notices, posting acknowledgment, flags (offers, viewings, quotes, business quotes/appointments, paid boosts, business ads) fail-closed | B | T1 | HUB 6 |
| Boost Listing, Premium, Business Advertise screens | B (held, flag OFF) | T3 | Do not restyle until flags are decided |
| Admin dashboard screens | B | T3 | Out of scope (keeps its own red/amber admin style) |

## Housing (pilot hub)
| Feature | Status | Tier | Kit |
|---|---|---|---|
| Browse, filters, ListingCard, detail with extended attributes (furnishing, bed/bath grids, kitchen, parking, A/C, Kahramaa, internet, rental period, features) | B | T1 | HUB 4, SUB Listing detail |
| Schedule a Viewing (request, confirm, counter time, reminders) | B (flag OFF at launch) | T2 | SUB Chat |
| Housing "Message" gated while viewing flag is OFF | B | T1 | HUB 4 detail bar (verify exact launch contact path) |
| Saved searches, My Activity, owner viewings overview | B | T2 | SUB Saved |
| Tenancy Truth Engine link, Rent & tenancy rights | B | T1 | HUB 16 (bridge card) |
| True Move-In and Monthly Cost, family-zone/occupancy check, move-in/move-out condition record, deposit-return pack, My Home tenant hub, Landlord Pack, lease-renewal reminder | C | T2 | HUB 16 + tool pattern (verify built) |
| Neighbourhood-verified + price-fairness badges, photo-reuse "Seen on site", listing quality score, listing history + days on market + building pages, ownership proof check, internet-at-building, commute matrix, heat and cooling facts card, remote viewing helper, photo compliance checker | C | T1/T2 | HUB 4 badges, SUB Listing detail |
| Takeover/Sublet listing type, Qatar address picker, share-link health | C | T2 | POST |
| Response Rate and Speed badge | W | T1 | HUB 4 |

## Jobs
| Feature | Status | Tier | Kit |
|---|---|---|---|
| Verified employers vs Community posts, JobCard, source-tier badge, "Apply on employer site" | B/C (aggregator phases unverified) | T1 | HUB 4, 5 |
| Jobs screen audit fix (posting tab, requirements section, live data) | B | T1 | HUB 4, POST |
| Application Status (Raabta-native only) + candidate pipeline for employers | B | T2 | SUB Chat, Saved |
| Employer Track Record + Check This Employer lookup + offer safety checklist | B | T1 | HUB 16 |
| Agency Verification Check (origin portals, MOL Qatar-side list idea) | B / I | T2 | HUB 16 |
| Job Offer True-Value Calculator | B | T2 | SUB Tool |
| CV Maker v1-v4 (templates, ATS badge, photo, upload, storage cap), Digital Business Card QR | B | T2 | SUB Tool + HUB 17 (document tool) |
| Job freshness chips, auto-expiry, ethical-recruiter registers, Worker Card, Certificates Wallet, wage reference upgrade, Google for Jobs | C | T2 | HUB 4, 16 |
| Jobs inline trust wiring (salary one-liner, MOL fee link) | W | T2 | HUB 16 |
| Aggregator sources (ATS adapters, tiered polling), JobSourceEngine | C | n/a | Backend, no UI beyond JobCard |

## Business
| Feature | Status | Tier | Kit |
|---|---|---|---|
| Hub landing (header, search, strip, quick actions, filters, HubBusinessCard feed, footer notice) | B | T1 | HUB 3, 4 |
| Listing detail bottom sheet + HubDetailActionBar (call/WhatsApp/structured + save/share) | B | T1 | HUB 4 DetailActionBar, SUB Listing detail |
| Skeleton loading, catalog empty vs zero-result empty, load error state | B | T1 | HUB 1, 7 |
| RTL landing chrome + widget goldens (390w) | B | T1 | HUB 9 |
| Business post flow skin (host notice + hub skeleton on schema load) | B | T1 | POST, HUB 6 |
| BusinessCard, profile (logo, cover, per-day hours, website, social, services list, per-category fields) | B | T1 | HUB 4, SUB Listing detail |
| Structured contact by type (Book appointment / Request quote / Message) | B (flag OFF; CTA hidden) | T2 | HUB 4 detail bar |
| Business ads, boosts | B (flag OFF) | T3 | Hidden |
| Overture Places seeding, QR for listing | C | T2 | SUB Saved (owner tools) |

## Services
| Feature | Status | Tier | Kit |
|---|---|---|---|
| Hub landing (Providers/Requests segment, `HubServiceCard` feed, summary strip, quick actions, filters, skeletons, goldens) | B | T1 | HUB 3–4, 16 |
| Listing detail (`HubDetailActionBar`, quote section skin, flag-off hides quote UI) | B | T3 | SUB Listing detail, HUB 14 |
| Post entry via unified `PostFlowScreen` (`/services/post`) | B | T1 | Post engine (services vertical) |
| 24-category / 184-sub taxonomy browse (parameterized `ServiceCategoryScreen`, hub category grid, audit CSV) | B | T1/T2 | HUB 4 — `docs/services_taxonomy_hub_audit.csv` |
| AI "describe what you need" entry | W | T1 | Verify before styling |
| Request a Quote (submit, comparison, inflation note) | B (flag OFF default) | T2 | SUB Chat — UI built; gated by `quotesEnabled` |
| Lead-gen MVP (service_leads, My Requests) | W (may be superseded) | T2 | Verify before styling |
| Skill Exchange Board | W (flag default OFF) | T2 | Do not design until built and flagged on |

## Market (Marketplace, bottom tab)
| Feature | Status | Tier | Kit |
|---|---|---|---|
| ListingCard, Marketplace detail screen (schema fields), category-aware photo limits | B | T1 | HUB 4, SUB Listing detail — Batch A: landing goldens + raw-color guard; Batch B: `MarketplaceScreen` hub kit + shared `MarketplaceListingCard` (photo-led); Batch D: landing load-error (`GlassErrorState` + retry), hub post shell `PostFlowMarketplaceHubShell`, marketplace schema-load skeleton + retry; category browse T2: `CategoryListingsScreen` — `HubSubscreenScaffold` + hub loading / footer / refresh |
| Make Offer (24h, one counter) + seller pending-offers view | B (flag OFF) | T2 | SUB Chat, Saved |
| Condition scale + tested-working flag, prohibited-items guard, safe meetup spots, used-phone card, vehicle inspection link, donate-instead link, Warranty Shield import, registration-card scan prefill, transfer checklist | C | T1/T2 | HUB 4, 16 |
| Platform-hopping reminder, payment-phishing defence | B | T2 | SUB Chat |
| Leaving Qatar tag | B | T2 | HUB 4 filter chip |
| Bundling | X | n/a | Rejected |
| AI photo search | X (held back) | n/a | Do not design |

## Visa & Documents
| Feature | Status | Tier | Kit |
|---|---|---|---|
| Shared guide tile + deadline urgency row (`HubGuideCard`, `HubDeadlineUrgencyRow` in `lib/core/widgets/hub/`) — documented in `HUB_DESIGN_CONTRACT.md` | B | n/a | HUB 4 (GuideCard), SUB Guide — Batch A |
| Visa hub landing (`VisaHomeScreen`: aurora, `HubLandingHeader`, legal freshness, emergency CTA, deadline hero, guides grid, tools row, full tracker; `HubLoadingPlaceholder` for deadline load) | B | T1 | HUB 3, 4, 7 — Batch B |
| Guide detail (`VisaGuideScreen`: `HubSubscreenScaffold`, `HubLoadingPlaceholder` load, truth-engine + notices + steps; share in header) | B | T1 | HUB 1, SUB Guide — Batch C |
| Deadline tracker UI (`DeadlineTrackerWidget`: `HubDeadlineUrgencyRow`, `HubLoadingPlaceholder`, `GlassErrorState`, `GlassEmptyState`, hub tokens; `DeadlineAddDialog` tokens) | B | T1 | HUB 1, 6, SUB Guide — Batch D |
| Document Vault landing (`DocumentVaultScreen`: `HubSubscreenScaffold`, hub search + filter chips, `GlassEmptyState`, `HubLoadingPlaceholder`, `DocumentVaultStrings`) | B | T2 | HUB 3, SUB — Batch E |
| Scanner studio hub (`ScannerStudioScreen`: `HubSubscreenScaffold`, `HubLoadingPlaceholder` for recent list, brand accent) | B | T2 | HUB 3, 17 — Batch E |
| 6 step-guide flows with legal source + last-updated chip | B | T1 | HUB 4 (GuideCard), SUB Guide |
| Deadline Tracker (types, 30/7/1 notifications, status summary, urgency colors, attachments) | B/W | T1 | SUB Guide |
| Smart Scanner and PDF Studio, Document Vault (folders, viewer, search), contextual scan entry | B | T2 | HUB 17 |
| Leaving Qatar mode (Exit Permit, Travel Ban, Traffic Fines as 3 distinct cards; exit bundle: bank, health cover, Kahramaa) | B | T1 | SUB Guide |
| Know Your Home-Country Support, Before You Sign, Freelance Visa Truth Layer, Consumer complaint guide, Telecom terms, Buying a car guide | B | T2 | HUB 16 (info cards) |
| Attestation Route Planner, Start-by deadline upgrade, Driving License calculator and quiz | C / W (low priority) | T2 | SUB Guide / Tool |
| Ask My Documents | I (parked) | n/a | Do not design |
| Sponsor Transfer guide cross-link to Sponsorship Truth Engine | B/W | T1 | HUB 16 (bridge card) |

## Money Hub
| Feature | Status | Tier | Kit |
|---|---|---|---|
| Tabs Dashboard / Markets / Branches, `HubLandingHeader` + search row, rates hero + 7-day trends, exchange-house comparison (Batch B landing chrome + l10n + gold accent) | B | T1 | HUB 5, HOME rates card |
| Gold Intelligence (needs live-data fix), Cost of Living, Personal Budget, Zakat (premium upgrade) — Batch C: COL / Budget / Gold on `MoneyToolScreenScaffold` | B / W | T1/T2 | SUB Tool |
| Send Money Home comparison, EWA awareness card | W | T2 | HUB 16 (info card) |
| Bill Tracker, Bill Splitter (additive entries), Friends and Family Loan Tracker, bill upgrade series (deposit tracker, lease wizard, share-to-Raabta capture, expected-range band, settle card) | B / W / C | T2 | HUB 17 |
| Exchange Locator Pro (directory, map, branch details) — Batch D: embedded in Money **Branches** tab + gold chrome on detail/company; `/exchange-locator` root redirects to `/money?tab=2`; map/finder/favorites pull colors | B | T2 | HUB 5 |
| Money Hub full UX audit | B | n/a | Source of the tool-screen grammar |
| Fuel Intelligence, QSE Stocks | X | n/a | Removed or shelved |

## Community
| Feature | Status | Tier | Kit |
|---|---|---|---|
| Sections: Feed, Groups, Ask Qatar, News, Events, Lost and Found, composer, live data, premium redesign — Batches A–E: hub kit landing + sections, sheets/moderation chrome, goldens + color guard (A–E complete for presentation) | B | T1 | HUB 4, 19 |
| Moderation (auto-block, fundraising guard, investment interstitial, rephrase-on-block), Report, Block | B / W | T2 | HUB 19 |
| Context layer: group tagging, "Why am I seeing this", post-to opt-in, Pulse strip, confidential report identity split | B | T1/T2 | HUB 19 |
| Nationality group suggestion, Buddy System, Leaving Qatar tag | B | T2 | HUB 19 |
| Ask Qatar "Already asked?", accepted answers, Helper Temperature, Rumour Check, Events RSVP/waitlist/WhatsApp cards/voice questions, Lost and Found auto-match, Report It Right, Share to Raabta check | B | T2 | HUB 19 |
| Trust-tier labels | W (shared `HubContentTrustTierBadge` Batch A; not wired to feeds) | T1 | HUB 4 |
| Admin-only articles | I | n/a | Do not design |
| Cool Points, people-proximity map, full chat rebuild | X | n/a | Rejected |

## Housing pilot checklist (first batch)
Hub landing; listing card; listing detail (facts grid, extended attributes, trust badges, history, owner card, safety box, report); detail action bar with flags OFF and ON; posting flow (Housing path); saved searches and sheet; owner viewings overview; viewing request/confirm cards in chat; skeleton, empty, zero-result and offline states; light and dark; RTL; text scale 1.3.
