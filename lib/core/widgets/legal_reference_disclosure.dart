import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/config/truth_engine_source_metadata.dart';
import 'package:raabta/core/l10n/classifieds_compliance_strings.dart';
import 'package:raabta/core/l10n/legal_reference_strings.dart';
import 'package:raabta/core/widgets/truth_engine_source_line.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Which static source metadata block to show above the disclosure.
enum TruthEngineSourceKind {
  eosb,
  healthInsurance,
  tenancy,
  sponsorshipTransfer,
}

/// Collapsed-by-default legal/reference disclosure for Truth Engine surfaces.
class LegalReferenceDisclosure extends StatefulWidget {
  const LegalReferenceDisclosure({
    super.key,
    required this.locale,
    required this.citationPreview,
    required this.children,
    this.margin = const EdgeInsets.only(top: AppSpacing.sm),
    this.sourceKind,
    this.sourceLabel = '',
    this.lastVerifiedOn = '',
    this.officialUrl = '',
    this.showInformationOnlyLine = true,
  });

  final String locale;
  final String citationPreview;
  final List<Widget> children;
  final EdgeInsets margin;
  final TruthEngineSourceKind? sourceKind;
  final String sourceLabel;
  final String lastVerifiedOn;
  final String officialUrl;
  final bool showInformationOnlyLine;

  @override
  State<LegalReferenceDisclosure> createState() =>
      _LegalReferenceDisclosureState();
}

class _LegalReferenceDisclosureState extends State<LegalReferenceDisclosure> {
  bool _expanded = false;
  final _headerKey = GlobalKey();
  final _expandedContentKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureHeaderVisibleIfClipped();
    });
  }

  /// Brings the tappable header into the viewport when it would miss hit tests
  /// (e.g. bottom of a [SingleChildScrollView] on a short screen).
  void _ensureHeaderVisibleIfClipped() {
    if (!mounted) return;
    final target = _headerKey.currentContext;
    if (target == null) return;
    final box = target.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;

    final media = MediaQuery.maybeOf(context);
    if (media == null) return;
    final topLeft = box.localToGlobal(Offset.zero);
    final bottom = topLeft.dy + box.size.height;
    final viewportHeight = media.size.height;
    final clipped =
        topLeft.dy < media.padding.top || bottom > viewportHeight - media.padding.bottom;
    if (!clipped) return;

    Scrollable.ensureVisible(
      target,
      duration: Duration.zero,
      alignment: 1.0,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }

  ({String source, String verified, String url}) _resolvedSource() {
    if (widget.sourceLabel.isNotEmpty ||
        widget.lastVerifiedOn.isNotEmpty ||
        widget.officialUrl.isNotEmpty) {
      return (
        source: widget.sourceLabel,
        verified: widget.lastVerifiedOn,
        url: widget.officialUrl,
      );
    }
    return switch (widget.sourceKind) {
      TruthEngineSourceKind.eosb => (
          source: TruthEngineSourceMetadata.eosbSource,
          verified: TruthEngineSourceMetadata.eosbLastVerified,
          url: TruthEngineSourceMetadata.eosbOfficialUrl,
        ),
      TruthEngineSourceKind.healthInsurance => (
          source: TruthEngineSourceMetadata.healthInsuranceSource,
          verified: TruthEngineSourceMetadata.healthInsuranceLastVerified,
          url: TruthEngineSourceMetadata.healthInsuranceOfficialUrl,
        ),
      TruthEngineSourceKind.tenancy => (
          source: TruthEngineSourceMetadata.tenancySource,
          verified: TruthEngineSourceMetadata.tenancyLastVerified,
          url: TruthEngineSourceMetadata.tenancyOfficialUrl,
        ),
      TruthEngineSourceKind.sponsorshipTransfer => (
          source: TruthEngineSourceMetadata.sponsorshipTransferSource,
          verified: TruthEngineSourceMetadata.sponsorshipTransferLastVerified,
          url: TruthEngineSourceMetadata.sponsorshipTransferOfficialUrl,
        ),
      null => (source: '', verified: '', url: ''),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();

    final source = _resolvedSource();
    final locale = widget.locale;

    return Padding(
      padding: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TruthEngineSourceLine(
            locale: locale,
            sourceLabel: source.source,
            lastVerifiedOn: source.verified,
            officialUrl: source.url,
          ),
          if (widget.showInformationOnlyLine)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                ClassifiedsComplianceStrings.t('information_only_notice', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  height: 1.4,
                ),
              ),
            ),
          Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    key: _headerKey,
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _ensureHeaderVisibleIfClipped();
                      setState(() => _expanded = !_expanded);
                      if (_expanded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          final target = _expandedContentKey.currentContext;
                          if (target != null) {
                            Scrollable.ensureVisible(
                              target,
                              alignment: 0,
                              duration: Duration.zero,
                            );
                          }
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 18,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LegalReferenceStrings.t(
                                    'legal_reference_title',
                                    locale,
                                  ),
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (widget.citationPreview.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    widget.citationPreview,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  LegalReferenceStrings.t(
                                    'legal_reference_view_basis',
                                    locale,
                                  ),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.cyanGlow,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _expanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_expanded)
                    Padding(
                      key: _expandedContentKey,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widget.children,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
