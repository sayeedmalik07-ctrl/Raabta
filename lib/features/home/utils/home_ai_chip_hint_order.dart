import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';

/// Static localized hint keys for the Home AI chip (no AI generation).
abstract final class HomeAiChipHintKeys {
  static const all = [
    hintEosb,
    hintScam,
    hintTrip,
    hintJob,
    hintContract,
    hintGeneral,
  ];

  static const hintEosb = 'ai_chip_hint_eosb';
  static const hintScam = 'ai_chip_hint_scam';
  static const hintTrip = 'ai_chip_hint_trip';
  static const hintJob = 'ai_chip_hint_job';
  static const hintContract = 'ai_chip_hint_contract';
  static const hintGeneral = 'ai_chip_hint_general';
}

abstract final class HomeAiChipHintOrder {
  /// Hint priority from [knowQatarPersonaProvider] — no local persona derivation.
  static List<String> forPersona(KnowQatarPersona persona) {
    return _orderedKeys(persona);
  }

  static List<String> _orderedKeys(KnowQatarPersona persona) {
    const eosb = HomeAiChipHintKeys.hintEosb;
    const scam = HomeAiChipHintKeys.hintScam;
    const trip = HomeAiChipHintKeys.hintTrip;
    const job = HomeAiChipHintKeys.hintJob;
    const contract = HomeAiChipHintKeys.hintContract;
    const general = HomeAiChipHintKeys.hintGeneral;

    return switch (persona) {
      KnowQatarPersona.visitor => [trip, scam, general, job, contract, eosb],
      KnowQatarPersona.newResident => [
          contract,
          eosb,
          scam,
          job,
          trip,
          general,
        ],
      KnowQatarPersona.workingResident => [
          job,
          eosb,
          contract,
          scam,
          trip,
          general,
        ],
      KnowQatarPersona.family => [
          eosb,
          contract,
          trip,
          scam,
          job,
          general,
        ],
    };
  }
}
