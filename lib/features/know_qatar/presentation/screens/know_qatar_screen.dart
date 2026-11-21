import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/know_qatar/data/know_qatar_moments_config.dart';
import 'package:raabta/features/know_qatar/data/know_qatar_moments_prefs.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_moment_models.dart';
import 'package:raabta/features/know_qatar/domain/services/know_qatar_moments_service.dart';
import 'package:raabta/features/know_qatar/domain/services/next_step_resolver.dart';
import 'package:raabta/features/know_qatar/presentation/l10n/know_qatar_strings.dart';
import 'package:raabta/features/know_qatar/presentation/widgets/know_qatar_moment_item_tile.dart';
import 'package:raabta/features/know_qatar/presentation/widgets/know_qatar_moments_chip_row.dart';
import 'package:raabta/features/know_qatar/presentation/widgets/know_qatar_next_step_card.dart';
import 'package:raabta/features/know_qatar/presentation/widgets/know_qatar_persona_banner.dart';
import 'package:raabta/features/know_qatar/presentation/widgets/know_qatar_section_card.dart';
import 'package:raabta/features/know_qatar/providers/know_qatar_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class KnowQatarScreen extends ConsumerStatefulWidget {
  const KnowQatarScreen({
    super.key,
    this.initialSectionKey,
    this.initialMomentId,
  });

  final String? initialSectionKey;

  /// Optional lens override (e.g. tests or deep links) — not persisted.
  final KnowQatarMomentId? initialMomentId;

  static String route({String? sectionKey}) {
    final key = sectionKey?.trim();
    if (key == null || key.isEmpty) return '/know-qatar';
    return '/know-qatar?section=${Uri.encodeComponent(key)}';
  }

  @override
  ConsumerState<KnowQatarScreen> createState() => _KnowQatarScreenState();
}

class _KnowQatarScreenState extends ConsumerState<KnowQatarScreen> {
  final Set<String> _expanded = {};
  KnowQatarMomentsPrefs? _prefs;
  int? _nextStepHiddenUntilMs;
  KnowQatarMomentId? _selectedMoment;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSectionKey?.trim();
    if (initial != null && initial.isNotEmpty) {
      _expanded.add(initial);
    }
    _selectedMoment = widget.initialMomentId;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await KnowQatarMomentsPrefs.load();
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _nextStepHiddenUntilMs = prefs.readNextStepHiddenUntilMs();
      _prefsLoaded = true;
    });
  }

  Future<void> _recordOpened(String destinationKey) async {
    await _prefs?.recordLastOpened(destinationKey);
  }

  Future<void> _dismissNextStep() async {
    final until = DateTime.now().millisecondsSinceEpoch +
        const Duration(days: NextStepResolver.dismissDurationDays).inMilliseconds;
    await _prefs?.hideNextStepUntil(until);
    if (!mounted) return;
    setState(() => _nextStepHiddenUntilMs = until);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final initial = widget.initialSectionKey?.trim();
    if (initial == null || initial.isEmpty) return;
    final visible = ref.read(knowQatarVisibleSectionKeysProvider);
    if (!visible.contains(initial) && _expanded.remove(initial)) {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final sections = ref.watch(knowQatarSectionsProvider);
    final persona = ref.watch(knowQatarPersonaProvider);
    final visibleKeys = ref.watch(knowQatarVisibleSectionKeysProvider);
    final deadlines = ref.watch(documentDeadlinesProvider).valueOrNull ?? const [];

    final defaultMoment = KnowQatarMomentsService.defaultMomentForPersona(persona);
    final selectedMoment =
        _selectedMoment ?? widget.initialMomentId ?? defaultMoment;
    final chipOrder = KnowQatarMomentsService.chipOrder(defaultMoment);

    final nextStep = _prefsLoaded
        ? NextStepResolver.resolve(
            deadlines: deadlines,
            persona: persona,
            activeMomentId: selectedMoment,
            publishedSectionKeys: visibleKeys,
            lastOpenedDestinationKey: _prefs?.readLastOpenedDestinationKey(),
            nextStepHiddenUntilMs: _nextStepHiddenUntilMs,
            nowMs: DateTime.now().millisecondsSinceEpoch,
          )
        : null;

    final momentDef = KnowQatarMomentsConfig.definitionFor(selectedMoment);
    final momentItems = selectedMoment == KnowQatarMomentId.allTopics
        ? const <KnowQatarMomentResolvedItem>[]
        : KnowQatarMomentsService.resolveMomentItems(
            momentId: selectedMoment,
            publishedSectionKeys: visibleKeys,
          );

    return GlassScreenScaffold(
      enableBackgroundAnimation: false,
      title: KnowQatarStrings.t('kq_screen_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.cyanGlow,
            glowIntensity: 0.14,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.cyanGlow.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.cyanGlow.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.cyanGlow,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    KnowQatarStrings.t('kq_screen_intro', locale),
                    style: AppTypography.bodySmall.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          KnowQatarMomentsChipRow(
            locale: locale,
            selected: selectedMoment,
            chipOrder: chipOrder,
            onSelected: (id) => setState(() => _selectedMoment = id),
          ),
          if (nextStep != null) ...[
            const SizedBox(height: AppSpacing.md),
            KnowQatarNextStepCard(
              locale: locale,
              step: nextStep,
              deadlineExpiryLabel:
                  nextStepDeadlineExpiryLabel(nextStep, deadlines),
              onDismiss: _dismissNextStep,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          KnowQatarPersonaBanner(persona: persona, locale: locale),
          const SizedBox(height: AppSpacing.lg),
          if (selectedMoment != KnowQatarMomentId.allTopics &&
              momentDef != null) ...[
            Text(
              KnowQatarStrings.t(momentDef.introKey, locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...momentItems.map(
              (item) => KnowQatarMomentItemTile(
                item: item,
                locale: locale,
                onOpened: () => _recordOpened(item.destinationKey),
              ),
            ),
            if (selectedMoment == KnowQatarMomentId.hostingVisitors) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                KnowQatarStrings.t('kq_moment_official_needs_internet', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
          ...sections.map(
            (section) => KnowQatarSectionCard(
              section: section,
              locale: locale,
              expanded: _expanded.contains(section.sectionKey),
              onExpansionChanged: (open) {
                setState(() {
                  if (open) {
                    _expanded.add(section.sectionKey);
                    _recordOpened(
                      KnowQatarMomentsService.destinationKeyForSection(
                        section.sectionKey,
                      ),
                    );
                  } else {
                    _expanded.remove(section.sectionKey);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
