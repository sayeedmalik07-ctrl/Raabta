import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/data/models/home_country_support_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:url_launcher/url_launcher.dart';

class MigrantSupportResourceTile extends StatelessWidget {
  const MigrantSupportResourceTile({
    super.key,
    required this.resource,
    required this.locale,
    this.compact = false,
  });

  final HomeCountrySupportResourceDef resource;
  final String locale;
  final bool compact;

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openContact(HomeCountrySupportContactDef contact) async {
    switch (contact.type) {
      case HomeCountrySupportContactType.phone:
        final uri = Uri.parse('tel:${contact.value}');
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      case HomeCountrySupportContactType.email:
        final uri = Uri.parse('mailto:${contact.value}');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      case HomeCountrySupportContactType.url:
        await _openUrl(contact.value);
      case HomeCountrySupportContactType.text:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = compact
        ? null
        : EosbStrings.t(resource.descriptionKey, locale);

    return Padding(
      padding: EdgeInsets.only(bottom: compact ? AppSpacing.xs : AppSpacing.sm),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? AppSpacing.xs : AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    EosbStrings.t(resource.titleKey, locale),
                    style: compact ? AppTypography.bodySmall : AppTypography.subtitle,
                  ),
                ),
                if (resource.needsVerification)
                  _VerifyBadge(locale: locale),
              ],
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(description, style: AppTypography.bodySmall),
            ],
            if (resource.url != null) ...[
              const SizedBox(height: AppSpacing.xs),
              InkWell(
                onTap: () => _openUrl(resource.url!),
                child: Text(
                  resource.url!,
                  style: AppTypography.link.copyWith(color: AppColors.info),
                ),
              ),
            ],
            if (resource.contacts.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              ...resource.contacts.map((contact) {
                final label = EosbStrings.t(contact.labelKey, locale);
                final value = contact.value.startsWith('eosb_')
                    ? EosbStrings.t(contact.value, locale)
                    : contact.value;
                final isActionable =
                    contact.type == HomeCountrySupportContactType.phone ||
                        contact.type == HomeCountrySupportContactType.email ||
                        contact.type == HomeCountrySupportContactType.url;

                return Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: isActionable
                      ? InkWell(
                          onTap: () => _openContact(contact),
                          child: Text(
                            '$label: $value',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.info,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      : Text(
                          '$label: $value',
                          style: AppTypography.bodySmall,
                        ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class VerifyBadge extends StatelessWidget {
  const VerifyBadge({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) => _VerifyBadge(locale: locale);
}

class _VerifyBadge extends StatelessWidget {
  const _VerifyBadge({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        EosbStrings.t('eosb_hcs_verify_badge', locale),
        style: AppTypography.caption.copyWith(
          color: AppColors.warning,
          fontSize: 10,
        ),
      ),
    );
  }
}
