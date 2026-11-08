import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/home/data/home_ai_orb_coach_mark_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('coach mark starts not dismissed', () async {
    expect(await HomeAiOrbCoachMarkPrefs.isDismissed(), isFalse);
  });

  test('dismiss persists', () async {
    await HomeAiOrbCoachMarkPrefs.dismiss();
    expect(await HomeAiOrbCoachMarkPrefs.isDismissed(), isTrue);

    SharedPreferences.setMockInitialValues({
      HomeAiOrbCoachMarkPrefs.dismissedKey: true,
    });
    expect(await HomeAiOrbCoachMarkPrefs.isDismissed(), isTrue);
  });
}
