import 'package:flutter/material.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';

/// Primary shell tabs (bottom navigation).
enum ShellTab {
  home,
  documents,
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

  /// Pre–Documents-tab era: `/home?tab=1` opened the Market / Marketplace shell.
  static const legacyMarketplaceTabIndex = 1;

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
          tab: ShellTab.documents,
          destination: NavigationDestination(
            icon: const Icon(Icons.description_outlined),
            selectedIcon: const Icon(Icons.description_rounded),
            label: AppShellStrings.t('nav_documents', locale),
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

  /// Maps a shell tab to a legacy `/home?tab=` query index when one exists.
  ///
  /// [ShellTab.documents] uses `/home?shell=documents` instead — never index 1.
  static int? legacyQueryIndexFor(ShellTab tab) => switch (tab) {
        ShellTab.home => 0,
        ShellTab.documents => null,
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
    if (rawTab == legacyMarketplaceTabIndex) {
      return const ShellHomeTabLaunch(tab: ShellTab.home);
    }
    return switch (rawTab) {
      0 => const ShellHomeTabLaunch(tab: ShellTab.home),
      2 => const ShellHomeTabLaunch(tab: ShellTab.community),
      3 => const ShellHomeTabLaunch(tab: ShellTab.profile),
      _ => const ShellHomeTabLaunch(tab: ShellTab.home),
    };
  }
}