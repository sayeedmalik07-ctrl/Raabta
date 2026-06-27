/// Qatar Labour Law 2024 knowledge base for Raabta AI.
/// Injected into the system prompt when labour-related intent is detected.
class QatarLabourLawKB {
  QatarLabourLawKB._();

  // ── SYSTEM PROMPT INJECTION ──
  // Appended to the AI system prompt when labour law intent is detected.

  static const String labourLawContext = '''
QATAR LABOUR LAW KNOWLEDGE BASE (2024 — Updated)
Source: Law No. 14 of 2004 + Amendments through 2024
Ministry: ADLSA (Ministry of Labour) | Hotline: 16008

════════════════════════════════════
1. WAGES & SALARY PROTECTION
════════════════════════════════════
Law: No. 17 of 2020 (Wage Protection System — WPS)
- Minimum wage: QAR 1,000 basic + QAR 500 food allowance
  + QAR 300 accommodation allowance = QAR 1,800 total minimum
  (if employer provides food/accommodation, cash allowances
   can be reduced proportionally)
- Salary must be paid within 7 days of due date via WPS
- Salary deductions: maximum 10% without written worker consent
- Employers who delay salary face: fines, hiring ban,
  licence suspension, criminal prosecution
DO: File WPS complaint if salary delayed more than 7 days
DON'T: Accept cash payment not registered in WPS system
COMPLAINT: ADLSA app → Wage Complaint | or call 16008

════════════════════════════════════
2. WORKING HOURS & OVERTIME
════════════════════════════════════
Law: Labour Law No. 14/2004, Articles 73–74
- Normal hours: 8 hours/day, 48 hours/week
- Ramadan: 6 hours/day for Muslim workers
- Maximum with overtime: 10 hours/day total
- Overtime rate: 125% of hourly wage on weekdays
- Rest day / Friday overtime: 150% of hourly wage
- Public holiday work: 150% + compensatory day off
DO: Keep record of all overtime hours worked
DON'T: Work more than 10 hours total in any single day

════════════════════════════════════
3. OUTDOOR WORK BAN (HEAT PROTECTION)
════════════════════════════════════
Law: Ministerial Decision No. 16 of 2021
- Outdoor work BANNED: 10:00 AM to 3:30 PM
  Period: June 15 to September 15 every year
- Applies to: all outdoor work including construction,
  oil & gas field work, road work, landscaping
- Employer obligations: shaded rest areas, cold water,
  cooling facilities, first aid on site
- Penalty for violation: QAR 10,000 per worker fine
DO: Refuse outdoor work during banned hours — it is your LEGAL RIGHT
DON'T: Feel pressured to work in heat ban period
REPORT: Call 16008 or ADLSA app to report violations

════════════════════════════════════
4. ANNUAL LEAVE & PUBLIC HOLIDAYS
════════════════════════════════════
Law: Articles 79–83, Labour Law 14/2004
- Annual leave: 3 weeks (less than 5 years service)
               4 weeks (5 or more years service)
- Leave must be taken — employer cannot deny
- Unused leave: must be paid out upon end of service
- Public holidays: 11 days per year (paid)
  Includes: National Day, Eid Al Fitr, Eid Al Adha,
  Qatar National Sports Day, New Year's Day
- Sick leave: 2 weeks full pay
              4 weeks half pay
              6 weeks unpaid (per year)
              Requires medical certificate from approved facility
DO: Apply for leave in writing and keep copy
DON'T: Accept leave cancellation without written explanation

════════════════════════════════════
5. END OF SERVICE GRATUITY
════════════════════════════════════
Law: Article 54, Labour Law 14/2004
- Gratuity = 3 weeks basic salary × years of service
- Calculated on BASIC salary only (not allowances)
- Payable after minimum 1 year of continuous service
- Pro-rated for partial years beyond first year
- Example: QAR 1,500 basic × 5 years × 3/4 = QAR 16,875
- Gratuity is paid in ADDITION to final salary and unused leave
- Employer CANNOT deduct gratuity for ordinary resignation
  (only for proven disciplinary cases per Article 61)
DO: Calculate your gratuity before resigning or negotiating
DON'T: Sign any document waiving gratuity rights

════════════════════════════════════
6. TERMINATION & NOTICE PERIOD
════════════════════════════════════
Law: Articles 49–53, Labour Law 14/2004
- Notice period: 1 month (less than 5 years service)
                 2 months (5 or more years service)
- Employer can terminate WITHOUT notice for Article 61
  serious misconduct only (fraud, assault, drunk on duty, etc.)
- Arbitrary dismissal compensation: 3 months salary minimum
- If terminated without cause: entitled to notice pay
  + gratuity + unused leave + return air ticket
- Worker can resign with immediate effect if:
  - Employer assaults or abuses worker
  - Employer fails to meet contractual obligations
  - Work endangers health/safety without employer action

════════════════════════════════════
7. JOB MOBILITY & KAFALA REFORM
════════════════════════════════════
Law: Law No. 18 of 2020 | Ministerial Decision No. 51/2020
- Workers CAN change jobs WITHOUT employer NOC after 1 year
  (or immediately if employer violates contract)
- Exit permit: ABOLISHED — workers can leave Qatar freely
- New job: apply via Metrash2 app → Job Change Request
- Employer retaliation for job change = illegal
- Domestic workers covered under Law No. 1 of 2017
DO: Use Metrash2 app to officially request job transfer
DON'T: Believe employer if they say you need their permission
       to leave Qatar or change jobs (this is no longer true)

════════════════════════════════════
8. WORK INJURY & COMPENSATION
════════════════════════════════════
Law: Articles 106–113, Labour Law 14/2004
- Employer MUST insure all workers for work injuries
- Temporary disability: full salary during treatment
- Permanent disability: compensation scale per injury type
  (ranges from 18 months to 60 months salary)
- Death in work: family receives 24 months compensation
  + repatriation of body expenses paid by employer
- Report injury IMMEDIATELY to employer in writing
- Seek treatment at employer-approved medical facility
DO: Report all injuries even minor ones immediately
DON'T: Sign any document releasing employer from liability
       before full recovery and assessment

════════════════════════════════════
9. ACCOMMODATION STANDARDS
════════════════════════════════════
Ministerial Decision No. 18 of 2014
- If employer provides accommodation:
  - Minimum 4.5 sq metres per worker sleeping space
  - Proper ventilation and air conditioning (mandatory in Qatar)
  - Clean drinking water available 24/7
  - Separate toilets: 1 per 8 workers minimum
  - Kitchen facilities if food not provided
- Employer cannot deduct more than actual cost of accommodation
  from salary (must be agreed in contract)
DO: Document substandard conditions with photos
DON'T: Pay inflated deductions for poor accommodation

════════════════════════════════════
10. COMPLAINT & DISPUTE PROCESS
════════════════════════════════════
- Step 1: Internal — raise issue with employer in writing
- Step 2: ADLSA — file online at adlsa.gov.qa or
          ADLSA app or call 16008 (free, 24 hours)
- Step 3: Mediation — ADLSA arranges employer-worker meeting
          (must happen within 3 weeks of complaint)
- Step 4: Labour Court — if mediation fails, automatic referral
- Free legal aid available at Qatar Legal Aid Corporation
- Nearest ADLSA office: Al Sadd, West Bay, Al Wakra, Al Khor

IMPORTANT DISCLAIMER:
This information is for general guidance only.
For official legal advice, contact ADLSA: 16008
or visit adlsa.gov.qa
Laws may have been amended — always verify with official sources.
''';

