import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/home/providers/home_truth_chip_invalidation.dart';
import 'package:raabta/features/home/providers/home_truth_engine_reveal_provider.dart';

/// Hides Truth Engine sensitive reveal on backgrounding and route changes.
class HomeTruthEngineRevealListener extends ConsumerStatefulWidget {
  const HomeTruthEngineRevealListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<HomeTruthEngineRevealListener> createState() =>
      _HomeTruthEngineRevealListenerState();
}

class _HomeTruthEngineRevealListenerState
    extends ConsumerState<HomeTruthEngineRevealListener>
    with WidgetsBindingObserver {
  VoidCallback? _routerListener;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.maybeOf(context);
    if (router == null) return;
    if (!identical(_router, router)) {
      _routerListener?.call();
      _router = router;
      _routerListener = () {
        ref.read(homeTruthEngineRevealControllerProvider).onRouteChanged();
      };
      router.routerDelegate.addListener(_routerListener!);
    }
  }

  @override
  void dispose() {
    if (_routerListener != null && _router != null) {
      _router!.routerDelegate.removeListener(_routerListener!);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        ref.read(homeTruthEngineRevealControllerProvider).onAppBackgrounded();
      case AppLifecycleState.resumed:
        invalidateHomeTruthChips(ref);
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
