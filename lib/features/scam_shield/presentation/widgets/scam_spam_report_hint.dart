import 'package:flutter/material.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/scam_shield_config.dart';

class ScamSpamReportHint extends StatelessWidget {
  const ScamSpamReportHint({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final code = ScamShieldConfig.spamReportShortCode;
    if (code == null || code.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      ScamShieldStrings.format(
        'ss_spam_report_forward',
        locale,
        {'code': code.trim()},
      ),
      style: AppTypography.bodySmall,
    );
  }
}
