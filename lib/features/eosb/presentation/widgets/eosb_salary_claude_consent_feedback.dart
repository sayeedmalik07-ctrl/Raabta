import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

void showEosbSalaryClaudeConsentSnackBar(BuildContext context, String locale) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        EosbStrings.t('eosb_salary_claude_consent_required', locale),
      ),
      action: SnackBarAction(
        label: EosbStrings.t('eosb_privacy_security', locale),
        onPressed: () => context.push('/profile/privacy'),
      ),
    ),
  );
}
