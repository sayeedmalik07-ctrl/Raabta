/// Qatar mandatory health insurance knowledge (Law No. 22 of 2021) for Raabta AI.
class QatarHealthInsuranceKB {
  QatarHealthInsuranceKB._();

  static const lastVerified = '2026-08-01';

  static const topicKeywords = [
    'health insurance',
    'mandatory insurance',
    'law 22',
    'law no. 22',
    'moph insurance',
    'employer insurance',
    'insurance premium',
    'salary deduction insurance',
    'insurance exemption',
    'visitor insurance',
    'qhis',
    'coverage gap',
    'coverage exclusion',
    'maternity limit',
    'pre-existing condition',
    'co-insurance',
    'co-payment',
    'in-network',
    'hmc network',
  ];

  static bool isHealthInsuranceQuery(String message) {
    final lower = message.toLowerCase();
    return topicKeywords.any((k) => lower.contains(k));
  }

  static const injection = '''
QATAR MANDATORY HEALTH INSURANCE (Law No. 22 of 2021 — verify on Al Meezan / moph.gov.qa):

**Employer-sponsored coverage (resident employees):**
- Employers must provide MOPH-approved health insurance and issue an insurance card.
- **Article 13 — salary deduction prohibition:** The full mandatory premium must be borne by the employer. Any salary deduction or employee cost-sharing for the mandatory premium is prohibited and may be a separate fineable offence (distinct from not providing coverage at all). Evidence: payslips showing insurance-related deductions.
- Insurer must be registered with MOPH (Art. 11). Coverage must remain continuous across insurer switches (Art. 10).

**12 exemption categories (Cabinet Decision No. 9 of 2023 — general information only):**
1. Temporary residence permit holders
2. Visa-on-arrival visitors for up to 30 days from entry (insurance required if stay extends beyond 30 days)
3. Temporary entry travellers
4. Transit passengers
5. Diplomats, their spouses, and children under 16
6. Non-Qatari women married to Qatari nationals
7. Children whose mothers are Qatari nationals married to non-Qatari nationals
8. Widows or divorced non-Qatari women (unless remarried to a non-Qatari national)
9. Up to four domestic workers per Qatari national household
10. Detainees and prisoners
11. Orphans in care homes
12. Children whose fathers are unknown

Exemption status is fact-specific — MOPH is the authoritative source for a confirmed determination.

**Coverage Reality Check (pre-emptive — /health-insurance/coverage-reality-check):**
- **Known (statutory minimum — Law No. 22 of 2021):** outpatient/inpatient care, diagnostics/radiology, essential medicines, hospital stays, mandatory surgical procedures, basic maternity care, emergency care, children up to 18.
- **Possible (common patterns — NOT universal; user must verify their own policy):** cosmetic surgery; fertility beyond initial diagnostics; congenital conditions discovered after policy start; dental beyond emergency; optical beyond basic vision correction; alternative medicine; self-inflicted injuries; maternity sub-limits (caps despite basic maternity mandate).
- **Action checks for HR/insurer:** HMC in-network and prior approval for elective care; maternity sub-limit; co-insurance/co-payment on inpatient/outpatient; pre-existing condition exclusions/waiting periods; dependents (spouse, up to 3 children under 18) on the policy.
- **Dependent coverage addendum (same screen — /health-insurance/coverage-reality-check):**
  - **Known (employer-paid entitlement):** implementing regulation covers **worker + spouse + up to 3 children under 18**. **Parent coverage is not part of that employer-paid family entitlement.**
  - **Sponsored parents:** confirm applicable **sponsor-paid mandatory coverage** and any **additional policy requirements** — do **NOT** describe parents as categorically excluded from mandatory health insurance; do **NOT** claim a private policy is always required.
  - **Possible:** Dependent plan may be **thinner** than employee's own (coverage required, not equal benefits). **Maternity waiting periods** (often ~12 months continuous coverage) are **distinct from maternity sub-limits** — check both.
  - **Action:** Request **written dependent benefit schedule** from HR; escalate if not provided within ~a week; plan ahead if pregnancy is a consideration.
  - **Guardrail (parents):** If asked whether parents are covered, **distinguish employer-paid family coverage from sponsor-paid mandatory coverage**. Do **not** answer categorically that parents are uninsured or that private insurance is always required. Recommend verification of the sponsor's applicable coverage requirements and policy.
  - **CRITICAL:** Never assert the user's dependents are on a specific plan tier or waiting period without their schedule — general law/patterns only.
- **CRITICAL:** Never assert what the user's SPECIFIC policy covers unless they uploaded a policy document or entered details in Policy Explainer. Without that, say the answer depends on their policy schedule and recommend checking with HR/insurer directly. Do NOT rank or compare insurers.

**Raabta:** Health Insurance Truth Engine (/health-insurance) runs employer compliance checks, Coverage Reality Check (pre-emptive gaps), policy document explainers, and claim denial dispute tracking. Not legal or medical advice.
''';
}
