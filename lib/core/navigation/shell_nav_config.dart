import 'package:flutter/material.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';

/// Primary shell tabs (bottom navigation).
enum ShellTab {
  home,
  market,
  community,
  profile,
}

/// One tappable bottom-nav tab. Prompt 2 can interleave [ShellNavCenterActionSlot].
sealed class ShellNavSlot {}

class ShellNavTabSlot extends ShellNavSlot {
  ShellNavTabSlot({
    required this.tab,
    required this.destination,
  });

  final ShellTab tab;
  final NavigationDestination destination;
}

/// Center Post action — not a tab; see [FloatingNavBar].
class ShellNavCenterActionSlot extends ShellNavSlot {
  ShellNavCenterActionSlot();
}

/// Result of parsing legacy `/home?tab=` indices from the 5-tab era.
class ShellHomeTabLaunch {
  const ShellHomeTabLaunch({
    required this.tab,
    this.openAiChat = false,
  });

  final ShellTab tab;
  final bool openAiChat;
}

abstract final class ShellNavConfig {
  static const legacyAiTabIndex = 3;
  static const legacyProfileTabIndex = 4;

  static List<ShellNavSlot> slotsFor(String locale) => [
        ShellNavTabSlot(
          tab: ShellTab.home,
          destination: NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: AppShellStrings.t('nav_home', locale),
          ),
        ),
        ShellNavTabSlot(
          tab: ShellTab.market,
          destination: NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront_rounded),
            label: AppShellStrings.t('nav_market', locale),
          ),
        ),
        ShellNavCenterActionSlot(),
        ShellNavTabSlot(
          tab: ShellTab.community,
          destination: NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups_rounded),
            label: AppShellStrings.t('nav_community', locale),
          ),
        ),
        ShellNavTabSlot(
          tab: ShellTab.profile,
          destination: NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: AppShellStrings.t('nav_profile', locale),
          ),
        ),
      ];

  static List<ShellNavTabSlot> tabSlotsFor(String locale) =>
      slotsFor(locale).whereType<ShellNavTabSlot>().toList();

  static int navIndexForTab(ShellTab tab, String locale) {
    final tabs = tabSlotsFor(locale);
    return tabs.indexWhere((slot) => slot.tab == tab);
  }

  static ShellTab? tabAtNavIndex(int navIndex, String locale) {
    final tabs = tabSlotsFor(locale);
    if (navIndex < 0 || navIndex >= tabs.length) return null;
    return tabs[navIndex].tab;
  }

  /// Maps a tab to the `/home?tab=` query index (4-tab shell).
  static int legacyQueryIndexFor(ShellTab tab) => switch (tab) {
        ShellTab.home => 0,
        ShellTab.market => 1,
        ShellTab.community => 2,
        ShellTab.profile => 3,
      };

  /// Parses `/home?tab=` from the pre–Prompt-1 five-tab shell.
  static ShellHomeTabLaunch resolveLegacyHomeTabQuery(int rawTab) {
    if (rawTab == legacyAiTabIndex) {
      return const ShellHomeTabLaunch(
        tab: ShellTab.home,
        openAiChat: true,
      );
    }
    if (rawTab >= legacyProfileTabIndex) {
      return const ShellHomeTabLaunch(tab: ShellTab.profile);
    }
    return ShellHomeTabLaunch(
      tab: ShellTab.values[rawTab.clamp(0, ShellTab.values.length - 1)],
    );
  }
}
