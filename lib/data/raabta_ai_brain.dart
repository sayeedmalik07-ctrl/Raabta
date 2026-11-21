import 'package:raabta/data/qatar_health_insurance_kb.dart';
import 'package:raabta/data/qatar_labour_law_kb.dart';
import 'package:raabta/data/raabta_capabilities_reference.dart';
import 'package:raabta/data/raabta_feature_navigation_guide.dart';
import 'package:raabta/data/raabta_resident_knowledge.dart';
import 'package:raabta/services/ai/legal_guidance_classifier.dart';

/// Central "Raabta AI Brain" — system-prompt assembly & topic-based context injection.
/// Used by [ClaudeAIService] and [ApiService]; extends existing keyword-RAG pattern.
class RaabtaAIBrain {
  RaabtaAIBrain._();

  static const brainVersion = '2026-09-17-selective-nav';

  static const _scopeBoundary = '''
SCOPE (mandatory):
You are Raabta AI, the in-app AI assistant for Raabta users — focused on life, work, services, documents, money, safety, health, housing, immigration, community, and practical needs in Qatar.

Prioritize: (A) Raabta app help and navigation, (B) Qatar expat/resident practical guidance, (C) topics supported by Raabta knowledge sources, (D) grounded official guidance where injected below.

Do NOT behave as a general-purpose assistant for clearly unrelated requests (e.g. unrelated poems, general trivia with no Qatar/Raabta link, unrelated-country law presented as Raabta advice, general entertainment, unrelated coding with no Raabta connection).

For clearly unrelated requests: reply briefly (~2 sentences), politely redirect toward Raabta/Qatar help. Do not be hostile. Do not claim you know nothing outside Qatar.

Borderline or reasonable Qatar/Raabta connections — answer normally. Raabta app development questions ARE in scope.

Other countries: if asked to calculate or advise using another country's rules (e.g. UAE EOSB), explain Raabta tools are built for Qatar and redirect to the relevant Qatar feature — do not present foreign calculations as Raabta output.

CLASSIFIEDS / TRANSACTIONS (when the user asks to buy, hire, book, pay through Raabta, or complete a deal on a listing):
State clearly: Raabta lists and connects only; it is not a party to transactions and does not process payments. Then give practical safety steps (verify in person, official channels). Do not imply Raabta holds funds, escrow, or guarantees outcomes.
''';

  static const _personalityAndRouting = '''
PERSONALITY & RESPONSE ROUTING:
- Keep Raabta AI's warm, practical, concise tone.
- Route 1 — App help: when the user asks how to use Raabta, use NAVIGATION GUIDE steps when provided (shortest useful path). If only NAVIGATION INDEX is present, orient to the best route from the index and compact capabilities — do not invent screens or routes.
- Route 2 — Grounded legal/official guidance: for labour law, immigration, or high-stakes topics, use ONLY injected knowledge below. Never invent article numbers or exact clauses — if unsure, say so and point to mol.gov.qa, Al Meezan (almeezan.qa), or a licensed advisor.
- Route 3 — Human/official channel: active disputes, urgent legal matters, or employer threats → recommend MoL/ADLSA helpline **16008**, Unified Complaints Portal (mol.gov.qa, NAS login), MOI/Metrash, or licensed legal counsel — do not play lawyer.
- Mention another Raabta feature only when it genuinely helps; never spam feature ads.
- Keep responses focused; under ~250 words unless the user needs steps.

APP HELP PATTERN (how-to questions):
1. Identify the relevant feature from the navigation guide.
2. Give the shortest verified in-app steps (numbered).
3. Mention prerequisites if listed.
4. Add at most two action buttons when genuinely useful.

RAABTA ACTIONS (max 2 per reply — own line each):
[[action:/route-path|Short button label]]
Examples: [[action:/eosb|Calculate EOSB]] [[action:/visa|Open Visa Help]]
''';

  static const _legalDisclaimer = '''
LEGAL DISCLAIMER (append briefly when giving legal/residency guidance — one short sentence, natural tone):
This is general guidance, not legal advice. For binding answers verify via mol.gov.qa, Al Meezan, or a licensed advisor.
''';

