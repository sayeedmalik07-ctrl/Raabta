import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/screens/services/widgets/service_hub_subscreen_scaffold.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/services/l10n/service_quote_strings.dart';
import 'package:raabta/screens/services/providers/service_quote_providers.dart';
import 'package:raabta/screens/services/widgets/service_hub_quote_skin.dart';
import 'package:raabta/core/colors/app_colors.dart';

class ServiceSubmitQuoteScreen extends ConsumerStatefulWidget {
  const ServiceSubmitQuoteScreen({
    super.key,
    required this.requestListingId,
    required this.customerId,
    required this.requestTitle,
  });

  final String requestListingId;
  final String customerId;
  final String requestTitle;

  @override
  ConsumerState<ServiceSubmitQuoteScreen> createState() =>
      _ServiceSubmitQuoteScreenState();
}

class _ServiceSubmitQuoteScreenState
    extends ConsumerState<ServiceSubmitQuoteScreen> {
  final _priceController = TextEditingController();
  final _includedController = TextEditingController();
  final _caveatController = TextEditingController();
  String? _errorKey;
  bool _busy = false;

  @override
  void dispose() {
    _priceController.dispose();
    _includedController.dispose();
    _caveatController.dispose();
    super.dispose();
  }

  Future<void> _submit(String locale) async {
    final price =
        double.tryParse(_priceController.text.replaceAll(',', '').trim());
    final included = _includedController.text.trim();
    if (price == null || price <= 0) {
      setState(() => _errorKey = 'svc_quote_invalid_price');
      return;
    }
    if (included.isEmpty) {
      setState(() => _errorKey = 'svc_quote_invalid_included');
      return;
    }

    setState(() {
      _busy = true;
      _errorKey = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    final providerName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Provider';

    final quote = await ref.read(serviceQuoteRepositoryProvider).submitQuote(
          requestListingId: widget.requestListingId,
          customerId: widget.customerId,
          requestTitle: widget.requestTitle,
          price: price,
          includedDescription: included,
          priceChangeNote: _caveatController.text.trim().isEmpty
              ? null
              : _caveatController.text.trim(),
          providerName: providerName,
          locale: locale,
        );

    if (!mounted) return;
    setState(() => _busy = false);

    if (quote == null) {
      setState(() => _errorKey = 'svc_quote_invalid_price');
      return;
    }

    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    return ServiceHubSubscreenScaffold(
      title: ServiceQuoteStrings.t('svc_submit_quote_title', locale),
      subtitle: widget.requestTitle,
      onBack: () => context.pop(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HubNoticeBanner.hostNotice(locale: locale),
            const SizedBox(height: AppSpacing.sm),
            HubNoticeBanner(
              text: ServiceQuoteStrings.t('svc_submit_quote_subtitle', locale),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ServiceQuoteStrings.t('svc_quote_price_label', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              decoration: serviceHubQuoteFieldDecoration(hintText: '0'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ServiceQuoteStrings.t('svc_quote_included_label', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _includedController,
              maxLines: 3,
              maxLength: 500,
              decoration: serviceHubQuoteFieldDecoration(
                hintText:
                    ServiceQuoteStrings.t('svc_quote_included_hint', locale),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ServiceQuoteStrings.t('svc_quote_caveat_label', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _caveatController,
              maxLines: 2,
              maxLength: 300,
              decoration: serviceHubQuoteFieldDecoration(
                hintText:
                    ServiceQuoteStrings.t('svc_quote_caveat_hint', locale),
              ),
            ),
            if (_errorKey != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                ServiceQuoteStrings.t(_errorKey!, locale),
                style: AppTypography.caption.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _busy ? null : () => _submit(locale),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandFamilyMain,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(ServiceQuoteStrings.t('svc_submit_quote', locale)),
            ),
          ],
        ),
      ),
    );
  }
}
