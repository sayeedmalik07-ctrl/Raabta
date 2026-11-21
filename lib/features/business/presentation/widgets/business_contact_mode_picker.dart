import 'package:flutter/material.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';

class BusinessContactModePicker extends StatelessWidget {
  const BusinessContactModePicker({
    super.key,
    required this.locale,
    required this.value,
    required this.onChanged,
  });

  final String locale;
  final BusinessContactMode value;
  final ValueChanged<BusinessContactMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          BusinessesStrings.t('contact_mode_label', locale),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: 8),
        ...BusinessContactMode.values.map(
          (mode) => Material(
            color: Colors.transparent,
            child: RadioListTile<BusinessContactMode>(
              title: Text(_label(mode, locale)),
              subtitle: Text(
                _subtitle(mode, locale),
                style: AppTypography.caption,
              ),
              value: mode,
              groupValue: value,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  static String _label(BusinessContactMode mode, String locale) {
    return switch (mode) {
      BusinessContactMode.messageOnly =>
        BusinessesStrings.t('contact_mode_message_only', locale),
      BusinessContactMode.appointment =>
        BusinessesStrings.t('contact_mode_appointment', locale),
      BusinessContactMode.quote => BusinessesStrings.t('contact_mode_quote', locale),
    };
  }

  static String _subtitle(BusinessContactMode mode, String locale) {
    return switch (mode) {
      BusinessContactMode.messageOnly =>
        BusinessesStrings.t('contact_mode_message_only_hint', locale),
      BusinessContactMode.appointment =>
        BusinessesStrings.t('contact_mode_appointment_hint', locale),
      BusinessContactMode.quote =>
        BusinessesStrings.t('contact_mode_quote_hint', locale),
    };
  }
}
