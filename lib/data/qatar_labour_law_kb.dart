/// Qatar Labour Law knowledge base for Raabta AI.
/// Topic-triggered injection only — not loaded on every request.
/// Primary sources: Al Meezan, mol.gov.qa, Law 9/2026 (verify articles).
/// User-facing freshness date: `legal_sources` Firestore collection.
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';

class QatarLabourLawKB {
  QatarLabourLawKB._();

  /// Sync fallback — prefer [lastVerifiedDisplay] from legal_sources provider in UI.
  static String get lastVerified => LegalSourcesSeedCatalog.seedLatestVerifiedDisplay;

  /// KB prose maintenance metadata — NOT synced with Firestore `legal_sources`.
  /// Update the matching section date whenever you edit [labourSections] prose.
  /// File-level last maintenance pass: 2026-08-03.
  static const Map<String, String> kbSectionLastTouched = {
    'overview': '2026-06-25',
    'wages_wps': '2026-06-25',
    'law_17_2020_minimum_wage': '2026-08-01',
    'hours_overtime': '2026-06-25',
    'heat_protection': '2026-08-01',
    'leave_holidays': '2026-06-25',
    'gratuity_eos': '2026-06-25',
    'death_benefits_art55': '2026-09-20',
    'work_related_death_compensation': '2026-09-20',
    'termination_notice': '2026-06-25',
    'law_9_2026': '2026-06-25',
    'job_mobility': '2026-06-25',
    'exit_permit': '2026-06-25',
    'work_injury': '2026-06-25',
    'accommodation': '2026-06-25',
    'complaints': '2026-06-25',
    'wsif': '2026-09-19',
    'law_12_2024_qatarization': '2026-08-01',
    'filing_deadline_art10': '2026-08-24',
    'domestic_workers': '2026-06-25',
    'contracts': '2026-06-25',
    'residency_sponsorship': '2026-06-25',
  };

  /// Maps Firestore `legal_sources` document ids → [labourSections] keys for admin cross-check.
  static const Map<String, List<String>> legalSourceIdToKbSections = {
    'law_14_2004': [
      'overview',
      'wages_wps',
      'hours_overtime',
      'leave_holidays',
      'gratuity_eos',
      'termination_notice',
      'contracts',
      'work_injury',
      'accommodation',
      'domestic_workers',
      'filing_deadline_art10',
    ],
    'law_21_2015': ['residency_sponsorship', 'exit_permit'],
    'law_17_2020': ['law_17_2020_minimum_wage'],
    'ministerial_decision_17_2021_heat': ['heat_protection'],
    'law_12_2024_qatarization': ['law_12_2024_qatarization'],
    'law_18_2020': ['job_mobility'],
    'law_9_2026': ['law_9_2026', 'termination_notice'],
    'law_14_2004_art_61': ['termination_notice'],
    'law_14_2004_art_62': ['termination_notice'],
    'law_14_2004_art_64': ['termination_notice'],
    'law_14_2004_art_55': ['death_benefits_art55', 'gratuity_eos'],
    'law_14_2004_art_110': ['work_related_death_compensation'],
    'law_14_2004_art_114': ['work_related_death_compensation'],
    'mol_guidance': ['complaints', 'wages_wps'],
    'cabinet_resolution_6_2018_ldrc': ['complaints', 'wsif'],
    'law_17_2018_wsif': ['wsif'],
  };

  /// Latest KB prose touch date for a Firestore legal_sources document id.
  static DateTime? latestKbTouchForLegalSource(String sourceId) {
    final sections = legalSourceIdToKbSections[sourceId];
    if (sections == null || sections.isEmpty) return null;
    DateTime? latest;
    for (final key in sections) {
      final raw = kbSectionLastTouched[key];
      if (raw == null) continue;
      final parsed = DateTime.tryParse(raw);
      if (parsed == null) continue;
      if (latest == null || parsed.isAfter(latest)) latest = parsed;
    }
    return latest;
  }

  /// True when Firestore verification is newer than KB prose — dual-record drift.
  static bool firestoreVerifiedNewerThanKb(
    String sourceId,
    DateTime? dateLastVerified,
  ) {
    if (dateLastVerified == null) return false;
    final kbTouch = latestKbTouchForLegalSource(sourceId);
    if (kbTouch == null) return false;
    return dateLastVerified.isAfter(kbTouch);
  }

