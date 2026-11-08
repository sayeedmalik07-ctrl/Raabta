import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/data/models/home_country_support_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

/// Country-agnostic "Is This Offer Real?" checklist — static, no AI.
class OfferAuthenticitySection extends StatelessWidget {
  const OfferAuthenticitySection({
    super.key,
    required this.checklist,
    required this.locale,
    this.checkedKeys,
    this.onToggle,
  });

  final OfferAuthenticityChecklistDef checklist;
  final String locale;
  final Map<String, bool>? checkedKeys;
  final void Function(String key, bool value)? onToggle;

  bool get _interactive => checkedKeys != null && onToggle != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EosbStrings.t('eosb_bys_offer_real_title', locale),
          style: AppTypography.subtitle.copyWith(color: AppColors.accentGold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          EosbStrings.t(checklist.introKey, locale),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        _Group(
          headingKey: 'eosb_bys_offer_comm_heading',
          itemKeys: checklist.communicationRedFlagKeys,
          locale: locale,
          icon: Icons.chat_bubble_outline,
          checkedKeys: checkedKeys,
          onToggle: onToggle,
          interactive: _interactive,
        ),
        const SizedBox(height: AppSpacing.md),
        _Group(
          headingKey: 'eosb_bys_offer_pay_heading',
          itemKeys: checklist.paymentRedFlagKeys,
          locale: locale,
          icon: Icons.payments_outlined,
          checkedKeys: checkedKeys,
          onToggle: onToggle,
          interactive: _interactive,
        ),
        const SizedBox(height: AppSpacing.md),
        _Group(
          headingKey: 'eosb_bys_offer_doc_heading',
          itemKeys: checklist.documentationRedFlagKeys,
          locale: locale,
          icon: Icons.description_outlined,
          checkedKeys: checkedKeys,
          onToggle: onToggle,
          interactive: _interactive,
        ),
        const SizedBox(height: AppSpacing.md),
        _Group(
          headingKey: 'eosb_bys_offer_verify_heading',
          itemKeys: checklist.verificationActionKeys,
          locale: locale,
          icon: Icons.verified_user_outlined,
          iconColor: AppColors.purpleGlow,
          checkedKeys: checkedKeys,
          onToggle: onToggle,
          interactive: _interactive,
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.headingKey,
    required this.itemKeys,
    required this.locale,
    required this.icon,
    this.iconColor,
    this.checkedKeys,
    this.onToggle,
    required this.interactive,
  });

  final String headingKey;
  final List<String> itemKeys;
  final String locale;
  final IconData icon;
  final Color? iconColor;
  final Map<String, bool>? checkedKeys;
  final void Function(String key, bool value)? onToggle;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EosbStrings.t(headingKey, locale),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        ...itemKeys.map(
          (key) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: interactive
                ? CheckboxListTile(
                    value: checkedKeys![key] == true,
                    onChanged: (v) => onToggle!(key, v ?? false),
                    title: Text(
                      EosbStrings.t(key, locale),
                      style: AppTypography.bodySmall,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 16, color: iconColor ?? AppColors.warning),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          EosbStrings.t(key, locale),
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
