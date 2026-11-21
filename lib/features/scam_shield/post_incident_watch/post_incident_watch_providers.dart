import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/post_incident_watch/post_incident_watch_service.dart';

final postIncidentWatchActiveProvider = FutureProvider<bool>((ref) async {
  return PostIncidentWatchService.isWatchActive();
});