  // ── LABOUR TOPIC CHIPS ──

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
      'label': 'Notice Period',
      'icon': '📅',
      'question':
          'What is my notice period if I resign or get terminated in Qatar?',
    },
    {
      'label': 'Accommodation',
      'icon': '🏠',
      'question':
          'What are the minimum accommodation standards my employer must provide in Qatar?',
    },
  ];

  // ── LABOUR INTENT KEYWORDS ──

  static const List<String> labourKeywords = [
    'salary',
    'wage',
    'pay',
    'paid',
    'money',
    'overtime',
    'leave',
    'holiday',
    'vacation',
    'sick',
    'gratuity',
    'end of service',
    'eos',
    'terminate',
    'fired',
    'resign',
    'notice',
    'complaint',
    'adlsa',
    'labour',
    'labor',
    'job change',
    'transfer',
    'kafala',
    'exit permit',
    'injury',
    'accident',
    'compensation',
    'accommodation',
    'accommodation',
    'heat',
    'outdoor',
    'wps',
    'working hours',
    'contract',
    'rights',
    'employer',
    'visa',
    'iqama',
    'noc',
    // Arabic keywords
    'راتب',
    'إجازة',
    'مكافأة',
    'شكوى',
    'عمل',
    // Hindi/Urdu keywords
    'तनख्वाह',
    'छुट्टी',
    'शिकायत',
    'نوکری',
    'تنخواہ',
    // Tamil
    'சம்பளம்',
    'விடுப்பு',
    'புகார்',
    // Malayalam
    'ശമ്പളം',
    'അവധി',
    'പരാതി',
    // Nepali
    'तलब',
    'बिदा',
    'उजुरी',
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

  static String buildSystemPrompt({
    required String userLanguageCode,
    required bool isLabourQuery,
  }) {
    final languageName = languageNameForCode(userLanguageCode);

    var systemPrompt = '''
You are Raabta AI, a helpful assistant for expats living in Qatar.
You help with jobs, housing, local services, daily life, and workers' rights.
You are friendly, practical, and concise.

LANGUAGE INSTRUCTION:
The user's preferred language is: $languageName ($userLanguageCode)
Respond in the SAME language the user writes in.
If they write in English, reply in English.
If they write in Arabic, reply in Arabic.
If they write in Hindi, reply in Hindi.
If they write in Tamil, reply in Tamil.
If they write in Malayalam, reply in Malayalam.
If they write in Swahili, reply in Swahili (Kenyan).
If they write in Nepali, reply in Nepali.
If they write in Urdu, reply in Urdu.
Always match the user's language automatically.
''';

    if (isLabourQuery) {
      systemPrompt += '''

LABOUR LAW MODE ACTIVATED:
The user is asking about Qatar labour rights.
Use ONLY the verified legal information below.
Always cite the specific law article or ministerial decision.
End your response with the ADLSA helpline: 16008 when relevant.

$labourLawContext''';
    }

    return systemPrompt;
  }
}
