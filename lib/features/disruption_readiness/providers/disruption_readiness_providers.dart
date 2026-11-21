import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/disruption_readiness/domain/disruption_go_bag_service.dart';

final disruptionGoBagServiceProvider = Provider<DisruptionGoBagService>(
  (ref) => DisruptionGoBagService(),
);
