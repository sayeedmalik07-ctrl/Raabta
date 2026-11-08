import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/business/presentation/l10n/business_quote_strings.dart';
import 'package:raabta/features/business/providers/business_structured_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class BusinessRequestQuoteScreen extends ConsumerStatefulWidget {
  const BusinessRequestQuoteScreen({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  final String businessId;
  final String businessName;

  @override
  ConsumerState<BusinessRequestQuoteScreen> createState() =>
      _BusinessRequestQuoteScreenState();
}

class _BusinessRequestQuoteScreenState
    extends ConsumerState<BusinessRequestQuoteScreen> {
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  String? _errorKey;
  bool _busy = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submit(String locale) async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      setState(() => _errorKey = 'biz_quote_invalid_description');
      return;
    }

    final budget = _budgetController.text.trim().isEmpty
        ? null
        : double.tryParse(_budgetController.text.replaceAll(',', '').trim());

    setState(() {
      _busy = true;
      _errorKey = null;
    });

    try {
      final request = await ref.read(businessQuoteRepositoryProvider).createRequest(
            businessId: widget.businessId,
            description: description,
            budgetQar: budget,
            businessName: widget.businessName,
            locale: locale,
          );

      if (!mounted) return;
      setState(() => _busy = false);

      if (request == null) {
        setState(() => _errorKey = 'biz_quote_open_exists');
        return;
      }
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _errorKey = 'biz_quote_open_exists';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: BusinessQuoteStrings.t('biz_quote_request_title', locale),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              BusinessQuoteStrings.t('biz_quote_request_subtitle', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: BusinessQuoteStrings.t(
                  'biz_quote_description_label',
                  locale,
                ),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(
                labelText:
                    BusinessQuoteStrings.t('biz_quote_budget_label', locale),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            if (_errorKey != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                BusinessQuoteStrings.t(_errorKey!, locale),
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],
            const Spacer(),
            GlassPrimaryButton(
              onPressed: _busy ? null : () => _submit(locale),
              label: BusinessQuoteStrings.t('biz_quote_submit', locale),
            ),
          ],
        ),
      ),
    );
  }
}
