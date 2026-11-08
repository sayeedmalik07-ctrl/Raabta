import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_share.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:share_plus/share_plus.dart';

class FamilyVerificationShareScreen extends ConsumerStatefulWidget {
  const FamilyVerificationShareScreen({super.key});

  @override
  ConsumerState<FamilyVerificationShareScreen> createState() =>
      _FamilyVerificationShareScreenState();
}

class _FamilyVerificationShareScreenState
    extends ConsumerState<FamilyVerificationShareScreen> {
  late String _recipientLocale;

  static final _teal = AppColors.tealFamilyMain;

  @override
  void initState() {
    super.initState();
    _recipientLocale = 'English';
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final preview = FamilyVerificationShareBuilder.buildText(_recipientLocale);
    final lines = preview.split('\n');
    final titleLine = lines.isNotEmpty ? lines[0] : '';
    final introLine = lines.length > 2 ? lines[2] : '';
    final ruleLines = <String>[];
    final rulePrefix = RegExp(r'^[123]\.\s+');
    for (final line in lines) {
      final match = rulePrefix.firstMatch(line);
      if (match != null) {
        ruleLines.add(line.substring(match.end));
      }
    }
    String footerLine = '';
    for (var i = lines.length - 1; i >= 0; i--) {
      final s = lines[i].trim();
      if (s.isNotEmpty) {
        footerLine = lines[i];
        break;
      }
    }
    if (footerLine == titleLine) footerLine = '';

    return HubSubscreenScaffold(
      title: FamilyVerificationKitStrings.t(
        'ss_fvk_share_screen_title',
        locale,
      ),
      subtitle: FamilyVerificationKitStrings.t('ss_fvk_share_subtitle', locale),
      onBack: () => context.pop(),
      body: ListView(
        padding: moneyHubScreenPadding,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              FamilyVerificationKitStrings.t('ss_fvk_share_section_language', locale),
              style: AppTypography.subtitle.copyWith(
                color: _teal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: _teal,
            glowIntensity: 0.07,
            borderRadius: AppSpacing.radiusMd,
            child: DropdownButtonFormField<String>(
              key: ValueKey(_recipientLocale),
              initialValue: _recipientLocale,
              decoration: _fvkTealFieldDecoration(
                labelText: FamilyVerificationKitStrings.t(
                  'ss_fvk_share_picker_label',
                  locale,
                ),
              ),
              dropdownColor: AppColors.surfaceElevated,
              items: [
                for (final loc in FamilyVerificationKitStrings.shareLocales)
                  DropdownMenuItem(
                    value: loc,
                    child: Text(loc),
                  ),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _recipientLocale = v);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              FamilyVerificationKitStrings.t('ss_fvk_share_section_preview', locale),
              style: AppTypography.subtitle.copyWith(
                color: _teal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            glowColor: _teal,
            glowIntensity: 0.06,
            borderRadius: AppSpacing.radiusLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  titleLine,
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (introLine.trim().isNotEmpty)
                  Text(
                    introLine,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                if (ruleLines.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    FamilyVerificationKitStrings.t(
                      'ss_fvk_share_preview_rules_heading',
                      locale,
                    ),
                    style: AppTypography.caption.copyWith(
                      color: _teal,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (var r = 0; r < ruleLines.length; r++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _teal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusXs,
                              ),
                            ),
                            child: Text(
                              '${r + 1}',
                              style: AppTypography.caption.copyWith(
                                color: _teal,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              ruleLines[r],
                              style: AppTypography.bodySmall.copyWith(
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                if (footerLine.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    footerLine,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.35,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassPrimaryButton(
            label: FamilyVerificationKitStrings.t('ss_fvk_share_cta', locale),
            icon: Icons.share_outlined,
            expand: true,
            accentColor: _teal,
            onPressed: () {
              FamilyVerificationShareBuilder.assertShareSafe(shareText: preview);
              Share.share(preview);
            },
          ),
        ],
      ),
    );
  }
}

InputDecoration _fvkTealFieldDecoration({
  required String labelText,
  String? hintText,
}) {
  final enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    borderSide: BorderSide(color: AppColors.glassBorder),
  );
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    labelStyle: AppTypography.caption,
    hintStyle:
        AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.isLight ? AppColors.surface : AppColors.glassSurface,
    border: enabledBorder,
    enabledBorder: enabledBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(
        color: AppColors.tealFamilyMain.withValues(alpha: 0.45),
      ),
    ),
  );
}
