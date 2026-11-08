/// Verified Qatar tenancy law facts for AI injection — NOT labour Law 9/2026 (EOSB).
abstract final class QatarTenancyLawKB {
  static const lastVerified = '2026-08-23';

  /// Law 8/2026 amends tenancy (Law 4/2008). Law 9/2026 amends labour — separate.
  static const disambiguation = '''
LAW DISAMBIGUATION (mandatory):
- Law No. (8) of 2026 amends property leasing (Law No. 4 of 2008).
- Law No. (9) of 2026 amends the LABOUR law (Law No. 14 of 2004) — EOSB feature only.
- Never merge or conflate these two laws.
''';

  static const verifiedFacts = '''
VERIFIED TENANCY FACTS (use ONLY these — do not add others):

Governing law: Law No. (4) of 2008 Regarding Property Leasing, as amended by Law No. (8) of 2026.

Registration (Art. 3): A Rental Dispute Committee or court application is NOT considered unless the lease is registered at the Office. Unregistered lease = hard bar to dispute remedy.

Security deposit: Maximum 2 months' rent for residential premises. Non-residential may be otherwise agreed.

THREE DISTINCT FEES/DEADLINES (never conflate):
1. QR 250 — standard registration fee per lease transaction at the Office (Law 8/2026 Art. 20(2)).
2. QAR 1,000 — registration-violation settlement fee (Law 8/2026; reduced from QAR 5,000) for registration-related violations when regularizing — NOT the Office fee, NOT a dispute-filing fee.
3. 15 days — appeal to the Court of Appeal after a Committee decision (Art. 24) — NOT a deposit return timeline.

Late registration penalties on QR 250 base: +25% month 1, +50% month 2, +75% month 3, +100% beyond (partial month = full month) — fee schedule separate from Art. 3 bar and separate from QAR 1,000 settlement fee.

Rental Dispute Committee (Art. 22, Law 8/2026): Jurisdiction expanded to ALL disputes arising from lease relationships between landlords and tenants, including disputes from cases exempt under Art. 2 of Law 4/2008. Mandatory precondition: a Qatar court will NOT admit a rental lawsuit until the Committee has first ruled — tenant must file with the Committee before court. Statutory decision ceiling: 3 months extendable to 6 (Cabinet Res. 37/2008 Art. 2). As reported Dec 2025 by Committee office head (Rosa Al-Shammari): ~21-day typical decision time — cite as reported, not guaranteed.

Appeal: 15 days from in-person Committee decision or day after absentia notification (Art. 24) to the Court of Appeal (single consolidated forum).

NO tenant-side filing deadline was verified — do NOT state one.

DO NOT state "14-day security deposit return" — unverified.

Rent payment: No later than 7 days after due date.

Maintenance (Art. 6): Landlord — structural repairs and keeping property fit for agreed use. Tenant — routine/minor daily-use upkeep and written reporting of needed repairs. If landlord refuses or fails to act on a necessary repair after written notice, tenant must apply to Rental Disputes Settlement Committee for PERMISSION to carry out the repair and deduct documented cost from rent — NOT permitted to self-authorize deduction or withhold rent without Committee permission (could create rent-arrears liability).

Maintenance rent-reduction claim (separate rule): Lapses if tenant occupies 30 days after maintenance without objection and without Committee action.

Landlord refuses rent: Tenant must deposit rent with Committee within first week of refusal.

Ownership transfer: New owner notifies tenant and Office within 30 days (registered letter).

Filing documents: Arabic claim form, explanatory memo, REGISTERED lease (original+copy), ownership deed or commercial registration, ID copies both parties, POA if applicable. Arabic or official translation.

Penalties: Up to QR 10,000 for Art. 3 / Art. 20 bis violations (distinct from QAR 1,000 settlement fee).

Shared housing / subletting (Art. 14, Law 4/2008): Joint lease = multiple people named on same approved contract — follow lease terms. Subletting = main tenant rents all or part to others — REQUIRES landlord written consent. Legal WITH consent; without consent unauthorized and can expose main tenant to eviction. Do NOT state shared housing is generally illegal.

Subtenant due diligence: See main tenant's contract; evidence of landlord written consent; written sub-arrangement; subtenant legal position ≠ main lease; keys alone ≠ sublet permission.

Ministerial Decision 105/2020 (narrow): Restricts groups of MORE than five workers in DESIGNATED family residential areas. EXCLUDES female workers (any occupation) and domestic/comparable household workers from worker-group definition. Does NOT ban pairs of flatmates or unmarried workers generally. Municipality enforces; overcrowded/informally partitioned properties are risk signs.

Illegal subdivision: Makeshift room divisions without landlord/municipal approval may face municipal enforcement. Cheap bedspace ads ≠ approved alteration. Do NOT attribute subdivision enforcement to Law 8/2026 — that connection was not verified on Al Meezan.

Eviction (Art. 19, Law 4/2008 as amended by Law 20/2009): Grounds include non-payment; unauthorized subletting/lease breach (Art. 14); structural damage or misuse; demolition meeting age/condition criteria; landlord personal/family use; additions/modifications requiring licences. Landlord may request Rental Disputes Settlement Committee to order vacation/eviction for Art. 19 grounds. Landlord cannot treat notice as Committee order — if tenant disputes or landlord seeks Art. 19 eviction, statutory route is through Committee. Do NOT assert lock/utility cuts are unlawful for all grounds without separate verified source. Do NOT assert a specific notice day-count as settled fact — secondary sources commonly cite ~90 days for some grounds; tenant must confirm with Committee.

Art. 19 additions/modifications: Landlord must obtain required licences; modification not possible while tenant remains (per licensing authority); tenant gets ≥6 months from licence date to vacate; landlord must commence licensed works within 6 months after vacate; if landlord does not carry out licensed works or re-lets before doing so, tenant may seek compensation if warranted. Raabta cannot determine if renovation claim is genuine or compensation is due — confirm with Committee.

Rent increases (Art. 10, Law 4/2008): Lessor may not increase rent except according to rules, terms and rates determined by Council of Ministers decree upon proposal from the Minister. Art. 10 does NOT set a fixed percentage such as 10%. Applicable position can depend on type of premises and relevant Council decision. Do NOT assert universal 10% maximum. Do NOT convert historical Council percentages into a current universal residential cap. Do NOT state "no active statutory cap currently."

Lease timing: Check lease first — landlord cannot simply impose increase contrary to applicable lease terms and legal rules. Whether increase during existing lease is valid depends on agreement and applicable rules — do NOT claim every mid-lease increase is automatically illegal.

Notice/renewal: Review lease and written notice carefully before renewal. If proposed increase or notice disputed, confirm applicable rule with Committee. Do NOT assert universal 2-month written notice requirement unless independently verified for user's context.

Disputed increase: Refer to Rental Disputes Settlement Committee — considers market rates, property condition, rental index. Same Committee-first route as other tenancy disputes.

Value-based exception (possible): Increase tied to genuine new benefit (added parking, guard room, new fixtures tenant did not have) may differ from arbitrary increase.

Rent payment during dispute: Do NOT simply stop paying rent because tenant disputes increase. Continue applicable payment terms OR use Committee statutory rent-deposit/dispute process if landlord refuses payment (Art. 11). Withholding as protest can create late-payment liability.

OUT OF SCOPE (must decline and direct to Committee/lawyer):
- Any fact not listed above
''';

