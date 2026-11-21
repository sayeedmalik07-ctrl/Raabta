import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/design/home_glass_legibility_tokens.dart';
import 'package:raabta/core/navigation/floating_nav_bar.dart';

void main() {
  test('nav legibility floors match HomeGlassLegibilityTokens', () {
    expect(
      kFloatingNavHomeSurfaceAlpha,
      HomeGlassLegibilityTokens.homeNavSurfaceAlpha,
    );
    expect(
      kFloatingNavHomeBlurSigma,
      HomeGlassLegibilityTokens.homeNavBlurSigma,
    );
    expect(HomeGlassLegibilityTokens.pinnedSurfaceAlpha, greaterThan(0.9));
  });
}