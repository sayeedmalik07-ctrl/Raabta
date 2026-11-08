import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:raabta/features/scam_shield/check_number/number_facts.dart';
import 'package:raabta/features/scam_shield/data/scam_authority_directory_config.dart';

class NumberGuidanceInput {
  const NumberGuidanceInput({
    required this.facts,
    this.channel,
    this.claimedAuthorityId,
  });

  final NumberFacts facts;
  final CheckNumberReachChannel? channel;
  final String? claimedAuthorityId;
}

abstract final class NumberGuidanceResolver {
  static const assetPath = 'assets/scam_shield/check_number_guidance.json';
  static Map<String, _GuidanceMeta>? _cards;

  @visibleForTesting
  static void installForTest(Map<String, _GuidanceMeta> cards) => _cards = cards;

  static Future<void> _ensureLoaded() async {
    if (_cards != null) return;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['cards'] as List<dynamic>? ?? [];
    _cards = {
      for (final item in list)
        if (item is Map<String, dynamic>)
          item['id']?.toString() ?? '': _GuidanceMeta(
            id: item['id']?.toString() ?? '',
            verified: item['verified'] == true,
            textKey: item['textKey']?.toString() ?? '',
            sourceLabel: item['sourceLabel']?.toString() ?? '',
            sourceUrl: item['sourceUrl'] as String?,
          ),
    };
  }

  static Future<List<NumberGuidanceCard>> resolve(NumberGuidanceInput input) async {
    await _ensureLoaded();
    final out = <NumberGuidanceCard>[];

    void add(String id) {
      final meta = _cards![id];
      if (meta == null || !meta.verified) return;
      out.add(
        NumberGuidanceCard(
          id: meta.id,
          textKey: meta.textKey,
          sourceLabel: meta.sourceLabel,
          sourceUrl: meta.sourceUrl,
        ),
      );
    }

    final isInternational = input.facts.type == NumberFactType.international;
    final isVoip = input.channel == CheckNumberReachChannel.whatsAppOrVoip ||
        input.channel == CheckNumberReachChannel.otherApp;
    final claimed = input.claimedAuthorityId;
    final claimedEntry =
        claimed == null ? null : ScamAuthorityDirectoryConfig.findById(claimed);
    final sensitiveClaim = claimedEntry != null &&
        (claimedEntry.category == ScamAuthorityCategory.bank ||
            claimedEntry.category == ScamAuthorityCategory.government ||
            claimedEntry.category == ScamAuthorityCategory.telecom);

    if ((isInternational || isVoip) && sensitiveClaim) {
      add('cra_voip_no_whatsapp');
    }

    add('caller_id_can_be_faked');
    return out;
  }

  static Future<NumberGuidanceCard?> cnapCard() async {
    await _ensureLoaded();
    final meta = _cards!['cnap_rollout'];
    if (meta == null || !meta.verified) return null;
    return NumberGuidanceCard(
      id: meta.id,
      textKey: meta.textKey,
      sourceLabel: meta.sourceLabel,
      sourceUrl: meta.sourceUrl,
    );
  }
}

class _GuidanceMeta {
  const _GuidanceMeta({
    required this.id,
    required this.verified,
    required this.textKey,
    required this.sourceLabel,
    this.sourceUrl,
  });

  final String id;
  final bool verified;
  final String textKey;
  final String sourceLabel;
  final String? sourceUrl;
}