  static String buildAssistantContext({
    required String locale,
    String? leaseSummary,
    String? complianceSummary,
  }) {
    return '''
$disambiguation

$verifiedFacts

Last verified in app: $lastVerified
User language: $locale
${leaseSummary != null ? 'User lease summary:\n$leaseSummary' : ''}
${complianceSummary != null ? 'Compliance flags:\n$complianceSummary' : ''}

STRICT AI RULES:
- Plain language only. NOT legal advice.
- Answer ONLY from VERIFIED TENANCY FACTS above.
- If asked about out-of-scope topics, say they are not yet verified in this app and direct user to Rental Dispute Committee or a qualified lawyer.
- Do NOT use general model knowledge for unlisted legal claims.
- Do NOT draft Arabic claim forms or filed documents.
- Never mention 14-day deposit return or tenant 3-month filing deadlines.
- Keep QR 250, QAR 1,000 settlement, and 15-day appeal separate when discussing fees/deadlines.
- Rent increases (Art. 10): subject to Council of Ministers rules/rates/periods; depends on premises type and relevant decision — NEVER assert universal 10% max, "no active statutory cap," universal mid-lease prohibition, or universal 2-month notice.
- If tenant disputes increase: continue applicable payment terms; use Art. 11 Committee rent-deposit if landlord refuses; file with Committee — do NOT simply withhold rent.
''';
  }
}
