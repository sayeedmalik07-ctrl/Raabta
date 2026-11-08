/// Practice-only theory questions — facts traceable to prompt-verified MOI guidance (28 Jul 2026).
/// NOT official MOI test content. Full bank requires licensed driving-school verification before marketing.
library;

enum TheoryQuizCategory {
  roadSigns,
  rightOfWay,
  speedLimits,
  parking,
  documentation,
  penaltiesPoints,
}

extension TheoryQuizCategoryX on TheoryQuizCategory {
  String get label {
    switch (this) {
      case TheoryQuizCategory.roadSigns:
        return 'Road Signs';
      case TheoryQuizCategory.rightOfWay:
        return 'Right of Way';
      case TheoryQuizCategory.speedLimits:
        return 'Speed Limits & Zones';
      case TheoryQuizCategory.parking:
        return 'Parking Rules';
      case TheoryQuizCategory.documentation:
        return 'Documentation';
      case TheoryQuizCategory.penaltiesPoints:
        return 'Penalties & Points';
    }
  }

  String get id => name;
}

class TheoryQuestion {
  const TheoryQuestion({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final TheoryQuizCategory category;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

/// Starter bank — expand with MOI-licensed curriculum before calling production-ready.
final drivingTheoryQuestions = <TheoryQuestion>[
  TheoryQuestion(
    id: 'pen_1',
    category: TheoryQuizCategory.penaltiesPoints,
    question:
        'Since September 2024, what happens if you have unpaid traffic fines in Qatar?',
    options: [
      'Nothing until court summons',
      'MOI blocks exit from Qatar and blocks QID/Istimara/licence renewal',
      'Only a SMS reminder',
      'Fines double automatically after 7 days',
    ],
    correctIndex: 1,
    explanation:
        'MOI blocks exit (air, land, sea) for unpaid fines and blocks QID, Istimara, and driving licence renewal until cleared.',
  ),
  TheoryQuestion(
    id: 'pen_2',
    category: TheoryQuizCategory.penaltiesPoints,
    question: 'What is the driving licence renewal fee for expats in Qatar?',
    options: ['QAR 500 for 10 years', 'QAR 250 for 5 years', 'QAR 100 per year', 'Free'],
    correctIndex: 1,
    explanation:
        'Expats pay QAR 250 for a 5-year licence. Qatari citizens pay QAR 500 for 10 years (MOI Traffic, verified Jul 2026).',
  ),
  TheoryQuestion(
    id: 'pen_3',
    category: TheoryQuizCategory.penaltiesPoints,
    question: 'Driving a vehicle without valid Istimara (registration) may result in:',
    options: [
      'Warning only',
      'QAR 3,000 fine and 2 black points',
      'Vehicle confiscation immediately',
      'QAR 500 fine only',
    ],
    correctIndex: 1,
    explanation:
        'Driving an unregistered vehicle: QAR 3,000 fine plus 2 black points under MOI Traffic rules.',
  ),
  TheoryQuestion(
    id: 'pen_4',
    category: TheoryQuizCategory.penaltiesPoints,
    question:
        'After Istimara expiry, what is true about the 30-day grace period?',
    options: [
      'You may continue driving normally',
      'You may renew without penalty but cannot drive the vehicle',
      'No grace period exists',
      'Grace period is 90 days with driving allowed',
    ],
    correctIndex: 1,
    explanation:
        'A 30-day grace allows renewal without penalty, but the vehicle legally cannot be driven during that window.',
  ),
  TheoryQuestion(
    id: 'pen_5',
    category: TheoryQuizCategory.penaltiesPoints,
    question: 'At the first black-points threshold breach (12 points), your licence is:',
    options: [
      'Permanently cancelled',
      'Suspended for 3 months',
      'Suspended for 6 months',
      'Not affected until 24 points',
    ],
    correctIndex: 1,
    explanation:
        'First threshold breach at 12 points: 3-month suspension. Second breach: 6 months. Fifth repeat at 6 points: permanent cancellation.',
  ),
  TheoryQuestion(
    id: 'doc_1',
    category: TheoryQuizCategory.documentation,
    question: 'Before renewing your Qatar driving licence you must typically:',
    options: [
      'Pass a new theory test every year',
      'Clear outstanding fines and complete an eye test',
      'Surrender your passport',
      'Only pay online with no other steps',
    ],
    correctIndex: 1,
    explanation:
        'Outstanding fines must be cleared and an eye test at an approved centre is required before licence renewal.',
  ),
  TheoryQuestion(
    id: 'doc_2',
    category: TheoryQuizCategory.documentation,
    question: 'Istimara renewal generally requires:',
    options: [
      'Only online payment',
      'FAHES vehicle inspection among other MOI steps',
      'International driving permit only',
      'Employer NOC only',
    ],
    correctIndex: 1,
    explanation:
        'FAHES inspection is required for Istimara renewal; exact steps and fees are on the MOI/Metrash portal.',
  ),
  TheoryQuestion(
    id: 'sign_1',
    category: TheoryQuizCategory.roadSigns,
    question: 'A red octagonal sign universally means:',
    options: ['Yield', 'Stop', 'No entry', 'Speed limit'],
    correctIndex: 1,
    explanation: 'Octagonal red signs indicate STOP — halt completely before proceeding when safe.',
  ),
  TheoryQuestion(
    id: 'sign_2',
    category: TheoryQuizCategory.roadSigns,
    question: 'A circular sign with a red border and white background usually indicates:',
    options: ['Information', 'Prohibition or restriction', 'Direction guidance', 'Parking allowed'],
    correctIndex: 1,
    explanation:
        'Circular signs with red borders are regulatory prohibitions (e.g. no entry, speed limit).',
  ),
  TheoryQuestion(
    id: 'row_1',
    category: TheoryQuizCategory.rightOfWay,
    question: 'At an intersection without signals, you should:',
    options: [
      'Always speed through if clear',
      'Give way to traffic on the main road and proceed with caution',
      'Honk continuously',
      'Reverse if unsure',
    ],
    correctIndex: 1,
    explanation:
        'Yield to traffic on the priority road; enter only when safe — standard GCC intersection practice.',
  ),
  TheoryQuestion(
    id: 'speed_1',
    category: TheoryQuizCategory.speedLimits,
    question: 'Urban speed limits in Qatar residential areas are typically lower than:',
    options: [
      'Highway limits — watch for posted signs',
      'Always 140 km/h everywhere',
      'There are no limits in cities',
      'Only motorcycles have limits',
    ],
    correctIndex: 0,
    explanation:
        'Always obey posted limits; urban and residential zones are lower than expressways. Confirm current limits on MOI guidance.',
  ),
  TheoryQuestion(
    id: 'park_1',
    category: TheoryQuizCategory.parking,
    question: 'Parking in a disabled bay without authorisation is:',
    options: [
      'Allowed for short stops',
      'A violation subject to fines',
      'Free after 6 PM',
      'Allowed with hazard lights',
    ],
    correctIndex: 1,
    explanation:
        'Reserved bays are for authorised holders only; misuse carries fines under traffic regulations.',
  ),
];

List<TheoryQuestion> questionsForCategory(TheoryQuizCategory? category) {
  if (category == null) return List.from(drivingTheoryQuestions);
  return drivingTheoryQuestions.where((q) => q.category == category).toList();
}
