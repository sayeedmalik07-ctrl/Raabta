import 'package:flutter/material.dart';
import 'package:raabta/core/widgets/truth_engine_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

class EosbDisclaimerBanner extends StatelessWidget {
  const EosbDisclaimerBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return TruthEngineDisclaimerBanner(
      text: EosbStrings.t('eosb_disclaimer', locale),
      style: TruthEngineDisclaimerStyle.legalWarning,
    );
  }
}
