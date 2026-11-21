# Services Modernization Decision (Nov 2026)

Status: decision taken on Sayeed's request ("make it light, advanced and easy to navigate; protect the cost strategy"). Most of Services modernization is already implemented; this document covers the remaining polish and one navigation change. Companion files: raabta_services_polish_and_navigation_cursor_prompt.md, raabta_hub_design_kit.md (section 22), raabta_hub_design_kit.html (tabs "Services", "Services: category", "Services: all"), kit_screenshots/hub_kit_services_*.png.

## 1. The concern
About 24 service categories and about 185 sub-categories ("sub screens") feel confusing and may work against the cost-optimization strategy.

## 2. What the build history says (facts to confirm in Cursor's Step 0)
- The Services taxonomy was seeded into Firestore (post_schemas) as 184 leaf categories. Categories are DATA, editable from the Admin Dashboard, cached in Hive. They are not 184 coded screens.
- Forms are not 184 either: the Universal Service Schema Templates fix grouped every leaf into 8 to 12 reusable template archetypes.
- Already built: Provider Listing vs Customer Request split (Part 9, one service_listings collection plus listingType), AI "describe what you need" entry and provider profile enhancement (Part 10), identity verification enforced, Request a Quote (flag OFF at launch), Report and Moderation tabs, saved-search alerts, My Activity rows.
- Chosen but not verified built: provider rate cards, non-review trust signals. Written, flag default OFF: Skill Exchange Board. An earlier lean lead-gen MVP (service_leads) may be superseded.
- Standing rules: no new collection without audit, no new paid service, AI optional and capped, audit first. There is no provider supply side yet.

## 3. Diagnosis
The 185 items are not the problem by themselves. The problem is that the whole taxonomy is exposed as navigation, so a user faces choice overload, and every leaf adds cost surface:

| Cost surface | Why a 184-leaf front door hurts |
|---|---|
| Choice overload | Customers must choose among many labels before they can say what they need |
| Empty states | With no supply side yet, most leaves would show "no providers" (a ghost-town feel) |
| Taxonomy reads | If leaves are separate documents, a cold start can cost up to 184 reads per user cache refresh |
| AI classification | Sending 184 labels in the category-detection prompt costs more tokens per call than sending 12 to 24 |
| Localization | 184 labels x 9 locales is about 1,650 strings to translate and review |
| QA matrix | 184 leaves x dark/light x RTL x 9 locales |
| Admin burden | Every leaf needs upkeep, merges and moderation context |

## 4. Decisions
D1. KEEP the data taxonomy (24 groups, 184 leaves) and every leaf ID. Nothing is deleted or renumbered. Existing listings and saved searches keep working.
D2. ADD a presentation layer of 12 FRONT GROUPS (mapping in section 5). It is configuration only; it does not change schemas.
D3. SEARCH FIRST. The Services landing shows "What do you need help with?", a "Describe what you need" card (AI optional, local search first), the 12 front-group tiles, and an "All services" row. No quick-action row, no filter chips, no per-leaf tiles on the landing.
D4. ONE parametrized category screen serves every group. Leaves are filter chips (about 6 to 8 visible, the rest behind "More"). No screen per leaf, ever.
D5. "All services" is the only place the full list lives: searchable, 12 group rows, long tail reachable through search.
D6. POSTING gets lighter without changing the schema. Customer request: describe, confirm a group chip, details (template), post. Provider: choose group, pick a leaf with the existing search-driven picker, template, rate card, post. The leaf stays required in the data; the picker makes it two taps or one search.
D7. NO per-leaf counts or per-leaf empty tiles. A leaf with no providers shows one calm inline line ("No providers yet for Carpentry. Post a request.") inside the category screen. Counts can be added later when volume justifies it (cost review first).
D8. SENSITIVE GROUPS (needs Sayeed's approval before build): Emergency becomes a static card of official emergency numbers, not a provider category. Health and care, childcare and security show a plain notice ("Raabta does not verify licences") and, when the existing verification flag is on, prefer identity-verified providers.
D9. COST BUDGET (targets in section 7). AI category detection sends group names only, local fuzzy search runs first, and the existing AI cap is unchanged.
D10. LOCALIZATION: native reviewed strings for the 12 front groups and the 24 groups first; leaf labels fall back to English until translated. No unreviewed machine translation (project stance).
D11. NOTHING ELSE CHANGES: schema templates, Part 9 split, listing model, quote logic and flags, moderation, verification enforcement, Firestore rules, saved-search keys, AI caps.

## 5. Front groups (non-destructive mapping of the 24 groups)
| Front group | Existing groups mapped to it |
|---|---|
| 1 Cleaning and laundry | Home Cleaning, Laundry |
| 2 Repair and installation | Home Maintenance, Home Installation, Appliance Repair, Electronics Repair |
| 3 Pest and outdoor | Pest Control, Outdoor Services |
| 4 Moving and transport | Moving |
| 5 Car care | Automotive |
| 6 Beauty and wellness | Beauty & Wellness |
| 7 Childcare and education | Childcare, Education |
| 8 Health and care | Home Healthcare |
| 9 Events, pets and lifestyle | Event Services, Pet Services, Travel & Lifestyle, Religious Services |
| 10 Business and professional | Business Services, Professional Services |
| 11 Digital and freelance | Digital Services, Freelancers |
| 12 Security and emergency | Security Services, Emergency Services (Emergency = static official numbers) |
These 24 names come from the taxonomy you gave earlier; Step 0 must confirm the seeded group names before mapping.

## 6. Taxonomy configuration (needs approval, data only)
Add optional display fields to the existing taxonomy config: frontGroupId, order, isPopular, aliases (search synonyms). If leaves are separate documents today, publish ONE versioned taxonomy snapshot document (or bundled asset with remote override) so a cold start is one read. Old IDs stay resolvable. No new collection unless the audit proves it is needed.

## 7. Cost and complexity budget (measure before and after)
- Taps from Services landing to a result list: 2 or fewer.
- Taps to post a customer request: 4 or fewer including the description.
- Firestore reads for the taxonomy on cold start: 1 (target), cached afterward.
- AI category detection: group names only (12 to 24 labels), local search first, existing monthly cap unchanged.
- Localized strings needed for launch quality: 12 + 24 (about 36) instead of about 200.
- Screens created per leaf: 0.

## 8. Rollout order
1. Audit and measurement (taps, reads, tokens, localization coverage).
2. Taxonomy presentation mapping and snapshot (config only).
3. Landing, category screen, All services (UI).
4. Posting picker tweaks and AI prompt size.
5. Sensitive-group handling (after approval).
6. States, light/dark/RTL, verification, contract doc.

## 9. Risks and mitigations
- Merged groups hide a niche service: search, aliases and "All services" keep every leaf reachable.
- Old listings point at old leaf IDs: IDs never change; only presentation maps them.
- Users expect their exact category name: aliases and synonym search cover this.
- Thin supply feels empty: the landing never shows empty tiles; empty states always offer "Post a request".

## 10. Open questions for Sayeed
1. Confirm the 24 group names in the seeded taxonomy.
2. Approve the Emergency static-card idea and the sensitive-group notice (D8).
3. Approve the optional config fields and the single taxonomy snapshot (section 6).
4. Keep the Providers and Requests tabs as they are (assumed yes).
