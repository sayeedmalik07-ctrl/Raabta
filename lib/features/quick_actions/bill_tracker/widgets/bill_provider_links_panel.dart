import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/quick_actions/bill_tracker/data/qatar_bill_providers.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:url_launcher/url_launcher.dart';

class BillProviderLinksPanel extends StatelessWidget {
  const BillProviderLinksPanel({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final withUrls = QatarBillProviders.withPaymentUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          BillTrackerStrings.t('pay_directly_header', locale),
          style: TextStyle(
            color: AppColors.isLight ? AppColors.textPrimary : Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: withUrls.map((provider) {
            return GestureDetector(
              onTap: () async {
                final uri = Uri.parse(provider.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.isLight
                      ? AppColors.textPrimary.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.isLight
                        ? AppColors.glassBorder
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          provider.name,
                          style: TextStyle(
                            color: AppColors.isLight
                                ? AppColors.textOnGlassSecondary
                                : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          BillTrackerStrings.t('open_provider_site', locale),
                          style: TextStyle(
                            color: AppColors.isLight
                                ? AppColors.textOnGlassMuted
                                : Colors.white.withValues(alpha: 0.35),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.open_in_new_rounded,
                      color: AppColors.isLight
                          ? AppColors.textOnGlassMuted
                          : Colors.white.withValues(alpha: 0.25),
                      size: 11,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Text(
          BillTrackerStrings.t('payment_disclaimer', locale),
          style: TextStyle(
            color: AppColors.isLight
                ? AppColors.textOnGlassMuted
                : Colors.white.withValues(alpha: 0.25),
            fontSize: 10,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
