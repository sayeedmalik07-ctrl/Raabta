import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';

void main() {
  test('Community hub landing l10n includes feed tab and hub search', () {
    expect(CommunityStrings.t('community_tab_feed', 'English'), 'Feed');
    expect(
      CommunityStrings.t('community_search_hub_hint', 'English'),
      'Search community…',
    );
    expect(
      CommunityStrings.t('community_hub_subtitle', 'English'),
      'Ask, share and help in Qatar',
    );
  });
}
