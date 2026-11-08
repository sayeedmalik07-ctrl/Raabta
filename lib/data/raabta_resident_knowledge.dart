/// General Qatar resident knowledge — lighter than labour law; official-source framing.
/// Injected only when resident/practical topics are detected.
class RaabtaResidentKnowledge {
  RaabtaResidentKnowledge._();

  static const lastVerified = '2026-08-01';

  static const Map<String, List<String>> topicKeywords = {
    'qid': [
      'qid',
      'qatar id',
      'iqama',
      'metrash',
      'renew qid',
      'id renewal',
      'هوية',
      'قطر',
    ],
    'family_sponsorship': [
      'family visa',
      'family residency',
      'sponsor family',
      'wife visa',
      'child visa',
      'dependant',
      'dependent',
      'family member',
    ],
    'traffic': [
      'traffic fine',
      'driving license',
      'driver license',
      'moi',
      'ministry of interior',
      'speed camera',
      'traffic violation',
      'vehicle registration',
      'فيفا',
      'رخصة',
    ],
    'healthcare': [
      'health card',
      'hamad',
      'hmc',
      'hospital',
      'healthcare',
      'medical card',
      'clinic',
      'health insurance',
      'seha',
    ],
    'housing_tenancy': [
      'rent',
      'landlord',
      'lease',
      'tenancy',
      'eviction',
      'deposit',
      'municipality registration',
      'housing contract',
    ],
    'sponsorship_transfer': [
      'change employer',
      'employer change',
      'sponsor transfer',
      'sponsorship transfer',
      'job transfer',
      'transfer iqama',
      'noc',
      'no objection',
    ],
    'outdoor_work_heat': [
      'work outside',
      'outdoor work',
      'construction outside',
      'summer work',
      'too hot to work',
      'heat ban',
      'can i work outside',
      'working in sun',
      'outdoor ban',
    ],
  };

  static const Map<String, String> sections = {
    'qid': '''
QID & METRASH (general orientation):
- Qatar ID (QID/residence permit) is managed via MOI; Metrash is the main self-service app for renewals, visa services, traffic, and many resident transactions.
- Renewal typically requires valid passport, medical fitness (where applicable), and sponsor/employer clearance depending on visa type.
- For exact steps, fees, and current requirements: use Metrash or moi.gov.qa — processes change more often than law text.
''',
    'family_sponsorship': '''
FAMILY RESIDENCY (general orientation):
- Family sponsorship rules depend on sponsor category (employee, business owner, etc.) and salary/housing criteria set by MOI.
- Typical flow involves eligibility check → application via Metrash/MOI → medical & biometrics for dependents.
- Verify current criteria on moi.gov.qa before planning — do not assume eligibility from old rules.
- DEPENDENT EMPLOYMENT: Family-residency holders may have a Ministry of Labour work-permit route that allows entering the labour market without changing residency type. The Ministry of Labour also lists work-permit routes for permanent residents, GCC citizens, and investor residents. Eligibility, fees, and current requirements must be confirmed through the official Ministry of Labour service — do not assume zero fee, single employer, or unrestricted switching without official verification.
''',
    'traffic': '''
TRAFFIC & DRIVING (general awareness):
- Traffic fines, license renewal, and vehicle registration are handled via MOI channels including Metrash.
- For fine amounts, points, or dispute procedures: check moi.gov.qa or Metrash directly.
- Emergencies on road: 999.
''',
    'healthcare': '''
HEALTHCARE ACCESS (general awareness):
- Hamad Medical Corporation (HMC) operates major public hospitals; expats often use private clinics or employer-provided insurance.
- Health card / registration processes vary by nationality and insurance status.
- For facility locations, appointments, and eligibility: use official HMC/PHCC portals — do not guess wait times or costs.
''',
    'housing_tenancy': '''
HOUSING & TENANCY (general orientation):
- Written lease agreements are standard; register tenancy with relevant municipality where required.
- Disputes may involve municipality rental committees or civil channels depending on issue type.
- For binding tenancy rights or eviction procedures, verify with official municipality/MOJ guidance or a licensed advisor.
- Raabta Housing Rights Truth Engine (/tenancy) covers verified Law 4/2008 compliance checks, dispute document checklist, and packet PDF — not rent-increase caps or in-app filing.
''',
    'sponsorship_transfer': '''
SPONSORSHIP / EMPLOYER CHANGE (general orientation):
- Since September 2020, NOC is generally not required for eligible employer changes under Law 19/2020 (sponsorship law) — distinct from labour notice rules under Law 18/2020.
- Transfer timing must respect residence permit validity and the 90-day post-expiry window (MOI Decree 51/2020).
- Raabta Sponsorship Transfer Truth Engine (/sponsorship-transfer) covers readiness checks, document checklist, and verified Q&A — not processing-time prediction or in-app MADLSA filing.
- For Metrash procedural steps, see Visa & Documents → Sponsor Transfer guide.
''',
    'outdoor_work_heat': '''
OUTDOOR WORK IN SUMMER (practical orientation — MoL/ADLSA):
- Qatar bans most outdoor work in direct sun / unshaded unventilated areas **1 June – 15 September**, **10:00 a.m. – 3:30 p.m.** (Ministerial Decision No. 17 of 2021).
- Work must also stop if heat-stress measurement (WBGT) exceeds **32.1°C** — any time of year.
- If your employer asks you to work outside during banned hours, you can refuse and report via MoL helpline **16008** or mol.gov.qa complaints portal.
- For full legal detail and employer duties, ask about "labour law heat protection" or verify on mol.gov.qa.
''',
  };

  static List<String> detectTopics(String message) {
    final lower = message.toLowerCase();
    final matched = <String>[];
    for (final entry in topicKeywords.entries) {
      if (entry.value.any((k) => lower.contains(k.toLowerCase()))) {
        matched.add(entry.key);
      }
    }
    return matched;
  }

  static String buildInjection(List<String> topics) {
    if (topics.isEmpty) return '';
    final buffer = StringBuffer('''
GENERAL QATAR RESIDENT KNOWLEDGE (orientation only — verify specifics on official portals):
Last verified: $lastVerified
''');
    for (final topic in topics) {
      final section = sections[topic];
      if (section != null) buffer.writeln(section);
    }
    buffer.writeln('''
For anything binding or fee-specific: direct user to moi.gov.qa, Metrash, mol.gov.qa, or the relevant official portal.
''');
    return buffer.toString();
  }
}
