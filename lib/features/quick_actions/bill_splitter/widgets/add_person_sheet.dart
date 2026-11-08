import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/features/quick_actions/bill_splitter/data/bill_splitter_currencies.dart';
import 'package:raabta/features/quick_actions/bill_splitter/l10n/bill_splitter_strings.dart';
import 'package:raabta/features/quick_actions/bill_splitter/models/split_person.dart';

Future<SplitPerson?> showAddPersonSheet(
  BuildContext context, {
  required String locale,
  String defaultCurrency = 'INR',
}) {
  final nameController = TextEditingController();
  var pickedCurrency = defaultCurrency;

  return showModalBottomSheet<SplitPerson>(
    context: context,
    backgroundColor: AppColors.surfaceElevated,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.isLight
                      ? AppColors.glassBorder
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              BillSplitterStrings.t('add_person_title', locale),
              style: AppTypography.headline2.copyWith(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            GlassTextField(
              controller: nameController,
              autofocus: true,
              hint: BillSplitterStrings.t('name_hint', locale),
            ),
            const SizedBox(height: 14),
            Text(
              BillSplitterStrings.t('home_currency', locale),
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textOnGlassSecondary
                    : Colors.white.withValues(alpha: 0.54),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.isLight
                    ? AppColors.glassSurface
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: BillSplitterCurrencies.codes.contains(pickedCurrency)
                      ? pickedCurrency
                      : BillSplitterCurrencies.codes.first,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceElevated,
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                    fontSize: 14,
                  ),
                  items: BillSplitterCurrencies.codes
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            '${BillSplitterCurrencies.flagFor(c)} $c  —  ${BillSplitterCurrencies.symbolFor(c)}',
                            style: TextStyle(
                              color: AppColors.isLight
                                  ? AppColors.textPrimary
                                  : Colors.white,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setSheet(() => pickedCurrency = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            GlassPrimaryButton(
              label: BillSplitterStrings.t('add_to_bill', locale),
              expand: true,
              accentColor: AppColors.accentGold,
              icon: Icons.person_add_rounded,
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(
                  ctx,
                  SplitPerson(
                    name: name,
                    currency: pickedCurrency,
                    flag: BillSplitterCurrencies.flagFor(pickedCurrency),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
