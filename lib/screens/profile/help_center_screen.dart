import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/data/help_center_content.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/screens/profile/profile_tab_scaffold.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<HelpFaqCategory> _filtered(String locale) {
    final q = _query.trim().toLowerCase();
    final all = HelpCenterContent.categoriesFor(locale);
    if (q.isEmpty) return all;

    return all
        .map((cat) {
          final items = cat.items.where((item) {
            return item.question.toLowerCase().contains(q) ||
                item.answer.toLowerCase().contains(q) ||
                cat.title.toLowerCase().contains(q);
          }).toList();
          if (items.isEmpty) return null;
          return HelpFaqCategory(
            id: cat.id,
            title: cat.title,
            icon: cat.icon,
            items: items,
          );
        })
        .whereType<HelpFaqCategory>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final categories = _filtered(locale);

    return ProfileTabScaffold(
      child: GlassScreenScaffold(
        title: ProfileStrings.t('settings_help_center', locale),
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios_rounded,
          tooltip: CommonActionStrings.t('action_back', locale),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: ListView(
          children: [
            Text(
              ProfileStrings.t('help_center_intro', locale),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: AppTypography.subtitle,
              decoration: InputDecoration(
                hintText: ProfileStrings.t('help_search_hint', locale),
                hintStyle: AppTypography.bodySmall,
                prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surface.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (categories.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  ProfileStrings.format(
                    'help_no_results',
                    locale,
                    params: {'query': _query},
                  ),
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...categories.map(
                (cat) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _CategorySection(category: cat, locale: locale),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.locale});

  final HelpFaqCategory category;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: AppSpacing.radiusMd,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          leading: Text(category.icon, style: const TextStyle(fontSize: 22)),
          title: Text(category.title, style: AppTypography.subtitle),
          subtitle: Text(
            ProfileStrings.format(
              'help_articles_count',
              locale,
              params: {'count': '${category.items.length}'},
            ),
            style: AppTypography.caption,
          ),
          children: category.items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.question, style: AppTypography.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text(item.answer, style: AppTypography.body),
                      if (item != category.items.last)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Divider(color: AppColors.glassBorder),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