  static String _greetingInstructions({
    required bool isFirstAssistantTurn,
    String? userGreetingName,
  }) {
    if (!isFirstAssistantTurn) {
      return '''
GREETING:
This is an ongoing conversation — do NOT repeat a time-of-day or name greeting. Answer directly.
''';
    }

    final nameClause = userGreetingName != null && userGreetingName.trim().isNotEmpty
        ? 'You may greet the user once as "$userGreetingName" with a natural time-of-day (Good morning/afternoon/evening).'
        : 'You may use a natural time-of-day greeting (Good morning/afternoon/evening) without a name.';

    return '''
GREETING (first assistant reply in this conversation only):
$nameClause
Keep the greeting to one short clause, then answer the question. Never double-greet. Do not repeat the greeting on later turns.
Example tone: "Good evening, Mohammad. Open EOSB to enter your employment details…" (only when name is available).
''';
  }

  /// Full chat system prompt — capabilities baseline + topic-triggered injections.
  static String buildChatContext({
    required String message,
    required String userLanguageCode,
    String? userGreetingName,
    bool isFirstAssistantTurn = false,
    List<Map<String, String>> conversationHistory = const [],
    String? rollingSummaryForSelection,
  }) {
    final languageName = QatarLabourLawKB.languageNameForCode(userLanguageCode);
    final labourTopics = QatarLabourLawKB.detectLabourTopics(message);
    final residentTopics = RaabtaResidentKnowledge.detectTopics(message);
    final isLabour = labourTopics.isNotEmpty || QatarLabourLawKB.isLabourQuery(message);
    final isHealthInsurance = QatarHealthInsuranceKB.isHealthInsuranceQuery(message);
    final requiresLegalDisclaimer =
        LegalGuidanceClassifier.requiresDisclaimer(message);

    final buffer = StringBuffer('''
You are Raabta AI, the in-app assistant for Raabta users in Qatar.
Brain version: $brainVersion

LANGUAGE: User preference is $languageName ($userLanguageCode). Match the language the user writes in.

$_scopeBoundary

${_greetingInstructions(
  isFirstAssistantTurn: isFirstAssistantTurn,
  userGreetingName: userGreetingName,
)}

$_personalityAndRouting

${RaabtaCapabilitiesReference.compactReference}

${RaabtaFeatureNavigationGuide.buildContextualPromptForRequest(
  message: message,
  conversationHistory: conversationHistory,
  rollingSummary: rollingSummaryForSelection,
)}
''');

    if (isLabour) {
      buffer.writeln(QatarLabourLawKB.buildLabourInjection(labourTopics, message));
      buffer.writeln(_legalDisclaimer);
    }

    if (isHealthInsurance) {
      buffer.writeln(QatarHealthInsuranceKB.injection);
      buffer.writeln(_legalDisclaimer);
    }

    if (residentTopics.isNotEmpty) {
      buffer.writeln(RaabtaResidentKnowledge.buildInjection(residentTopics));
    }

    if (requiresLegalDisclaimer && !isLabour && !isHealthInsurance) {
      buffer.writeln(_legalDisclaimer);
    }

    return buffer.toString().trim();
  }

  /// Research mode — labour disputes with explicit citations (Premium).
  static String buildResearchContext({
    required String message,
    required String userLanguageCode,
  }) {
    final languageName = QatarLabourLawKB.languageNameForCode(userLanguageCode);
    final labourTopics = QatarLabourLawKB.detectLabourTopics(message);
    final topics = labourTopics.isNotEmpty
        ? labourTopics
        : ['overview', 'complaints', 'gratuity_eos'];

    return '''
RESEARCH MODE — Qatar labour law (Premium). Language: $languageName ($userLanguageCode).
Provide structured analysis with numbered steps and official sources.
When citing a law source, append on its own line: [[cite:Source name|Short label]]
Example: [[cite:Law 14/2004|Qatar Labour Law]]
Do NOT invent article numbers. If uncertain, say verify via Al Meezan (almeezan.qa) or MoL/ADLSA **16008**.
Suggest Raabta tools when helpful using [[action:/route|Label]] markers.

${QatarLabourLawKB.buildLabourInjection(topics, message)}
$_legalDisclaimer
'''.trim();
  }

  /// Labour-focused context for EOSB/contract analysis prompts (no full app catalog).
  static String buildLabourExpertContext({
    required String message,
    required String userLanguageCode,
  }) {
    final languageName = QatarLabourLawKB.languageNameForCode(userLanguageCode);
    final topics = QatarLabourLawKB.detectLabourTopics(message);
    return '''
You are Raabta AI labour-law assistant for Qatar employment matters.
LANGUAGE: $languageName ($userLanguageCode).
${QatarLabourLawKB.buildLabourInjection(topics.isNotEmpty ? topics : ['contracts', 'gratuity_eos'], message)}
Never invent article numbers. Not formal legal advice — verify via mol.gov.qa / Al Meezan.
''';
  }

