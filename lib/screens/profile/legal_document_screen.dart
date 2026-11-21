import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/config/app_config.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/raabta_platform_notices_panel.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/data/legal_content.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/screens/profile/profile_tab_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({super.key, required this.type});

  final LegalDocumentType type;

  String _onlineUrl() => switch (type) {
        LegalDocumentType.privacy => AppConfig.privacyPolicyUrl,
        LegalDocumentType.terms => AppConfig.termsOfServiceUrl,
      };

  String _title(String locale) => switch (type) {
        LegalDocumentType.privacy =>
          ProfileStrings.t('settings_privacy_policy', locale),
        LegalDocumentType.terms => ProfileStrings.t('legal_terms_title', locale),
      };

  Future<void> _openOnline(BuildContext context, String locale) async {
    final url = _onlineUrl();
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ProfileStrings.format(
              'legal_open_failed',
              locale,
              params: {'url': url},
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    return ProfileTabScaffold(
      child: GlassScreenScaffold(
        title: _title(locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_rounded,
          tooltip: CommonActionStrings.t('action_back', locale),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _openOnline(context, locale),
            icon: Icon(Icons.open_in_new, size: 18, color: AppColors.cyanGlow),
            label: Text(
              ProfileStrings.t('legal_online', locale),
              style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
            ),
          ),
        ],
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RaabtaPlatformNoticesPanel(locale: locale, dense: true),
              const SizedBox(height: AppSpacing.lg),
              SelectableText(
                LegalContent.body(type),
                style: AppTypography.body.copyWith(height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
