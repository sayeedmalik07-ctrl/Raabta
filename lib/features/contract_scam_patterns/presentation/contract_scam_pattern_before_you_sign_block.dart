import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/contract_scam_patterns/contract_scam_pattern_engine.dart';
import 'package:raabta/features/contract_scam_patterns/contract_scam_pattern_models.dart';
import 'package:raabta/features/contract_scam_patterns/l10n/contract_scam_pattern_strings.dart';
import 'package:raabta/features/contract_scam_patterns/presentation/contract_scam_pattern_checks_section.dart';

/// Optional offer/contract paste + local scam-pattern checks (Before You Sign).
class ContractScamPatternBeforeYouSignBlock extends StatefulWidget {
  const ContractScamPatternBeforeYouSignBlock({
    super.key,
    required this.locale,
  });

  final String locale;

  @override
  State<ContractScamPatternBeforeYouSignBlock> createState() =>
      _ContractScamPatternBeforeYouSignBlockState();
}

class _ContractScamPatternBeforeYouSignBlockState
    extends State<ContractScamPatternBeforeYouSignBlock> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final text = _controller.text;
    final result = text.trim().length >= 20
        ? ContractScamPatternEngine.scan(
            text: text,
            domain: ContractScamPatternDomain.employment,
          )
        : ContractScamPatternResult.empty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ContractScamPatternStrings.t('cop_bys_paste_label', locale),
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _controller,
          maxLines: 4,
          style: AppTypography.bodySmall,
          decoration: InputDecoration(
            hintText: ContractScamPatternStrings.t('cop_bys_paste_hint', locale),
            filled: true,
            fillColor: AppColors.glassSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: BorderSide(color: AppColors.glassBorder),
            ),
          ),
        ),
        if (result.scannedCharacterCount >= 20) ...[
          const SizedBox(height: AppSpacing.md),
          ContractScamPatternChecksSection(
            locale: locale,
            result: result,
            compact: true,
          ),
        ],
      ],
    );
  }
}
