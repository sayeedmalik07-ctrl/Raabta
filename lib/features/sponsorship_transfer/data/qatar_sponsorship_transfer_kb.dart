/// Verified Qatar sponsorship transfer facts for AI injection.
/// Law 19/2020 (sponsorship) ≠ Law 18/2020 (labour notice) ≠ Law 17/2020 (wage).
abstract final class QatarSponsorshipTransferKB {
  static const lastVerified = '2026-06-01';

  static const disambiguation = '''
THREE-WAY 2020 LAW DISAMBIGUATION (mandatory — never merge):
- Law No. (17) of 2020 = minimum wage only.
- Law No. (18) of 2020 = amends Labour Law 14/2004 — resignation/termination NOTICE (1 month if under 2 years with employer, 2 months if 2+ years).
- Law No. (19) of 2020 = amends Law 21/2015 sponsorship/residency — NOC abolished, Art. 21 employer change, Art. 22 deleted.
- MOI Decree No. (51) of 2020 = executive regulation — transfer during permit validity OR within 90 days after expiry.
- Cabinet Resolution No. (6) of 2018 = Labour Dispute Resolution Committees (LDRC).
''';

  static const verifiedFacts = '''
VERIFIED SPONSORSHIP TRANSFER FACTS (use ONLY these):

Law 21/2015 (base): Regulates expatriate entry, exit, residence.

Law 19/2020 (in force 9 Sep 2020): Amends Arts. 21 & 23 of Law 21/2015; deletes Art. 22. New Art. 21: expatriate worker can change employer per MoLADSA procedures — NOC (No Objection Certificate) NO LONGER REQUIRED.

MOI Decree 51/2020 (19 Aug 2020): Expatriate must notify concerned MADLSA department; employer change must occur during residence permit validity OR within 90 days following expiry. This is the verified timing constraint — cite this for deadline/window questions.

Law 18/2020 (separate labour law): Written notice if resigning AFTER probation — 1 month if employed under 2 years with current employer, 2 months if 2+ years. Cite Law 18/2020 for post-probation NOTICE questions — NEVER attribute notice period to Law 19/2020.

Article 39 (Labour Law 14/2004 — probation): Probation up to 6 months maximum, usable only once with same employer. During probation, 1-month written notice applies when changing employer — distinct from post-probation Law 18/2020 rule.

Employer-to-employer transfer costs: New employer may compensate current employer for portion of recruitment costs and one-way air ticket — amount agreed between employers, capped at no more than 2 months of worker's current basic wage. Cost between employers, NOT deducted from worker pay. Raabta cannot verify actual agreed amount.

Article 57 (Labour Law 14/2004 — return travel on termination): Upon termination, employer bears cost of returning worker to place from which worker was recruited, or another place agreed by the parties. If worker joins another employer in Qatar before leaving, that return obligation shifts to the new employer. Do NOT invent a partial or percentage-based return-flight formula — Art. 57 does not create one.

Art. 22 deleted: Part of Law 19/2020 reform. Do NOT speculate on its original detailed content. Domestic workers covered separately under Law No. 15 of 2017 — redirect domestic-worker transfer questions there.

LDRC (Cabinet Resolution 6/2018): Labour Dispute Resolution Committees — judge-led panels (Court of First Instance level), meet ≥3× weekly; in wrongful dismissal can order reinstatement or compensation; appeal directly to Court of Appeal. Correct path if employer disputes transfer — NOT a fabricated admin shortcut.

QID cancellation emergency (separate from voluntary transfer readiness): MOI Airport Passports Department operational guidance (15 Jun 2026): after residence-permit cancellation, person must leave Qatar within 14 days (previously reported as 30 days); staying beyond two weeks incurs QAR 10/day; MOI advised checking Metrash before travel. Source is June 2026 MOI operational guidance — NOT Law 21/2015 Art. 19 (Art. 19's 14-day period is the sponsor's notification obligation to the competent authority, not the resident's departure window). Do NOT cite older MOI/Law 21/2015 web guidance that referred to 90 days as the current rule — that content is legacy/outdated vs June 2026 guidance. User must check status via Metrash/MOI themselves — Raabta has NO live QID API. MADLSA 16008 if improper/retaliatory. Scenarios differ: retaliatory, company closure, routine end-of-contract — do NOT flatten into one generic message.

Active transfer application protection: Once formal job-change/transfer application submitted through official electronic system, current employer should not cancel QID or file false absconding during process — if it happens, may be retaliation; MADLSA 16008 + keep application proof.

Employer disappearance/closure: MADLSA complaint still processable if employer unresponsive; may support wage/EOSB via LDRC; QID reactivation possible in some improper/retaliatory cases (MADLSA/MOI coordination). For unpaid LDRC ruling when employer gone → WSIF (Law 17/2018) — see EOSB escalation, do not duplicate WSIF details here.

Peer-reviewed context (German Law Journal / Cambridge Core, March 2024 — DATED, not current guarantee):
- 348,500+ change-of-employer applications approved MoL Nov 2020–Aug 2022.
- 67% of MoL complaints Oct 2021–Oct 2022 settled in mediation before/during process.

REJECTED CLAIMS — NEVER USE (even if user asks):
- "70% of applications stall" or any paraphrase — unverified marketing claim.
- "24 hours with a fixer vs 3 months without" — unverified commercial claim.
- Do NOT state WPS blocks, unpaid fines, or CR cancellation as confirmed legal blockers — at most say these can complicate transfers in practice without citing as law.

OUT OF SCOPE (decline or redirect):
- Domestic worker sponsorship transfer specifics → Law 15/2017 separate regime.
- Transfer approval likelihood or processing time prediction — no verified per-case data.
- In-app MADLSA filing — app does not submit on user's behalf.
- Rent, tenancy, EOSB/gratuity (separate features).
''';

  static String buildAssistantContext({
    required String locale,
    String? readinessSummary,
  }) {
    return '''
$disambiguation

$verifiedFacts

Last verified in app: $lastVerified
User language: $locale
${readinessSummary != null ? 'User readiness summary:\n$readinessSummary' : ''}

STRICT AI RULES:
- Plain language only. NOT legal advice.
- Attribute each fact to its CORRECT source law when asked (Law 19/2020 = NOC; Law 18/2020 = notice; Decree 51/2020 = 90-day window; Cabinet Res 6/2018 = LDRC).
- Answer ONLY from VERIFIED FACTS above.
- If asked about 70% stall rate or 24-hour fixer claims, decline and offer the dated 348,500+ / 67% statistics instead — framed honestly as historical data not a guarantee.
- If asked about domestic worker transfer, redirect to Law 15/2017 regime — do not answer from general sponsorship content.
- If asked what Article 22 originally said, give the limited verified answer (deleted in 2020 reform; domestic workers separate law) and decline to speculate further.
- Never use general model knowledge for unlisted legal claims.
- Do NOT predict approval likelihood or processing time.
- If asked about QID cancellation: give 14-day/fine guidance per June 2026 MOI operational guidance; direct Metrash/MOI self-check; MADLSA 16008; distinguish scenarios; NEVER claim Raabta can verify live QID status.
- Do NOT cite Law 21/2015 Article 19 as the source of the resident's 14-day cancellation departure window. Article 19's 14-day period concerns the sponsor's notification obligation.
- Do NOT cite older MOI/Law 21/2015 web guidance (90-day cancellation departure) as the current user rule — legacy/outdated vs June 2026 MOI announcement.
- If asked about protection during transfer application: cite employer should not cancel QID/file false absconding during active application.
''';
  }
}