  static const Map<String, List<String>> labourTopicKeywords = {
    'wages_wps': [
      'salary', 'wage', 'pay', 'paid', 'wps', 'deduction',
      'راتب', 'تنخواہ', 'तनख्वाह', 'ശമ്പളം', 'சம்பளம்', 'तलब',
    ],
    'law_17_2020_minimum_wage': [
      'minimum wage', 'min wage', '1000', 'qar 1000', 'basic wage',
      'food allowance', 'accommodation allowance', 'law 17', 'law no 17',
      'أجر', 'حد أدنى', 'न्यूनतम वेतन', 'کم از کم تنخواہ',
    ],
    'hours_overtime': [
      'overtime', 'working hours', 'rest day', 'friday work', 'shift',
      'ramadan hours',
    ],
    'heat_protection': [
      'heat', 'outdoor', 'summer ban', 'outdoor work', 'sun', 'construction ban',
      'heat stress', 'wbgt', '10 am', '3:30', 'june 1', 'september 15',
    ],
    'law_12_2024_qatarization': [
      'qatarization', 'qatarisation', 'nationalization', 'qatari hire',
      'qatari national', 'children of qatari women', 'law 12', 'law no 12',
      'job nationalization', 'تقنين',
    ],
    'leave_holidays': [
      'annual leave', 'sick leave', 'holiday', 'vacation', 'public holiday',
      'إجازة', 'छुट्टी', 'വിദ്യ', 'அவധி', 'बिदा',
    ],
    'gratuity_eos': [
      'gratuity', 'end of service', 'eos', 'indemnity', 'مكافأة',
    ],
    'death_benefits_art55': [
      'worker died', 'passed away', 'deceased worker',
      'heir', 'inheritance', 'court deposit', 'repatriation remains',
      'article 55', 'art. 55', 'وفاة', 'ورثة',
    ],
    'work_related_death_compensation': [
      'work-related death', 'died at work', 'death at work', 'workplace accident',
      'occupational injury', 'death caused by work', 'died by reason of work',
      'article 110', 'art. 110', 'article 114', 'art. 114',
      'وفاة بسبب العمل', 'تعويض الوفاة',
    ],
    'filing_deadline_art10': [
      'sue', 'lawsuit', 'filing deadline', 'limitation period', 'one year',
      'how long to sue', 'how long do i have', 'time limit', 'art. 10', 'article 10',
      'تقادم', 'رفع دعوى', 'مهلة',
    ],
    'termination_notice': [
      'terminate', 'terminated', 'fired', 'dismiss', 'resign', 'resignation',
      'notice period', 'arbitrary dismissal', 'wrongful',
    ],
    'job_mobility': [
      'job change', 'change job', 'transfer employer', 'noc', 'kafala',
      'employer change', 'metrash job', 'نوكري', 'تبديل',
    ],
    'exit_permit': [
      'exit permit', 'leave qatar', 'travel ban', 'exit visa', 'cannot leave',
    ],
    'work_injury': [
      'injury', 'accident', 'work injury', 'compensation', 'disability',
    ],
    'accommodation': [
      'accommodation', 'labour camp', 'worker housing', 'sleeping',
    ],
    'complaints': [
      'complaint', 'adlsa', 'mol', 'grievance', 'dispute', 'hotline',
      'شكوى', 'शिकायत', 'പരാതി', 'புகார்', 'उजुरी',
    ],
    'wsif': [
      'wsif', 'workers support', 'insurance fund', 'employer will not pay',
      'won my case', 'committee ruling', 'non-payment', 'law 17 of 2018',
      'صندوق', 'لم يدفع', 'فوز', 'قرار اللجنة',
    ],
    'domestic_workers': [
      'domestic worker', 'housemaid', 'maid', 'nanny', 'driver domestic',
      'home worker', 'خادمة',
    ],
    'contracts': [
      'employment contract', 'labour contract', 'contract arabic', 'contract english',
      'job contract',
    ],
    'residency_sponsorship': [
      'sponsorship', 'sponsor', 'residence permit', 'law 21', 'expatriate entry',
      'visa transfer', 'iqama',
    ],
    'law_9_2026': [
      'law 9', '2026 amendment', 'strike', 'incitement', 'noncompete', 'non-compete',
      'part-time', 'part time', 'freelance', 'joint committee', '100 workers',
      'article 23', '23 bis', 'vocational', 'training certificate', '2000', '5000',
    ],
  };

