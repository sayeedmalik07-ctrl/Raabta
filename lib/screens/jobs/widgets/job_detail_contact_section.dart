import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';

/// WhatsApp, email and call actions on job listing detail (native and aggregated).
class JobDetailContactSection extends StatelessWidget {
  const JobDetailContactSection({
    super.key,
    required this.job,
    required this.locale,
    required this.onOpenUrl,
    required this.whatsappMessage,
  });

  final JobListing job;
  final String locale;
  final Future<void> Function(String url) onOpenUrl;
  final String whatsappMessage;

  @override
  Widget build(BuildContext context) {
    final aggregated = !job.supportsApplicationTracking;
    final whatsappLabel = aggregated
        ? JobsStrings.t('jobs_contact_whatsapp', locale)
        : CommonActionStrings.t('action_whatsapp', locale);
    final emailLabel = aggregated
        ? JobsStrings.t('jobs_contact_email', locale)
        : JobsStrings.t('jobs_email', locale);
    final callLabel = aggregated
        ? JobsStrings.t('jobs_contact_call', locale)
        : CommonActionStrings.format(
            'action_call_contact',
            locale,
            params: {'contact': job.contact},
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (aggregated) ...[
          Text(
            JobsStrings.t('jobs_contact_section_heading', locale),
            style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            JobsStrings.t('jobs_contact_section_subtitle', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final phone =
                      job.contact.replaceAll(' ', '').replaceAll('-', '');
                  onOpenUrl(
                    'https://wa.me/${phone.replaceAll('+', '')}?text=${Uri.encodeComponent(whatsappMessage)}',
                  );
                },
                icon: const Icon(Icons.chat),
                label: Text(whatsappLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: job.email == null
                    ? null
                    : () => onOpenUrl('mailto:${job.email}'),
                icon: const Icon(Icons.email_outlined),
                label: Text(emailLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cyanGlow,
                  side: BorderSide(
                    color: AppColors.cyanGlow.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => onOpenUrl('tel:${job.contact}'),
            icon: const Icon(Icons.phone),
            label: Text(callLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.surfaceElevated),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
