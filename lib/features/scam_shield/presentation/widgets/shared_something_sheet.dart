import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_alert_state_repository.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_catalog.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_guidance_strings.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showSharedSomethingSheet(
  BuildContext context, {
  required String locale,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => SharedSomethingSheet(locale: locale),
  );
}

class SharedSomethingSheet extends StatelessWidget {
  const SharedSomethingSheet({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: FutureBuilder(
          future: _load(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    data.headline,
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final step in data.steps) ...[
                    Text('• $step', style: AppTypography.body),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  GlassPrimaryButton(
                    label: SecurityGuidanceStrings.t(
                      'ss_sec_shared_call_bank',
                      locale,
                    ),
                    expand: true,
                    onPressed: () => _callBank(context, data.bankLine),
                  ),
                  if (data.bankLine == null || data.bankLine!.isEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      SecurityGuidanceStrings.t(
                        'ss_sec_bank_line_missing',
                        locale,
                      ),
                      style: AppTypography.caption,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => context.push('/scam-shield/directory'),
                    child: Text(
                      SecurityGuidanceStrings.t(
                        'ss_sec_shared_links_directory',
                        locale,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/scam-shield/incident'),
                    child: Text(
                      SecurityGuidanceStrings.t(
                        'ss_sec_shared_links_incident',
                        locale,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/scam-shield/call-screening'),
                    child: Text(
                      SecurityGuidanceStrings.t(
                        'ss_sec_shared_links_call_help',
                        locale,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<_SharedCopy> _load() async {
    final shared = await SecurityGuidanceCatalog.loadSharedSomething();
    final repo = SecurityAlertStateRepository();
    final bankLine = await repo.read(
      SecurityAlertStateRepository.userBankFraudLineKey,
    );
    return _SharedCopy(
      headline: shared == null
          ? ''
          : SecurityGuidanceStrings.t(shared.headlineKey, locale),
      steps: [
        if (shared != null)
          for (final key in shared.stepKeys)
            SecurityGuidanceStrings.t(key, locale),
      ],
      bankLine: bankLine,
    );
  }

  Future<void> _callBank(BuildContext context, String? line) async {
    final trimmed = line?.trim() ?? '';
    if (trimmed.isEmpty) return;
    final uri = Uri.parse('tel:$trimmed');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _SharedCopy {
  const _SharedCopy({
    required this.headline,
    required this.steps,
    this.bankLine,
  });

  final String headline;
  final List<String> steps;
  final String? bankLine;
}