  static const Map<String, String> labourSections = {
    'overview': '''
LABOUR LAW OVERVIEW (Qatar):
- Core law: Law No. 14 of 2004 (Labour Law) + amendments including Law No. 17 of 2020 (minimum wage), Law No. 18 of 2020 (job mobility), and **Law No. 9 of 2026** (promulgated 25 June 2026).
- Residency/sponsorship is separate: Law No. 21 of 2015 (entry, exit, residence of expatriates).
- Official legal text: Al Meezan (almeezan.qa). Current procedures: mol.gov.qa.
- **ADLSA** (Ministry of Administrative Development, Labour and Social Affairs) is the current official name for Qatar's Ministry of Labour — use "Ministry of Labour (MoL/ADLSA)" as one entity, not two separate ministries.
- MoL/ADLSA labour helpline: **16008** (24/7) | Unified Complaints Portal via mol.gov.qa (NAS login available).
- Do NOT cite specific article numbers unless grounded below; recommend verification for binding matters.
- **Law 9/2026 article-level details in this KB require Al Meezan verification before binding use.**
''',
    'wages_wps': '''
WAGES & WAGE PROTECTION SYSTEM (WPS):
- Wages must be paid via the Wage Protection System (WPS) within required timelines; delayed or off-system wages can be reported to MoL/ADLSA.
- Deductions generally require worker consent and legal limits — do not accept off-WPS cash without understanding risk.
- Minimum wage floor is set separately by **Law No. 17 of 2020** (see dedicated section — not the same law as WPS).
- Action: file wage complaint via MoL Unified Complaints Portal (mol.gov.qa) or helpline **16008**.
''',
    'law_17_2020_minimum_wage': '''
LAW NO. 17 OF 2020 — MINIMUM WAGE (workers & domestic workers):
**NOT Law No. 18 of 2020** — Law 18/2020 covers job mobility/NOC reform; Law 17/2020 sets minimum wage only.
- Effective from **20 March 2021** (per ADLSA/MoL implementation announcements).
- Applies to **all private-sector workers including domestic workers**, regardless of nationality or sector.
- Non-discriminatory minimum components (reference figures — cite as facts, do not calculate entitlements for the user):
  • Basic wage: **QAR 1,000/month** minimum.
  • If employer does **not** provide adequate **accommodation**: **QAR 500/month** accommodation allowance.
  • If employer does **not** provide adequate **food**: **QAR 300/month** food allowance.
- If employer provides both adequate accommodation and food: worker receives at least QAR 1,000 basic wage.
- If employer provides accommodation only: at least QAR 1,300/month (1,000 + 300 food allowance).
- If employer provides neither: at least QAR 1,800/month (1,000 + 500 + 300).
- Employer cannot use the minimum wage law to **reduce** pay below existing contract terms (Ministerial Decision No. 17 of 2020 on minimum wage determination — verify Art. 4 on Al Meezan).
- Enforced by MoL/ADLSA; wage below minimum is reportable via Unified Complaints Portal or **16008**.
- **OPEN QUESTION (product owner):** Should Raabta EOSB PendingSalary or Overtime Truth Engine use QAR 1,000 basic wage as a floor/sanity-check? Not implemented in calculators — decision pending.
''',
    'hours_overtime': '''
WORKING HOURS & OVERTIME (Law 14/2004 — general principles):
- Standard reference: up to 8 hours/day, 48 hours/week (Ramadan reduced hours for Muslim workers).
- Overtime compensation rates apply for extra hours — verify current rates on Al Meezan/MoL.
- Keep personal records of hours worked.
''',
    'heat_protection': '''
OUTDOOR HEAT STRESS PROTECTION — Ministerial Decision No. 17 of 2021:
(Repeals Ministerial Decision No. 16 of 2007; verify current text on mol.gov.qa / Al Meezan.)
- **Seasonal outdoor work ban (Art. 2):** Prohibited to work in the sun, in outdoor workplaces, or in places that are **not shaded and ventilated**, annually from **1 June to 15 September**, between **10:00 a.m. and 3:30 p.m.**
- **Year-round WBGT threshold:** All outdoor work must stop immediately if Wet-Bulb Globe Temperature (WBGT) exceeds **32.1°C** at the workplace — applies regardless of date or time.
- Employer duties include: published daily work schedule, heat-stress risk assessment, worker training, shaded rest/water, annual medical checks for at-risk workers (per MoL heat-stress guidance).
- Workers may refuse unsafe outdoor work during banned periods or when WBGT exceeds threshold — report violations to MoL/ADLSA.
- **Currently active** as of 2026 — verify any annual MoL announcements before citing exact dates in edge cases.
''',
    'leave_holidays': '''
LEAVE & PUBLIC HOLIDAYS:
- Annual leave entitlement increases with service length (general reference: 3 weeks under 5 years, 4 weeks at 5+ years — verify on Al Meezan).
- Sick leave tiers exist (paid/partial/unpaid) with medical certificate requirements.
- Unused leave generally payable on termination — confirm in contract and official sources.
''',
    'gratuity_eos': '''
END OF SERVICE GRATUITY (Law 14/2004 Art. 54 area — general formula):
- Gratuity commonly calculated on basic salary × years of service (often referenced as ~3 weeks per year — verify formula for employee category on Al Meezan).
- Based on BASIC salary, not total allowances, unless contract states otherwise within legal limits.
- Raabta EOSB Truth Engine (/eosb) can help estimate — official disputes via MoL.
- **Death during employment (Art. 55):** gratuity is calculated the same as any other end of service — service is not reduced because of death. See Raabta standalone page `/eosb/death-benefits` for family-member guidance (court deposit, heirs, repatriation) — do NOT mix into calculator output unless user explicitly asks about a deceased worker.
''',
    'death_benefits_art55': '''
DEATH DURING EMPLOYMENT — ART. 55 (Law 14/2004):
- If a worker dies during employment **for any cause**, employer must deposit **wages, earned gratuity, and other entitlements** with the **court within 15 days** of the date of death.
- Deposit must include a **detailed report** showing how amounts were calculated.
- **Gratuity:** same formula as normal end of service (Art. 54 area) — **not reduced or penalized** because of death; full gratuity if one year+ continuous service met.
- **Court distribution to heirs:** applies **Islamic Sharia** OR the **personal law applicable in the country of the deceased** — non-Muslim expatriate families may be governed by home-country inheritance law, **not automatic Sharia**. State this plainly; advise families to ask which law applies.
- **Unclaimed funds:** if heirs not identified within **3 years** of deposit, funds transfer to the **State public fund**.
- **Repatriation (separate from deposit):** employer responsible for preparing remains and repatriation to home country/agreed residence at heirs' request; if employer fails, relevant government department arranges and **recovers cost from employer** administratively.
- **Family guidance:** MADLSA hotline **16008**; embassy/consulate or home-country labour attaché in Qatar may help. Raabta page `/eosb/death-benefits` — informational only; no heir verification or deposit tracking tools.
- **If employer fails court deposit:** direct family to MADLSA; may cross-reference WSIF/dispute routes only where unpaid entitlements overlap — WSIF primary context is post-LDRC non-payment, not a substitute for Art. 55 court deposit process.
- **Work-related death:** Art. 55 is **not the only** potentially relevant provision if death was caused by work — see separate **`work_related_death_compensation`** section (Art. 110/114). Do **not** answer work-caused death using Art. 55 alone.
- Tone: calm, factual — audience may be grieving family abroad. No promotional framing.
''',
    'work_related_death_compensation': '''
WORK-RELATED DEATH COMPENSATION — ART. 110 & 114 (Law 14/2004) — SEPARATE FROM ART. 55:
- **Art. 55 (separate section):** death during employment **regardless of cause** — wages, other employment entitlements, and end-of-service gratuity court deposit and heir distribution.
- **Art. 110:** compensation rights for **heirs** where the worker dies **by reason of the work** — separate from Art. 55 entitlements.
- **Art. 114:** employer **15-day court deposit** requirement for **death compensation** following death or investigation result supporting work-related death — separate from Art. 55 deposit.
- Process and amount depend on **circumstances and investigation findings** — **not every death during employment** qualifies for work-injury/death compensation.
- **Do NOT attribute Art. 110 compensation to Art. 55.** Do **NOT calculate or state a compensation amount** unless a separately audited verified implementation exists.
- **Guardrail:** If the user says the death was caused by work, workplace accident, occupational injury, or similar — **do not answer using Art. 55 alone**. Surface Art. 110/114 framework and advise verification of circumstances and investigation outcome. Raabta `/eosb/death-benefits` includes a calm boundary note for family members.
''',
    'filing_deadline_art10': '''
ART. 10 FILING DEADLINE — LAWSUIT FOR ENTITLEMENTS (Law No. 14 of 2004):
- Verified rule: the right to file a lawsuit for employment entitlements **lapses one year from the date of expiry of the contract** (when employment ends).
- Trigger date is **contract expiry / last working day** — not the date a violation occurred.
- **Do NOT calculate a user-specific deadline in chat.** Direct the user to their **EOSB result or dashboard Legal Deadline card** for their personal calculated date (Raabta LegalDeadlineService).
- General ADLSA channels: helpline **16008**, mol.gov.qa Unified Complaints Portal.
- **Known limitation:** active MoL conciliation may suspend the limitation period in practice — Raabta's EOSB deadline card does not yet model conciliation pauses; advise verification with ADLSA for conciliation cases.
''',
    'termination_notice': '''
TERMINATION & NOTICE:
- Notice periods depend on length of service and who initiates termination.
- **Article 54 (Law 14/2004):** end-of-service gratuity is owed after one year of service in most cases — calculated separately from any dismissal dispute.
- **Article 61 (Law 14/2004):** employer may dismiss **without notice and without end-of-service gratuity** only on statutory grounds — false identity/documents; gross financial loss with Labour Department notified within 24 hours; repeated written safety violations; repeated essential-duty failures after written warning; secrets disclosure; intoxication at work; assault on employer/manager/supervisor; repeated colleague assault after warning; unauthorised absence thresholds; final criminal sentence for immorality/dishonesty. Employer must prove the ground.
- **Article 62 (Law 14/2004):** **disciplinary penalty procedure** when imposing penalties — e.g. accusation within 15 days; work-related violation; written inquiry (oral for minor breaches); one penalty per violation; authorized imposer; penalty must be in regulations. **Not** the arbitrary-dismissal compensation article.
- **Article 64 (Law 14/2004):** **dismissal penalty grievance** — internal appeal steps (7-day employer appeal; 7-day Department appeal) except dismissal penalty may be appealed directly to competent court/LDRC. If dismissal is **arbitrary or violates the law**, court may order reinstatement with back wages OR **appropriate compensation** (wages/benefits for relevant period) — **no fixed cap or formula; at court discretion**. Raabta must NEVER estimate Art. 64 compensation for a specific case.
- Art. 54 gratuity and Art. 64 dismissal-dispute remedies are **separate** — gratuity may still be owed while a dismissal is disputed.
- **Law No. 9 of 2026 (verify on Al Meezan):** new narrow ground for summary dismissal **without end-of-service gratuity** where worker unlawfully incited others to strike disrupting business operations — separate from Art. 61/62/64; do not conflate.
- Keep copies of all termination letters, written warnings, and final settlement statements.
- Information routes: ADLSA helpline **16008**, Labour Dispute Resolution Committees (Cabinet Resolution 6/2018).
''',
    'law_9_2026': '''
LAW NO. 9 OF 2026 — AMENDMENTS TO LABOUR LAW (promulgated 25 June 2026):
**REQUIRES LEGAL REVIEW:** Exact articles and wording must be verified on Al Meezan before binding advice.

Confirmed themes from legal-analysis summaries (not primary legislative text):
- **Scope:** Part-time and freelance workers excluded from default Labour Law coverage; Council of Ministers may extend by decision.
- **Joint committees:** Mandatory employer–worker committees for establishments with **100+ workers** (threshold reportedly raised from 30+). Non-compliance may attract administrative fines reportedly in the **QAR 2,000–5,000** range per violation — verify on Al Meezan.
- **Article 23 bis (vocational professions):** New training/examination certificate requirement before starting work in designated vocational professions — verify designated categories on Al Meezan.
- **Summary dismissal / gratuity & notice:** Employer may terminate without notice and **without EOS gratuity** for unlawful incitement to strike disrupting operations — narrow, fact-specific; ground only exists from 25 June 2026 onward.
- **Noncompete:** Durations reportedly expanded — verify for contract reviews.
- **Strike rights & enforcement:** Broader amendments to strike rules and MoL enforcement — verify primary text.
- Raabta EOSB Truth Engine (/eosb) applies the strike-incitement gratuity exception only when user explicitly confirms that ground; part-time/freelance users see reference figures only unless coverage is confirmed.
- Always recommend independent legal advice for dismissal disputes involving these grounds.
''',
    'job_mobility': '''
JOB MOBILITY & NOC REFORM (Law No. 18 of 2020 — **not** Law 17/2020):
- Law **18**/2020 amended job-change rules; Law **17**/2020 is the separate minimum-wage law — do not conflate them.
- Most private-sector workers covered by Labour Law can change employers after minimum service period WITHOUT employer NOC (verify eligibility and process on mol.gov.qa / Metrash Employer Change service).
- Employer retaliation for lawful job change is prohibited.
- Process and exceptions differ for domestic workers, some public sector, QFC, and military — see separate sections.
''',
    'exit_permit': '''
EXIT PERMITS — IMPORTANT DISTINCTION:
- September 2018 Labour Law / expatriate-entry-exit reforms removed the exit-permit requirement for relevant private-sector workers covered by the Labour Law — do NOT attribute this abolition solely to Decision No. 95 of 2019.
- Decision No. 95 of 2019 governs exit arrangements for expatriates NOT governed by the Labour Law and provides category-specific procedures.
- Under Decision 95/2019, employers may designate up to 5% of workers as critical, requiring prior MOI approval before leaving because of the nature of their work.
- Domestic workers under Law No. 15 of 2017: typically no exit permit but must inform employer at least 72 hours before departure (Decision 95/2019).
- Military personnel remain an exception.
- Always confirm category and current status on MOI/Metrash before advising someone they can leave freely — do not use a blanket "no exit permit required" statement.
''',
    'work_injury': '''
WORK INJURY & COMPENSATION:
- Employer must insure workers; report injuries promptly in writing.
- Compensation scales depend on injury severity — verify on Al Meezan.
- Seek approved medical treatment and keep documentation.
''',
    'accommodation': '''
ACCOMMODATION STANDARDS (Ministerial Decision 18/2014 area):
- If employer provides housing, minimum space, ventilation, sanitation, and water standards apply.
- Document substandard conditions; complaints via MoL.
''',
    'complaints': '''
COMPLAINT & DISPUTE CHANNELS (MoL/ADLSA — Ministry of Labour):
1. Raise issue with employer in writing (keep proof).
2. **Unified Complaints and Whistleblowers Platform** — mol.gov.qa (log in with QID/visa + mobile OTP, or **National Authentication System (NAS)** credentials).
3. **24/7 labour helpline: 16008** (multilingual).
4. **SMS complaint:** send **5** followed by your **QID or visa number** to **92727**.
5. Amerni mobile app (MoL/ADLSA) — alternative channel for some services.
6. Mediation through MoL/ADLSA; referral to Labour Dispute Resolution Committees (LDRC, Cabinet Resolution 6/2018) if unresolved — judge-led panels; appeal to Court of Appeal.
7. LDRC issues a binding decision (often reported within ~3 weeks in public guidance — not a guaranteed timeline).
8. **If the Committee rules in the worker's favor but the employer cannot or will not pay:** Workers' Support and Insurance Fund (Law No. 17 of 2018, wsif.gov.qa) may pay awarded entitlements and pursue recovery from the employer — typically requires valid QID and completed Committee ruling; payouts may be capped or interim, not necessarily the full sum awarded. Contact ADLSA **16008** or wsif.gov.qa for current process — Raabta does not file fund applications.
9. Qatar Legal Aid for eligible cases.
Free general guidance — not a substitute for licensed legal representation in active disputes.
''',
    'wsif': '''
WORKERS' SUPPORT AND INSURANCE FUND (Law No. 17 of 2018 — wsif.gov.qa):
- **When it applies:** If the Labour Dispute Resolution Committee (LDRC) rules in the worker's favor but the employer cannot or will not pay the awarded entitlements.
- **Known:** Government-run fund that may pay entitlements already decided by the Committee and separately pursue recovery from the employer.
- **Typical requirements (verify on wsif.gov.qa):** valid QID and a completed Committee ruling.
- **Honest limits:** Payment amounts may be **capped** or issued as an **interim amount** — not a guarantee of the full sum awarded.
- **Action:** Contact ADLSA helpline **16008** or visit **wsif.gov.qa** for current eligibility and process — Raabta does **not** file fund applications.
- **Do not conflate** with Law No. 17 of **2020** (minimum wage) — separate law.
''',
    'law_12_2024_qatarization': '''
LAW NO. 12 OF 2024 — QATARIZATION OF JOBS IN THE PRIVATE SECTOR:
**General labour-market context** — not an individual entitlement calculator like EOSB/overtime.
**REQUIRES LEGAL REVIEW:** Exact quotas, job lists, and phased timelines depend on future Council of Ministers / MoL implementing decisions — verify on Al Meezan and mol.gov.qa before binding employer advice.

Confirmed themes (orientation only):
- Private-sector employers must prioritize hiring, training, and onboarding **Qatari nationals**; if no Qatari candidate, priority to **children of Qatari women**.
- Applies to commercial companies and private institutions registered in Qatar; **excludes** entities under Qatar Energy / petroleum operations (verify scope on primary text).
- Employers must notify MoL of vacancies (conditions, salary, timeline) and submit biannual workforce reports.
- MoL to develop classification plans (by establishment size, job types); standard employment contract templates for nationalization hires.
- Incentives for compliant employers; penalties for non-compliance (fines reported up to QAR 100,000 — verify current penalty schedule on Al Meezan).
- Relevant for Jobs feature, hiring Q&A, and salary-negotiation context — not for violation detection against individual workers.
''',
    'domestic_workers': '''
DOMESTIC WORKERS (separate regime — Law No. 1 of 2017):
- Domestic workers (maids, nannies, family drivers in home employment) are NOT fully covered by the general Labour Law in the same way.
- Exit permit, leave, and transfer rules differ — verify on mol.gov.qa domestic worker section.
- Never apply private-sector job mobility or exit-permit abolition rules to domestic workers without checking category.
''',
    'contracts': '''
EMPLOYMENT CONTRACTS:
- Arabic contract is the legally official version; English translations are common but Arabic prevails in disputes.
- Contract must reflect actual terms (salary, role, leave, ticket policy).
- Do not sign blank or incomplete contracts; keep copies of everything signed.
- **Law No. 9 of 2026:** Noncompete clause durations reportedly expanded — verify current limits on Al Meezan before relying on contract review tools.
''',
    'residency_sponsorship': '''
RESIDENCY & SPONSORSHIP (Law No. 21 of 2015 — orientation):
- Governs entry, exit, and residence of expatriates — separate from Labour Law employment rights.
- Sponsorship ties affect visa status, family visas, and exit requirements for some categories.
- Verify procedures on moi.gov.qa / Metrash — immigration rules change administratively.
''',
  };

