import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';

class ScamShieldSenderChips extends StatelessWidget {
  const ScamShieldSenderChips({
    super.key,
    required this.locale,
    required this.selected,
    required this.onSelected,
  });

  final String locale;
  final ScamMessageSenderType selected;
  final ValueChanged<ScamMessageSenderType> onSelected;

  @override
  Widget build(BuildContext context) {
    return ScamShieldOptionChips<ScamMessageSenderType>(
      options: ScamMessageSenderType.values.toList(),
      selected: selected,
      labelFor: (t) => ScamShieldStrings.t(t.labelKey, locale),
      onSelected: onSelected,
    );
  }
}

class ScamShieldSenderRow extends StatelessWidget {
  const ScamShieldSenderRow({
    super.key,
    required this.locale,
    required this.selected,
    required this.onSelected,
  });

  final String locale;
  final ScamMessageSenderType selected;
  final ValueChanged<ScamMessageSenderType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ScamShieldStrings.t('ss_sender_who_heading', locale),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          ScamShieldStrings.t('ss_sender_who_sub', locale),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        ScamShieldSenderChips(
          locale: locale,
          selected: selected,
          onSelected: onSelected,
        ),
      ],
    );
  }
}
