import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_consent_screen.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_prefs.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_strings.dart';

/// Optional one-time-style nudge — "Not now" records decline (90-day cooldown).
class ScamAnonymousSignalConsentBanner extends StatefulWidget {
  const ScamAnonymousSignalConsentBanner({super.key, required this.locale});

  final String locale;

  @override
  State<ScamAnonymousSignalConsentBanner> createState() =>
      _ScamAnonymousSignalConsentBannerState();
}

class _ScamAnonymousSignalConsentBannerState
    extends State<ScamAnonymousSignalConsentBanner> {
  bool? _visible;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (await ScamAnonymousSignalPrefs.isOptedIn()) {
      if (mounted) setState(() => _visible = false);
      return;
    }
    final may = await ScamAnonymousSignalPrefs.mayShowConsentPrompt();
    if (mounted) setState(() => _visible = may);
  }

  @override
  Widget build(BuildContext context) {
    if (_visible != true) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: AppColors.surfaceElevated.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ScamAnonymousSignalStrings.t('ss_signal_nudge_title', widget.locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                ScamAnonymousSignalStrings.t('ss_signal_nudge_body', widget.locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => ScamAnonymousSignalConsentScreen(
                            locale: widget.locale,
                          ),
                        ),
                      );
                      await _refresh();
                    },
                    child: Text(
                      ScamAnonymousSignalStrings.t(
                        'ss_signal_nudge_learn',
                        widget.locale,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await ScamAnonymousSignalPrefs.recordDeclined();
                      await _refresh();
                    },
                    child: Text(
                      ScamAnonymousSignalStrings.t(
                        'ss_signal_consent_decline',
                        widget.locale,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