  static List<String> detectLabourTopics(String message) {
    final lower = message.toLowerCase();
    final matched = <String>[];
    for (final entry in labourTopicKeywords.entries) {
      if (entry.value.any((k) => lower.contains(k.toLowerCase()))) {
        matched.add(entry.key);
      }
    }
    return matched;
  }

  /// Inject only relevant labour sections (max 3 specific + overview/complaints fallback).
  static String buildLabourInjection(List<String> topics, String message) {
    final buffer = StringBuffer('''
LABOUR / WORK RIGHTS MODE (last verified: $lastVerified):
Sources: Al Meezan (almeezan.qa), mol.gov.qa, GCO labour reform summaries.
''');

    final toInject = <String>{};
    if (topics.isEmpty) {
      toInject.add('overview');
      toInject.add('complaints');
    } else {
      toInject.add('overview');
      for (final t in topics.take(3)) {
        toInject.add(t);
      }
      if (topics.any((t) => t == 'exit_permit' || t == 'job_mobility')) {
        toInject.add('domestic_workers');
      }
    }

    for (final key in toInject) {
      final section = labourSections[key];
      if (section != null) buffer.writeln(section);
    }

    return buffer.toString();
  }

  // ── LABOUR TOPIC CHIPS (AI Chat UI) ──

