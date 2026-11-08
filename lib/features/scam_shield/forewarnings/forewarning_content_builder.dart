import 'package:raabta/features/scam_shield/domain/scam_advisory_models.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_models.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_string_resolver.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

abstract final class ForewarningContentBuilder {
  static ForewarningResolvedContent build({
    required ForewarningMomentDefinition moment,
    required int variantIndex,
    required String locale,
    List<ScamAdvisory> advisories = const [],
  }) {
    final variants = moment.variants;
    final index = variantIndex.clamp(0, variants.length - 1);
    final body = variants.isEmpty
        ? ''
        : ForewarningStringResolver.resolve(variants[index].reuseKey, locale);

    String? advisoryLine;
    final category = moment.advisoryCategory;
    if (category != null && advisories.isNotEmpty) {
      for (final a in advisories) {
        if (!a.isActive || a.category != category) continue;
        final when = a.sourceDate ?? a.publishedAt ?? DateTime.now();
        final date = when.toIso8601String().split('T').first;
        advisoryLine = ScamShieldStrings.format(
          'ss_forewarning_advisory_line',
          locale,
          {
            'title': a.title,
            'source': a.sourceName,
            'date': date,
          },
        );
        break;
      }
    }

    return ForewarningResolvedContent(
      body: body,
      sourceLabel: moment.sourceLabel,
      advisoryLine: advisoryLine,
      ctaTarget: moment.ctaTarget,
    );
  }
}
