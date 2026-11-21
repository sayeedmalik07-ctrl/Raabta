import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/navigation/floating_nav_bar.dart';
import 'package:raabta/core/navigation/shell_nav_config.dart';
import 'package:raabta/core/navigation/shell_post_center_action.dart';
import 'package:raabta/core/navigation/shell_post_entry.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Keeps the main bottom nav visible on Profile sub-screens pushed via GoRouter.
class ProfileTabScaffold extends ConsumerStatefulWidget {
  const ProfileTabScaffold({super.key, required this.child});

  final Widget child;

  static const double _bodyBottomPadding =
      AppSpacing.navHeight + AppSpacing.navBottomMargin + AppSpacing.sm;

  @override
  ConsumerState<ProfileTabScaffold> createState() => _ProfileTabScaffoldState();
}

class _ProfileTabScaffoldState extends ConsumerState<ProfileTabScaffold> {
  bool _postMenuOpen = false;

  void _onNavTap(BuildContext context, ShellTab tab) {
    _closePostMenu();
    if (tab == ShellTab.profile) {
      if (context.canPop()) {
        context.pop();
        return;
      }
      context.go('/home?tab=${ShellNavConfig.legacyQueryIndexFor(ShellTab.profile)}');
      return;
    }
    context.go('/home?tab=${ShellNavConfig.legacyQueryIndexFor(tab)}');
  }

  void _closePostMenu() {
    if (!_postMenuOpen) return;
    setState(() => _postMenuOpen = false);
  }

  void _openPostVertical(PostVertical vertical) {
    _closePostMenu();
    ShellPostEntry.openVertical(context, vertical);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final showBottomNav = keyboardInset <= 0;

    return PopScope(
      canPop: !_postMenuOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _postMenuOpen) _closePostMenu();
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: ProfileTabScaffold._bodyBottomPadding),
            child: widget.child,
          ),
          if (_postMenuOpen && showBottomNav)
            Positioned.fill(
              child: ShellPostVerticalMenuOverlay(
                locale: locale,
                open: _postMenuOpen,
                onClose: _closePostMenu,
                onVerticalSelected: _openPostVertical,
              ),
            ),
          if (showBottomNav)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingNavBar(
                currentTab: ShellTab.profile,
                slots: ShellNavConfig.slotsFor(locale),
                locale: locale,
                postMenuOpen: _postMenuOpen,
                onPostMenuToggle: () => setState(() => _postMenuOpen = !_postMenuOpen),
                onTabSelected: (tab) => _onNavTap(context, tab),
              ),
            ),
        ],
      ),
    );
  }
}
