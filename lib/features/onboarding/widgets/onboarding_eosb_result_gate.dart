import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/onboarding/providers/onboarding_providers.dart';
import 'package:raabta/features/onboarding/widgets/onboarding_completion.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Wraps [EosbResultScreen] to finish onboarding after the first estimate is shown.
class OnboardingEosbResultGate extends ConsumerStatefulWidget {
  const OnboardingEosbResultGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OnboardingEosbResultGate> createState() =>
      _OnboardingEosbResultGateState();
}

class _OnboardingEosbResultGateState extends ConsumerState<OnboardingEosbResultGate> {
  var _completionHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeComplete());
  }

  void _maybeComplete() {
    if (_completionHandled || !mounted) return;
    if (!ref.read(onboardingActiveProvider)) return;
    if (ref.read(eosbProvider).result == null) return;
    _completionHandled = true;
    ref.read(onboardingActiveProvider.notifier).state = false;
    // Snapshot at one-time onboarding completion — celebration copy matches locale then.
    final locale = ref.read(userLanguageProvider);
    completeOnboardingWithEstimate(context, locale: locale);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EosbState>(eosbProvider, (previous, next) {
      if (next.result != null) _maybeComplete();
    });

    return widget.child;
  }
}