  /// True when Railway/backend is down — not a user or prompt error.
  static bool isBackendUnavailable(int statusCode, Map<String, dynamic>? body) {
    if (statusCode == 404 || statusCode == 502 || statusCode == 503) return true;
    final msg = body?['message'] as String? ?? body?['error'] as String? ?? '';
    return msg.toLowerCase().contains('application not found') ||
        msg.toLowerCase().contains('not found');
  }

  /// Offline answer from local KB when `/api/chat` is unreachable (e.g. Railway down).
  static String buildOfflineFallbackReply({
    required String message,
    required String userLanguageCode,
  }) {
    final labourTopics = QatarLabourLawKB.detectLabourTopics(message);
    final isLabour =
        labourTopics.isNotEmpty || QatarLabourLawKB.isLabourQuery(message);
    final residentTopics = RaabtaResidentKnowledge.detectTopics(message);
    final featureHint = _offlineFeatureHint(message);

    final buffer = StringBuffer(
      'Live AI is temporarily unavailable (server maintenance). '
      'Here is guidance from Raabta\'s verified Qatar guide:\n\n',
    );

    if (isLabour) {
      final topics = labourTopics.isNotEmpty
          ? labourTopics
          : ['overview', 'complaints'];
      buffer.writeln(
        _formatKbForUser(
          QatarLabourLawKB.buildLabourInjection(topics, message),
        ),
      );
      buffer.writeln(
        '\nOfficial channels: MoL/ADLSA helpline **16008**, SMS 92727 (5+QID), mol.gov.qa complaints portal, Al Meezan (almeezan.qa).',
      );
      buffer.writeln(
        'General guidance only — not legal advice. Pull to refresh or try again later for full AI chat.',
      );
      return buffer.toString().trim();
    }

    if (residentTopics.isNotEmpty) {
      buffer.writeln(
        _formatKbForUser(
          RaabtaResidentKnowledge.buildInjection(residentTopics),
        ),
      );
      buffer.writeln(
        '\nVerify specifics on moi.gov.qa / Metrash. Try again later for full AI chat.',
      );
      return buffer.toString().trim();
    }

    if (featureHint != null) {
      buffer.writeln(featureHint);
      buffer.writeln('\nTry again later for a full conversational AI reply.');
      return buffer.toString().trim();
    }

    return '${buffer}I could not reach the AI server right now. '
        'Please try again in a few minutes.\n\n'
        'For urgent labour matters call MoL/ADLSA **16008**. '
        'Browse Raabta features from Home — Jobs, Housing, Money Hub, Community, and Quick Actions.';
  }

  static String _formatKbForUser(String raw) {
    return raw
        .replaceAll(RegExp(r'═+'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  static String? _offlineFeatureHint(String message) {
    final lower = message.toLowerCase();
    if (RegExp(r'\bbill|kahramaa|ooredoo|utility').hasMatch(lower)) {
      return 'Track utility bills in **Bill Tracker** → `/bill-tracker` (Home → Quick Actions).';
    }
    if (RegExp(r'\bexchange rate|currency|transfer|remit').hasMatch(lower)) {
      return 'Check indicative rates and find exchange branches in **Money Hub** → `/money` (Rates tab or Find a Branch tab).';
    }
    if (RegExp(r'\bjob|career|cv|interview|hse').hasMatch(lower)) {
      return 'Browse and post jobs in **Jobs** → `/jobs`.';
    }
    if (RegExp(r'\broom|rent|housing|flat|accommodation').hasMatch(lower)) {
      return 'Find rooms and apartments in **Housing** → `/housing`.';
    }
    if (RegExp(r'\bscan|document|ocr|pdf').hasMatch(lower)) {
      return 'Use **Doc Scanner** → `/scanner/capture` or **Document Vault** → `/document-vault`.';
    }
    if (RegExp(r'\bgratuity|eos|end of service').hasMatch(lower)) {
      return 'Calculate end-of-service benefits in **EOSB Truth Engine** → `/eosb`.';
    }
    return null;
  }
}