  static const List<Map<String, String>> quickTopics = [
    {
      'label': 'Salary Not Paid',
      'icon': '💰',
      'question':
          'My employer has not paid my salary. What are my legal rights and how do I complain in Qatar?',
    },
    {
      'label': 'Overtime Pay',
      'icon': '⏰',
      'question':
          'Am I entitled to overtime pay in Qatar and what is the correct rate?',
    },
    {
      'label': 'Annual Leave',
      'icon': '🏖️',
      'question':
          'How many annual leave days am I entitled to in Qatar and what happens to unused leave?',
    },
    {
      'label': 'Gratuity Calc',
      'icon': '🧮',
      'question':
          'How is end of service gratuity calculated in Qatar? I want to know my entitlement.',
    },
    {
      'label': 'Change Job',
      'icon': '🔄',
      'question':
          'Can I change my job in Qatar without my employer permission? What is the process?',
    },
    {
      'label': 'Exit Permit',
      'icon': '✈️',
      'question':
          'Do I still need an exit permit to leave Qatar? Does it depend on my job type?',
    },
    {
      'label': 'Work Injury',
      'icon': '🏥',
      'question':
          'I was injured at work in Qatar. What compensation am I entitled to and what should I do?',
    },
    {
      'label': 'Heat Ban',
      'icon': '☀️',
      'question':
          'What are the outdoor work ban rules in Qatar during summer and what if my employer violates it?',
    },
    {
      'label': 'File Complaint',
      'icon': '📋',
      'question':
          'How do I file a complaint against my employer in Qatar? What is the step by step process?',
    },
    {
      'label': 'Domestic Worker',
      'icon': '🏠',
      'question':
          'What are the labour rules for domestic workers in Qatar? Are they different from other jobs?',
    },
  ];

