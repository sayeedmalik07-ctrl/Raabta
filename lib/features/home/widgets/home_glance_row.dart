import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/utils/home_glance_layout_policy.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_prayer_strip.dart';
import 'package:raabta/features/home/widgets/home_scam_shield_anchor_card.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_schedule_providers.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';

/// Home glance block — Prayer + ScamShield with elevated alert precedence.
class HomeGlanceRow extends ConsumerWidget {
  const HomeGlanceRow({super.key});

  static EdgeInsets get _elevatedBlockPadding => const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.md,
      );

  static EdgeInsets get _calmRowPadding => const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.md,
      );

  static EdgeInsets get _calmStackPadding => const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scamElevated = ref.watch(scamShieldActiveAlertProvider).maybeWhen(
          data: (state) => state.isElevated,
          orElse: () => false,
        );

    if (scamElevated) {
      return Padding(
        padding: _elevatedBlockPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HomeScamShieldAnchorCard(),
            const SizedBox(height: AppSpacing.xs),
            const HomePrayerStrip(outerPadding: false),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final locale = _resolveLocale(ref);
        final prayerPreview = _prayerPreviewLine(ref, locale);
        final scamLine =
            AppShellStrings.t('home_scam_shield_status_calm', locale);
        final textDirection = Directionality.of(context);
        final sideBySide = HomeGlanceLayoutPolicy.prefersSideBySide(
          maxWidth: constraints.maxWidth,
          textScaler: MediaQuery.textScalerOf(context),
          prayerPrimaryLine: prayerPreview,
          scamCalmLine: scamLine,
          textDirection: textDirection,
        );

        if (sideBySide) {
          return Padding(
            padding: _calmRowPadding,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: HomePrayerStrip(
                      compact: true,
                      outerPadding: false,
                    ),
                  ),
                  const SizedBox(width: HomeCardTier.glanceTileGap),
                  const Expanded(
                    child: HomeScamShieldAnchorCard(compact: true),
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: _calmStackPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomePrayerStrip(compact: true, outerPadding: false),
              const SizedBox(height: AppSpacing.xs),
              const HomeScamShieldAnchorCard(compact: true),
            ],
          ),
        );
      },
    );
  }

  String _resolveLocale(WidgetRef ref) {
    final appLocale = ref.watch(appLocaleProvider);
    final strip = ref.watch(prayerScheduleStripProvider);
    return AppLocale.normalize(
      strip.settings.locale.isNotEmpty ? strip.settings.locale : appLocale,
    );
  }

  String _prayerPreviewLine(WidgetRef ref, String locale) {
    final strip = ref.watch(prayerScheduleStripProvider);
    if (strip.isLoading) {
      return '—';
    }
    final schedule = strip.schedule;
    if (schedule == null) {
      return '—';
    }
    final now = ref.watch(prayerLiveClockProvider);
    final next = schedule.nextPrayerAt(now);
    final remaining = schedule.timeUntilNextAt(now);
    return HomePrayerStrip.nextCountdownLine(
      locale: locale,
      next: next,
      remaining: remaining,
    );
  }
}
