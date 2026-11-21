import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_prefs.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_strings.dart';

class ScamAnonymousSignalConsentScreen extends StatelessWidget {
  const ScamAnonymousSignalConsentScreen({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassScreenScaffold(
      title: ScamAnonymousSignalStrings.t('ss_signal_consent_title', locale),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            ScamAnonymousSignalStrings.t('ss_signal_consent_purpose', locale),
            style: AppTypography.body,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            ScamAnonymousSignalStrings.t('ss_signal_consent_sent', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ScamAnonymousSignalStrings.t('ss_signal_consent_never', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ScamAnonymousSignalStrings.t('ss_signal_consent_retention', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ScamAnonymousSignalStrings.t('ss_signal_consent_no_ads', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassPrimaryButton(
            label: ScamAnonymousSignalStrings.t('ss_signal_consent_enable', locale),
            onPressed: () async {
              await ScamAnonymousSignalPrefs.setOptedIn(true);
              await ScamAnonymousSignalPrefs.clearDeclined();
              if (context.mounted) Navigator.pop(context, true);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () async {
              await ScamAnonymousSignalPrefs.recordDeclined();
              if (context.mounted) Navigator.pop(context, false);
            },
            child: Text(
              ScamAnonymousSignalStrings.t('ss_signal_consent_decline', locale),
            ),
          ),
        ],
      ),
    );
  }
}
