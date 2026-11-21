import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/classifieds_compliance_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/hub/hub_advanced_filter_toggle.dart';
import 'package:raabta/core/widgets/hub/hub_business_card.dart';
import 'package:raabta/core/widgets/hub/hub_detail_action_bar.dart';
import 'package:raabta/core/widgets/hub/hub_feed_footer_notice.dart';
import 'package:raabta/core/widgets/hub/hub_deadline_urgency_row.dart';
import 'package:raabta/core/widgets/hub/hub_filter_chip.dart';
import 'package:raabta/core/widgets/hub/hub_guide_card.dart';
import 'package:raabta/core/widgets/hub/hub_job_card.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/core/widgets/hub/money_tool_screen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_layout_tokens.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_post_fab.dart';
import 'package:raabta/core/widgets/hub/hub_quick_action_tile.dart';
import 'package:raabta/core/widgets/hub/hub_service_card.dart';
import 'package:raabta/core/widgets/hub/hub_content_trust_tier_badge.dart';
import 'package:raabta/core/widgets/hub/hub_post_card.dart';
import 'package:raabta/core/widgets/hub/hub_community_moderation_notice.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/core/widgets/hub/hub_source_tier_badge.dart';
import 'package:raabta/core/widgets/hub/hub_summary_strip_card.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';
import 'package:raabta/core/widgets/hub/hub_landing_header.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/money/widgets/money_hub_primitives.dart';
import 'package:raabta/screens/money/widgets/money_hub_tools_grid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hub filter chip', () {
    testWidgets('selected chip uses brand family text color at rest', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildHubFilterChip(
              label: const Text('Sector'),
              selected: true,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, isTrue);
      expect(chip.labelStyle?.color, AppColors.brandFamilyText);

      final box = tester.getSize(find.byType(FilterChip));
      expect(box.height, lessThanOrEqualTo(HubLayoutTokens.filterChipHeight));
    });

    testWidgets('chip row enforces 36dp height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildHubFilterChip(
              label: const Text('Rent'),
              selected: false,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(FilterChip),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.height, HubLayoutTokens.filterChipHeight);
    });

    testWidgets('selection updates immediately when reduce-motion is on', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      var selected = false;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return buildHubFilterChip(
                    label: const Text('Zone'),
                    selected: selected,
                    onSelected: (value) => setState(() => selected = value),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(FilterChip));
      await tester.pump();
      expect(selected, isTrue);

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.labelStyle?.color, AppColors.brandFamilyText);
    });
  });

  group('Hub summary strip card', () {
    testWidgets('fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubSummaryStripCard(
              value: '4',
              label: 'Saved searches',
              icon: Icons.search,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Saved searches'));
      expect(tapped, isTrue);
    });
  });

  group('Hub quick action tile', () {
    testWidgets('label uses FittedBox for long copy', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubQuickActionTile(
              icon: Icons.balance,
              label: 'Rent and tenancy rights',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(FittedBox), findsOneWidget);
    });
  });

  group('HubSourceTierBadge', () {
    testWidgets('matches TrustBadge dimensions and type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HubSourceTierBadge(
              label: 'Verified employer',
              tier: HubJobSourceTier.verifiedEmployer,
            ),
          ),
        ),
      );

      final box = tester.getSize(find.byType(HubSourceTierBadge));
      expect(box.height, HubLayoutTokens.trustBadgeHeight);

      final decoration = tester.widget<DecoratedBox>(
        find.ancestor(
          of: find.text('Verified employer'),
          matching: find.byType(DecoratedBox),
        ).first,
      );
      final radius = decoration.decoration as BoxDecoration;
      expect(
        radius.borderRadius,
        BorderRadius.circular(HubLayoutTokens.trustBadgeRadius),
      );

      final text = tester.widget<Text>(find.text('Verified employer'));
      expect(text.style?.fontSize, HubLayoutTokens.trustBadgeFontSize);
      expect(text.style?.fontWeight, FontWeight.w700);
    });
  });

  group('HubJobCard kit anatomy', () {
    testWidgets('leading tile is 40px and hides empty salary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubJobCard(
              title: 'HSE Officer',
              employerLine: 'QatarEnergy LNG · Ras Laffan',
              freshnessLine: 'Posted 2 days ago',
              leadingInitial: 'Q',
              sourceTierBadge: (
                label: 'Verified employer',
                tier: HubJobSourceTier.verifiedEmployer,
              ),
            ),
          ),
        ),
      );

      expect(find.text('12,000 QAR'), findsNothing);

      final leading = tester.getSize(
        find.byWidgetPredicate(
          (w) =>
              w is SizedBox &&
              w.width == HubLayoutTokens.jobCardLeadingSize &&
              w.height == HubLayoutTokens.jobCardLeadingSize,
        ),
      );
      expect(leading.width, HubLayoutTokens.jobCardLeadingSize);
      expect(HubLayoutTokens.jobCardLeadingSize, 40);
    });

    testWidgets('shows salary when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubJobCard(
              title: 'Driver',
              employerLine: 'Acme · Doha',
              freshnessLine: 'Posted today',
              salaryLine: '3,500 QAR',
              leadingInitial: 'A',
            ),
          ),
        ),
      );

      expect(find.text('3,500 QAR'), findsOneWidget);
    });
  });

  group('HubFeedFooterNotice', () {
    testWidgets('uses NoticeBanner decoration and typography', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HubFeedFooterNotice(locale: 'English'),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(HubFeedFooterNotice),
          matching: find.byType(Text),
        ),
      );
      expect(text.style?.fontSize, HubTypography.noticeBannerBody.fontSize);

      final decoration = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(HubFeedFooterNotice),
          matching: find.byType(DecoratedBox),
        ),
      );
      final box = decoration.decoration as BoxDecoration;
      expect(
        box.borderRadius,
        BorderRadius.circular(HubLayoutTokens.noticeBannerRadius),
      );
    });

    testWidgets('announces notice once while keeping visible text', (tester) async {
      const locale = 'English';
      final notice = ClassifiedsComplianceStrings.t('host_notice', locale);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubFeedFooterNotice(locale: locale),
          ),
        ),
      );

      expect(find.text(notice), findsOneWidget);

      final semanticsHandle = tester.ensureSemantics();
      expect(find.bySemanticsLabel(notice), findsOneWidget);
      semanticsHandle.dispose();
    });

    testWidgets('outer padding uses directional insets in LTR and RTL',
        (tester) async {
      Future<void> pumpNotice(TextDirection direction) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Directionality(
              textDirection: direction,
              child: const Scaffold(
                body: HubFeedFooterNotice(locale: 'English'),
              ),
            ),
          ),
        );
      }

      Finder outerDirectionalPadding() {
        return find.descendant(
          of: find.byType(HubFeedFooterNotice),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Padding &&
                widget.padding is EdgeInsetsDirectional,
          ),
        );
      }

      await pumpNotice(TextDirection.ltr);
      var padding = tester.widget<Padding>(outerDirectionalPadding());
      var insets = padding.padding as EdgeInsetsDirectional;
      expect(insets.start, AppSpacing.xl);
      expect(insets.end, AppSpacing.xl);
      expect(insets.top, AppSpacing.lg);
      expect(insets.bottom, 100);

      await pumpNotice(TextDirection.rtl);
      padding = tester.widget<Padding>(outerDirectionalPadding());
      insets = padding.padding as EdgeInsetsDirectional;
      expect(insets.start, AppSpacing.xl);
      expect(insets.end, AppSpacing.xl);
      expect(insets.top, AppSpacing.lg);
      expect(insets.bottom, 100);
    });
  });

  group('HubAdvancedFilterToggle', () {
    testWidgets('exposes custom semanticsLabel as button', (tester) async {
      const label = 'Custom advanced filters';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubAdvancedFilterToggle(
              expanded: false,
              onToggle: () {},
              semanticsLabel: label,
            ),
          ),
        ),
      );

      final semanticsHandle = tester.ensureSemantics();
      expect(find.bySemanticsLabel(label), findsOneWidget);
      semanticsHandle.dispose();
    });
  });

  group('HubPostFab', () {
    testWidgets('is 56dp and uses onPrimary icon color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(onPrimary: Color(0xFFFAFAFA)),
          ),
          home: Scaffold(
            body: HubPostFab(
              onPressed: () {},
              tooltip: 'Post',
            ),
          ),
        ),
      );

      final fabBox = tester.getSize(find.byType(HubPostFab));
      expect(fabBox.width, HubLayoutTokens.postFabSize);
      expect(fabBox.height, HubLayoutTokens.postFabSize);

      final icon = tester.widget<Icon>(find.byIcon(Icons.add));
      expect(icon.color, const Color(0xFFFAFAFA));
    });
  });

  group('HubLoadingPlaceholder', () {
    testWidgets('formTool silhouette omits listing media block', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HubLoadingPlaceholder(
              width: 280,
              height: 160,
              silhouette: HubLoadingSilhouette.formTool,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(HubLoadingPlaceholder), findsOneWidget);
    });

    testWidgets('businessCard silhouette renders without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HubLoadingPlaceholder(
              width: 320,
              height: 120,
              silhouette: HubLoadingSilhouette.businessCard,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(HubLoadingPlaceholder), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('serviceCard silhouettes render without overflow', (tester) async {
      for (final silhouette in [
        HubLoadingSilhouette.serviceCard,
        HubLoadingSilhouette.serviceCardRequest,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HubLoadingPlaceholder(
                width: 320,
                height: 120,
                silhouette: silhouette,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('renders listing media silhouette', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HubLoadingPlaceholder(width: 280, height: 320),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(HubLoadingPlaceholder), findsOneWidget);
      expect(find.byType(ClipRRect), findsWidgets);
    });
  });

  group('HubServiceCard kit anatomy', () {
    testWidgets('provider avatar is 44dp and caps trust badges at three',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubServiceCard.provider(
              providerName: 'Fatima Al-Hajri',
              serviceTypeLine: 'Home cleaning · West Bay',
              rateLine: 'From QAR 80',
              avatarInitial: 'F',
              trustBadges: const [
                HubServiceTrustBadge(
                  label: 'ID verified',
                  tone: HubServiceTrustBadgeTone.verified,
                ),
                HubServiceTrustBadge(
                  label: 'Replies within 1h',
                  tone: HubServiceTrustBadgeTone.brand,
                ),
                HubServiceTrustBadge(
                  label: 'Extra',
                  tone: HubServiceTrustBadgeTone.neutral,
                ),
                HubServiceTrustBadge(
                  label: 'Hidden',
                  tone: HubServiceTrustBadgeTone.neutral,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('From QAR 80'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
      expect(find.text('ID verified'), findsOneWidget);

      final avatar = tester.getSize(
        find.byWidgetPredicate(
          (w) =>
              w is SizedBox &&
              w.width == HubLayoutTokens.serviceCardAvatarSize &&
              w.height == HubLayoutTokens.serviceCardAvatarSize,
        ),
      );
      expect(avatar.width, HubLayoutTokens.serviceCardAvatarSize);
    });

    testWidgets('request card shows open request badge and meta lines',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubServiceCard.request(
              requestTitle: 'Needs: AC repair this weekend',
              areaLine: 'Al Sadd',
              postedLine: 'Posted 2h ago',
              repliesLine: '3 replies',
              openRequestBadgeLabel: 'Open request',
            ),
          ),
        ),
      );

      expect(find.text('Needs: AC repair this weekend'), findsOneWidget);
      expect(find.text('Open request'), findsOneWidget);
      expect(find.text('Al Sadd'), findsOneWidget);
      expect(find.text('3 replies'), findsOneWidget);
    });
  });

  group('HubBusinessCard kit anatomy', () {
    testWidgets('logo tile is 48dp and caps service chips at three',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubBusinessCard(
              name: 'Al Khor Fresh Bakery',
              categoryLine: 'Food and bakery · Al Khor',
              openNow: true,
              closingTime: '11 PM',
              logoInitial: 'A',
              services: const [
                'Dine-in',
                'Takeaway',
                'Catering',
                'Delivery',
              ],
            ),
          ),
        ),
      );

      expect(find.text('Delivery'), findsNothing);
      expect(find.text('Dine-in'), findsOneWidget);
      expect(find.text('Open now • closes 11 PM'), findsOneWidget);

      final logo = tester.getSize(
        find.byWidgetPredicate(
          (w) =>
              w is SizedBox &&
              w.width == HubLayoutTokens.businessCardLogoSize &&
              w.height == HubLayoutTokens.businessCardLogoSize,
        ),
      );
      expect(logo.width, HubLayoutTokens.businessCardLogoSize);
    });
  });

  group('HubDetailActionBar', () {
    testWidgets('hides primary when label or callback is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubDetailActionBar(
              primaryLabel: 'Book an appointment',
              onPrimary: null,
              isSaved: false,
              onSave: () {},
              onShare: () {},
            ),
          ),
        ),
      );

      expect(find.text('Book an appointment'), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('shows primary and secondary for appointment flag layout',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubDetailActionBar(
              primaryLabel: 'Book an appointment',
              onPrimary: () {},
              secondaryLabel: 'Message',
              onSecondary: () {},
              isSaved: true,
              onSave: () {},
              onShare: () {},
            ),
          ),
        ),
      );

      expect(find.text('Book an appointment'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });

  group('HubGuideCard', () {
    testWidgets('shows title and optional law-updated badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 180,
                height: 220,
                child: HubGuideCard(
                  icon: Icons.menu_book_outlined,
                  title: 'Iqama renewal',
                  lawUpdatedLabel: 'Law updated 1 Jan 2026',
                  metaLine: '5 steps · 3–5 days',
                  layout: HubGuideCardLayout.compact,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Iqama renewal'), findsOneWidget);
      expect(find.text('Law updated 1 Jan 2026'), findsOneWidget);
      expect(find.text('5 steps · 3–5 days'), findsOneWidget);
    });
  });

  group('HubDeadlineUrgencyRow', () {
    testWidgets('maps critical tier to error bright rail color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HubDeadlineUrgencyRow(
              tier: HubDeadlineUrgencyTier.critical,
              title: 'Qatar ID',
              subtitle: '12 days left',
            ),
          ),
        ),
      );

      expect(
        hubDeadlineUrgencyColor(HubDeadlineUrgencyTier.critical),
        AppColors.errorBright,
      );
      expect(find.text('Qatar ID'), findsOneWidget);
      expect(find.text('12 days left'), findsOneWidget);
    });
  });

  group('MoneyToolScreenScaffold', () {
    testWidgets('customBody skips default scroll and shows TabBar child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MoneyToolScreenScaffold(
            title: 'Gold',
            subtitle: 'Spot and tools',
            onBack: () {},
            onRefresh: () async {},
            customBody: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'A'),
                      Tab(text: 'B'),
                    ],
                  ),
                  const Expanded(
                    child: TabBarView(
                      children: [
                        Center(child: Text('Pane A')),
                        Center(child: Text('Pane B')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Gold'), findsOneWidget);
      expect(find.text('Pane A'), findsOneWidget);
    });

    testWidgets('shows title and triggers refresh from trailing control', (tester) async {
      var refreshCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: MoneyToolScreenScaffold(
            title: 'Remittance Truth Engine',
            subtitle: 'Compare corridor costs.',
            onBack: () {},
            onRefresh: () async {
              refreshCount++;
            },
            children: const [
              SizedBox(height: 400, child: Text('Body')),
            ],
          ),
        ),
      );

      expect(find.text('Remittance Truth Engine'), findsOneWidget);
      expect(find.text('Compare corridor costs.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(refreshCount, 1);
    });
  });

  group('MoneyToolStatusRow', () {
    testWidgets('shows label and optional detail', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MoneyToolStatusRow(
              label: 'Indicative only',
              detail: 'Verify with your bank.',
            ),
          ),
        ),
      );

      expect(find.text('Indicative only'), findsOneWidget);
      expect(find.text('Verify with your bank.'), findsOneWidget);
    });
  });

  group('HubLandingHeader', () {
    testWidgets('showBack false omits back IconButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubLandingHeader(
              title: 'Money Hub',
              subtitle: 'Subtitle',
              onBack: () {},
              showBack: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.text('Money Hub'), findsOneWidget);
    });
  });

  group('MoneyHubShell', () {
    testWidgets('shows search field and tab labels', (tester) async {
      await tester.pumpWidget(
        _MoneyHubShellTestHarness(),
      );

      expect(find.text('Test Hub'), findsOneWidget);
      expect(find.text('Test subtitle'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
      expect(find.text('Tab A'), findsOneWidget);
      expect(find.text('Tab B'), findsOneWidget);
    });
  });

  group('MoneyHubToolsGrid', () {
    testWidgets('lays out seven compact tool tiles', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userLanguageProvider.overrideWith((ref) => 'English'),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: MoneyHubToolsGrid(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MoneyHubFeatureTile), findsNWidgets(7));
    });
  });

  group('HubNoticeBanner', () {
    testWidgets('hostNotice uses notice banner typography', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubNoticeBanner.hostNotice(locale: 'English'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontSize, HubTypography.noticeBannerBody.fontSize);
    });
  });

  group('Community hub Batch A primitives', () {
    test('communityHubAccent uses teal family token', () {
      expect(communityHubAccent, AppColors.tealFamilyMain);
    });

    testWidgets('HubContentTrustTierBadge official uses brand tint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HubContentTrustTierBadge(
              label: 'Official',
              tier: HubContentTrustTier.official,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Official'));
      expect(text.style?.color, AppColors.brandFamilyText);
    });

    testWidgets('HubPostCard shows trust tier and why link', (tester) async {
      var whyTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubPostCard(
              authorName: 'Nadia R.',
              authorInitial: 'N',
              sectionContextLine: 'Ask Qatar · 2h ago',
              trustTierBadge: (
                label: 'Community',
                tier: HubContentTrustTier.community,
              ),
              body: 'How do I renew my Iqama online?',
              metaLine: '5 answers · 1 accepted ✓',
              helperTemperatureLabel: 'Helper temperature high',
              whySeeingLabel: 'Why am I seeing this?',
              onWhySeeingTap: () => whyTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Nadia R.'), findsOneWidget);
      expect(find.text('Community'), findsOneWidget);
      expect(find.text('Helper temperature high'), findsOneWidget);
      await tester.tap(find.text('Why am I seeing this?'));
      expect(whyTapped, isTrue);
    });

    testWidgets('HubPostCard shows flag emoji in author avatar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HubPostCard(
              authorName: 'Indians in Qatar',
              authorInitial: '🇮🇳',
              body: 'Group preview',
            ),
          ),
        ),
      );

      expect(find.text('🇮🇳'), findsOneWidget);
      expect(find.text('I'), findsNothing);
    });

    testWidgets('HubLoadingPlaceholder postCard silhouette lays out', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HubLoadingPlaceholder(
              height: 140,
              width: 360,
              silhouette: HubLoadingSilhouette.postCard,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(HubLoadingPlaceholder), findsOneWidget);
    });

    testWidgets('HubCommunityModerationNotice shows inline action', (tester) async {
      var edited = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HubCommunityModerationNotice(
              message: 'Your post needs a change before it can be published.',
              actionLabel: 'Edit',
              onAction: () => edited = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Edit'));
      expect(edited, isTrue);
    });
  });
}

class _MoneyHubShellTestHarness extends StatefulWidget {
  @override
  State<_MoneyHubShellTestHarness> createState() =>
      _MoneyHubShellTestHarnessState();
}

class _MoneyHubShellTestHarnessState extends State<_MoneyHubShellTestHarness>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this);
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MoneyHubShell(
        shellTitle: 'Test Hub',
        shellSubtitle: 'Test subtitle',
        searchHint: 'Search',
        tabLabels: const ['Tab A', 'Tab B'],
        searchController: _searchController,
        tabController: _tabController,
        onRefresh: () async {},
        isRefreshing: false,
        body: const SizedBox.shrink(),
      ),
    );
  }
}
