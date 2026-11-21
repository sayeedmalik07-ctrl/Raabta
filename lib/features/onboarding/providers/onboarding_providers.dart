import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';

/// Qualifier answers collected on onboarding screen 2.
class OnboardingQualifierState {
  const OnboardingQualifierState({
    this.contractType = EosbContractType.unlimited,
    this.yearsBand = OnboardingYearsBand.oneToThree,
  });

  final EosbContractType contractType;
  final OnboardingYearsBand yearsBand;

  double get approximateYears => yearsBand.approximateYears;

  OnboardingQualifierState copyWith({
    EosbContractType? contractType,
    OnboardingYearsBand? yearsBand,
  }) {
    return OnboardingQualifierState(
      contractType: contractType ?? this.contractType,
      yearsBand: yearsBand ?? this.yearsBand,
    );
  }
}

enum OnboardingYearsBand {
  underOne('< 1 year', 0.5),
  oneToThree('1–3 years', 2),
  threeToFive('3–5 years', 4),
  fiveToTen('5–10 years', 7),
  tenPlus('10+ years', 12);

  const OnboardingYearsBand(this.label, this.approximateYears);

  final String label;
  final double approximateYears;
}

/// True while the user is in the first-run EOSB funnel.
final onboardingActiveProvider = StateProvider<bool>((ref) => false);

final onboardingQualifierProvider =
    StateProvider<OnboardingQualifierState>((ref) {
  return const OnboardingQualifierState();
});
