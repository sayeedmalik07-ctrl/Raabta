# Services taxonomy hub audit

**Scope:** All Services browse surfaces in `service_taxonomy.dart`, not 184 separate Flutter routes.

## Summary

| Layer | Count | Implementation | Kit status |
|-------|------:|----------------|------------|
| Top-level categories | **24** | `ServicesHubFrontGroupGrid` (12 front tiles → T2) + `/services/all` + `/services/category/:id` | **B** — `ServiceHubSubscreenScaffold` |
| Front-group long tail | **12** | `ServicesAllServicesScreen` (`/services/all`) — search filters 12 rows + leaf previews; tap → `/services/category/:id` | **D** — `ServiceHubSubscreenScaffold` |
| Sub-services | **184** | `ServiceCategoryLeafChipRow` (~7 + More sheet) on `ServiceCategoryScreen` (+ optional `?serviceName=` deep link) | **B** — same T2 screen |
| Physical route files | **7** | home, category, detail, my-listings, post (PostFlow), quote submit, quote chat | **B** (post via PostFlow) |

Legacy docs sometimes cite **15** groups; the live taxonomy defines **24** parent categories (**184** sub-services). Row-level detail: [`services_taxonomy_hub_audit.csv`](services_taxonomy_hub_audit.csv) (**208** rows = 24 category landings + 184 sub-filters).

## Kit mapping (HUB §3–4)

| Surface | Components |
|---------|------------|
| Hub T1 | `ServicesHomeScreen`, `ServicesHubFrontGroupGrid`, `ServicesHubDescribeCard`, `ServicesHubAllServicesRow`, `ServicesHubBrowseSegment`, `HubServiceCard` feed |
| All services T2 | `ServicesAllServicesScreen`, `GlassTextField` search, `HubNoticeBanner`, 12 × `ServiceSubcategoryTile` (compact), taxonomy helpers in `service_taxonomy.dart` |
| Category T2 | `ServiceCategoryScreen`, `ServiceCategoryLeafChipRow`, `HubPostFab`, listings feed |
| Detail T3 | `ServiceListingDetailScreen`, `ServiceHubSubscreenScaffold` |
| Quote T2 | `ServiceSubmitQuoteScreen`, `ServiceQuoteChatScreen` — hub subscreen + skeletons |
| Post T1 | `/services/post` → `PostFlowScreen` (`PostVertical.services`) |

## Out of scope (unchanged)

- Per-sub-service duplicate screens (anti-pattern; one parameterized screen).
- Taxonomy l10n (English names in `kServiceCategories` today).
- Legacy `post_service_listing_screen.dart` (deprecated; router uses PostFlow).

## Verification

- `test/screens/services/service_taxonomy_hub_coverage_test.dart` — counts, ID resolution, All services matching/tap helpers.
- `test/screens/services/services_all_services_screen_test.dart` — 12 rows, search empty state, navigation.
- `test/screens/services/services_hub_golden_test.dart` — `goldens/services_all_services_dark_390.png` (All services T2).
- Regenerate CSV after taxonomy edits: run the generator in repo maintenance or update CSV manually.
