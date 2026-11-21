import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/background/animated_aurora_background.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/features/home/screens/home_screen.dart';
import 'package:raabta/features/home/widgets/home_all_services_grouped_list.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_page_grain_layer.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Full catalogue of classifieds hubs + Money (Documents lives in shell nav).
///
/// Nested under `/home/*` (pushed route) — bottom nav stays on [HomeScreen] only.
class HomeAllServicesScreen extends ConsumerWidget {
  const HomeAllServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnimatedAuroraBackground(
      enableAnimation: !reduceMotion,
      ignoreSafeArea: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(child: HomePageGrainLayer()),
            ),
            SafeArea(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HomeZoneSpacing.sectionHorizontalPadding,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: HubLandingHeader(
                        title: AppShellStrings.t('home_all_services_title', locale),
                        subtitle: AppShellStrings.t('home_explore_sub', locale),
                        showBack: true,
                        onBack: () => context.pop(),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      HomeZoneSpacing.sectionHorizontalPadding,
                      HomeZoneSpacing.afterSectionHeader,
                      HomeZoneSpacing.sectionHorizontalPadding,
                      HomeScreen.shellBodyBottomClearance() +
                          bottomInset +
                          HomeScreen.homeFeedBottomClearanceExtra,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: HomeAllServicesGroupedList(
                        locale: locale,
                        onOpenRoute: (route) => context.push(route),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}