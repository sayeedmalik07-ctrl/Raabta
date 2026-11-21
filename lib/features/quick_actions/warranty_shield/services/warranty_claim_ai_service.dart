import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';
import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// Drafts factual warranty claim messages — mirrors Health Insurance dispute letter pattern.
class WarrantyClaimAiService {
  WarrantyClaimAiService(this._ref);

  final Ref _ref;

  static const requestTypeLetter = 'warranty_shield_claim_letter';

  ClaudeAIService get _ai => _ref.read(claudeAIServiceProvider);

  Future<String> draftClaimLetter({
    required WarrantyItem item,
    required String issueDescription,
    required String locale,
    bool hasFaultPhoto = false,
    bool warrantyExpired = false,
  }) async {
    final recipient = item.retailer.isNotEmpty
        ? '${item.retailer} Customer Service / Warranty Department'
        : '${item.brand} Customer Service';

    final package = TruthPackage(
      engineType: 'warrantyShield',
      facts: {
        'recipient': recipient,
        'productName': item.productName,
        'brand': item.brand,
        if (item.retailer.isNotEmpty) 'retailer': item.retailer,
        'category': item.category,
        'purchaseDate': item.purchaseDate.toIso8601String().split('T').first,
        'warrantyExpiryDate': item.expiryDate.toIso8601String().split('T').first,
        'purchasePrice': item.purchasePriceQar,
        'currency': item.currency,
        'issueDescription': issueDescription.trim(),
        'hasFaultPhotoAttached': hasFaultPhoto,
        'warrantyMarkedExpiredInApp': warrantyExpired,
      },
      calculation: const {},
      assumptions: const [
        'Product and purchase details reflect what the user saved in Warranty Shield.',
        'The issue description is the user\'s own words — not verified by Raabta.',
      ],
      unknowns: const [
        'Whether the retailer or manufacturer will approve repair, replacement, or refund cannot be predicted.',
        'Store-specific warranty terms not printed on the saved receipt are not known to this assistant.',
        'Raabta does not assess legal validity of the claim.',
      ],
      sourceRefs: const [],
    );

    final letterFooter = WarrantyStrings.t('warr_claim_letter_footer', locale);

    final reply = await _ai.sendMessage(
      TruthPackagePrompt.build(
        package: package,
        locale: locale,
        trailingInstructions: '''
Draft a formal warranty claim / complaint letter to the retailer or brand using ONLY facts in the TruthPackage.
- Use a neutral, factual, polite business tone — describe the fault and request a resolution (repair, replacement, or refund).
- Do NOT assert that the user has a legal right, cite Qatar consumer-protection statutes, or predict the outcome.
- Do NOT give legal advice or recommend lawyers unless the user already mentioned escalation in their description.
- If warrantyMarkedExpiredInApp is true, note politely that the warranty period appears expired while still describing the issue factually.
- If hasFaultPhotoAttached is true, mention that supporting photos are available upon request (do not describe photo contents you cannot see).
- End the letter body with this exact footer on its own line:
"$letterFooter"
- Formal business letter format with date placeholder [Date], addressee, subject, body, closing.''',
      ),
      language: locale,
      requestType: requestTypeLetter,
    );

    final letter = reply.trim();
    if (!letter.contains(letterFooter)) {
      return '$letter\n\n$letterFooter';
    }
    return letter;
  }
}

final warrantyClaimAiServiceProvider = Provider<WarrantyClaimAiService>(
  (ref) => WarrantyClaimAiService(ref),
);
