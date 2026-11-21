import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/daily_utilities/l10n/daily_utilities_strings.dart';
import 'package:raabta/features/daily_utilities/ussd/qatar_ussd_codes.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class UssdCodesScreen extends ConsumerStatefulWidget {
  const UssdCodesScreen({super.key});

  @override
  ConsumerState<UssdCodesScreen> createState() => _UssdCodesScreenState();
}

class _UssdCodesScreenState extends ConsumerState<UssdCodesScreen> {
  QatarTelecomOperator _operator = QatarTelecomOperator.ooredoo;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _copyCode(String code, String locale) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(DailyUtilitiesStrings.t('copied', locale))),
      );
    }
  }

  Future<void> _dialCode(String code) async {
    final uri = Uri.parse(ussdToTelUri(code));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final filtered = ussdForOperator(_operator).where((e) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return e.label.toLowerCase().contains(q) ||
          e.code.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q) ||
          e.category.label.toLowerCase().contains(q);
    }).toList();

    final grouped = <UssdCategory, List<UssdCodeEntry>>{};
    for (final entry in filtered) {
      grouped.putIfAbsent(entry.category, () => []).add(entry);
    }

    return GlassScreenScaffold(
      title: DailyUtilitiesStrings.t('ussd_title', locale),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, 8),
            child: Text(
              DailyUtilitiesStrings.t('ussd_subtitle', locale),
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim()),
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
              ),
              decoration: InputDecoration(
                hintText: DailyUtilitiesStrings.t('search_hint', locale),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.isLight
                    ? AppColors.glassSurface
                    : Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _OpChip(
                  label: 'Ooredoo',
                  selected: _operator == QatarTelecomOperator.ooredoo,
                  color: AppColors.sharePurple,
                  onTap: () => setState(
                    () => _operator = QatarTelecomOperator.ooredoo,
                  ),
                ),
                const SizedBox(width: 8),
                _OpChip(
                  label: 'Vodafone',
                  selected: _operator == QatarTelecomOperator.vodafone,
                  color: AppColors.errorBright,
                  onTap: () => setState(
                    () => _operator = QatarTelecomOperator.vodafone,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                for (final cat in grouped.keys)
                  ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: Text(
                        cat.label,
                        style: AppTypography.title.copyWith(fontSize: 14),
                      ),
                    ),
                    ...grouped[cat]!.map(
                      (entry) => _UssdRow(
                        entry: entry,
                        locale: locale,
                        onCopy: () => _copyCode(entry.code, locale),
                        onDial: () => _dialCode(entry.code),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpChip extends StatelessWidget {
  const _OpChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.25)
                : (AppColors.isLight
                    ? AppColors.glassSurface
                    : Colors.white10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? color
                  : (AppColors.isLight
                      ? AppColors.glassBorder
                      : Colors.white24),
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UssdRow extends StatelessWidget {
  const _UssdRow({
    required this.entry,
    required this.locale,
    required this.onCopy,
    required this.onDial,
  });

  final UssdCodeEntry entry;
  final String locale;
  final VoidCallback onCopy;
  final VoidCallback onDial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.label, style: AppTypography.title.copyWith(fontSize: 15)),
            if (entry.planNote != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  entry.planNote!,
                  style: AppTypography.caption.copyWith(color: AppColors.accentGold),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              entry.code,
              style: AppTypography.headline2.copyWith(
                fontSize: 22,
                color: AppColors.cyanGlow,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.description,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text(DailyUtilitiesStrings.t('copy', locale)),
                ),
                TextButton.icon(
                  onPressed: onDial,
                  icon: const Icon(Icons.phone, size: 16),
                  label: Text(DailyUtilitiesStrings.t('dial', locale)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
