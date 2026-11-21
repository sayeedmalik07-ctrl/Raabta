import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/notification_preferences/presentation/screens/notification_preferences_screen.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_awareness_models.dart';
import 'package:raabta/features/scam_shield/security_alerts/security_awareness_service.dart';
import 'package:raabta/providers/visa_providers.dart';

final securityAwarenessServiceProvider = Provider<SecurityAwarenessService>(
  (ref) => SecurityAwarenessService(),
);

final securityAwarenessCampaignProvider =
    FutureProvider<SecurityAwarenessCampaign?>((ref) async {
  final locale = ref.watch(userLanguageProvider);
  final service = ref.watch(securityAwarenessServiceProvider);
  final prefsService =
      await ref.watch(notificationPreferencesServiceProvider.future);
  final settings = await prefsService.getSettings();
  return service.resolve(settings: settings, locale: locale);
});

Future<void> dismissSecurityAwarenessCampaign(
  WidgetRef ref,
  SecurityAwarenessCampaign campaign,
) async {
  await ref.read(securityAwarenessServiceProvider).dismissCampaign(campaign.id);
  ref.invalidate(securityAwarenessCampaignProvider);
}