  // ── BROAD LABOUR INTENT KEYWORDS (8 languages) ──

  static const List<String> labourKeywords = [
    'salary', 'wage', 'pay', 'paid', 'overtime', 'leave', 'holiday', 'vacation',
    'sick', 'gratuity', 'end of service', 'eos', 'terminate', 'fired', 'resign',
    'notice', 'complaint', 'adlsa', 'labour', 'labor', 'job change', 'transfer',
    'kafala', 'exit permit', 'injury', 'accident', 'compensation', 'accommodation',
    'heat', 'outdoor', 'wps', 'working hours', 'contract', 'rights', 'employer',
    'noc', 'domestic worker', 'housemaid', 'sponsor', 'mol', '16008', '92727',
    'minimum wage', 'qatarization', 'qatarisation', 'law 17', 'law 18', 'law 12',
    'راتب', 'إجازة', 'مكافأة', 'شكوى', 'عمل',
    'तनख्वाह', 'छुट्टी', 'शिकायत', 'نوکری', 'تنخواہ',
    'சம்பளம்', 'விடுப்பு', 'புகார்',
    'ശമ്പളം', 'അവധി', 'പരാതി',
    'तलब', 'बिदा', 'उजुरी',
  ];

  static bool isLabourQuery(String message) {
    final lower = message.toLowerCase();
    return labourKeywords.any(
      (keyword) => lower.contains(keyword.toLowerCase()),
    );
  }

  static String languageNameForCode(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'hi':
        return 'हिंदी';
      case 'ur':
        return 'اردو';
      case 'ta':
        return 'தமிழ்';
      case 'ml':
        return 'മലയാളം';
      case 'sw':
        return 'Kiswahili';
      case 'ne':
        return 'नेपाली';
      default:
        return 'English';
    }
  }

  /// Legacy helper — prefer [RaabtaAIBrain.buildChatContext] for full chat.
  static String buildSystemPrompt({
    required String userLanguageCode,
    required bool isLabourQuery,
    String message = '',
  }) {
    final languageName = languageNameForCode(userLanguageCode);
    final buffer = StringBuffer('''
You are Raabta AI, a helpful assistant for expats living in Qatar.
LANGUAGE: $languageName ($userLanguageCode). Match the user's language.
''');
    if (isLabourQuery) {
      final topics = detectLabourTopics(message);
      buffer.writeln(buildLabourInjection(
        topics.isNotEmpty ? topics : ['complaints'],
        message,
      ));
    }
    return buffer.toString();
  }
}
