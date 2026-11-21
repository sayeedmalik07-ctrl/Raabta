# Official scam advisories (`scam_advisories`)

Editorial, official-source-only documents for ScamShield matching (Phase 12 evidence UI) and a small read-only list in the app.

## Firestore schema — `scam_advisories/{id}`

| Field | Type | Notes |
|-------|------|--------|
| `status` | string | `draft` \| `published` — clients only read `published` |
| `severity` | string | `info` \| `elevated` (only `elevated` may notify in Phase 30) |
| `category` | string | Phase 6 archetype id where it fits, or `govt_impersonation`, `fake_app`, `vendor_invoice`, `money_mule`, `other` |
| `title` | string | Short headline |
| `summary` | string | 1–3 sentences, no accused persons/businesses |
| `redFlags` | string[] | Generic warning signs |
| `whatToDo` | map | Locale → string (`English` required, `Arabic` expected) |
| `claimedEntityIds` | string[] | Phase 11 Official Directory ids the scam *pretends* to be |
| `matchPhrases` | map | Locale → string[] (3–8 generic lowercase phrases, no PII) |
| `samplePattern` | string | Generic paraphrase only |
| `authorityRefs` | string[] | Phase 4 Authority Directory ids (e.g. `moi`, `qnb`) |
| `sourceName` | string | Publisher of the advisory |
| `sourceUrl` | string | HTTPS link to the source page |
| `sourceDate` | timestamp | Date on the source |
| `publishedAt` | timestamp | When Raabta published |
| `expiresAt` | timestamp | Default ~90 days after publish |

**Security rules:** public read only when `status == published` and `expiresAt > request.time`; writes `isAdmin()` only.

**Composite index:** `status` ASC, `expiresAt` ASC, `publishedAt` DESC.

## Authoring

No admin UI — create/edit documents in the Firebase console (or run `tools/seed_scam_advisories.mjs` after review). Keep **5–10** active advisories; set `expiresAt` ~90 days out.

Import seed drafts: verify wording against each `sourceUrl` before setting `status` to `published`.

## Client behaviour

- One Firestore query per 6-hour Hive cache window (stale-while-revalidate).
- `AdvisoryMatcher` is deterministic (entity overlap or ≥2 phrase hits); max 2 matches.
- Push: `ScamAdvisoryPushHook` — unwired until Phase 30 `scamAdvisoryAlert` preference exists.

## Legal / editorial

Do not name persons, phone numbers, accounts, or businesses as scammers. Brands may appear only as impersonated parties when the source does so. Mandatory disclaimer is shown in UI.
