import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/navigation/floating_nav_bar.dart';
import 'package:raabta/core/navigation/shell_nav_config.dart';

void main() {
  test('lens stretch peaks mid glide', () {
    final start = navLensStretchWidthForTest(0);
    final mid = navLensStretchWidthForTest(0.5);
    final end = navLensStretchWidthForTest(1);
    expect(mid, greaterThan(start));
    expect(mid, greaterThan(end));
  });

  test('shell nav indexes skip center slot', () {
    expect(ShellNavConfig.navIndexForTab(ShellTab.home, 'English'), 0);
    expect(ShellNavConfig.navIndexForTab(ShellTab.market, 'English'), 1);
    expect(ShellNavConfig.navIndexForTab(ShellTab.community, 'English'), 2);
    expect(ShellNavConfig.navIndexForTab(ShellTab.profile, 'English'), 3);
  });

  test('hub dock glass is more opaque than home', () {
    const isLight = false;
    final home = floatingNavGlassBackground(
      currentTab: ShellTab.home,
      isLight: isLight,
    );
    final community = floatingNavGlassBackground(
      currentTab: ShellTab.community,
      isLight: isLight,
    );
    expect(community, isNot(equals(home)));
    expect(
      floatingNavGlassBlurSigma(currentTab: ShellTab.community, isLight: false),
      lessThan(
        floatingNavGlassBlurSigma(currentTab: ShellTab.home, isLight: false),
      ),
    );
  });

  test('lens centers stay inside bar width', () {
    const width = 320.0;
    for (final tab in ShellTab.values) {
      final x = floatingNavLensCenterXForTab(
        tab: tab,
        totalWidth: width,
        textDirection: TextDirection.ltr,
      );
      expect(x, greaterThan(0));
      expect(x, lessThan(width));
    }
  });
}
