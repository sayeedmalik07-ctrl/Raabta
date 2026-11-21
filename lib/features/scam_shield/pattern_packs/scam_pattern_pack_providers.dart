import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/pattern_packs/scam_pattern_pack_loader.dart';

final scamPatternPackBootstrapProvider = FutureProvider<void>((ref) async {
  await ScamPatternPackLoader.loadAll();
});
