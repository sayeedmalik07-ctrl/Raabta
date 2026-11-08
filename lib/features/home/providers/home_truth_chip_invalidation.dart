import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/home/providers/truth_chip_status_providers.dart';

/// Refreshes Home Truth Engine chips after engine saves or Home resume.
void invalidateHomeTruthChips(dynamic ref) {
  ref.invalidate(truthChipStatusProvider);
  ref.invalidate(eosbHistoryProvider);
}
