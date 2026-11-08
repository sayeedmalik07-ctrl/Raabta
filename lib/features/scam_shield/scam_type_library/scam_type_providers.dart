import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_catalog.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_models.dart';

final scamTypeCatalogProvider = FutureProvider<List<ScamTypeDefinition>>(
  (ref) => ScamTypeCatalog.loadAll(),
);

final scamTypeVerifiedProvider = FutureProvider<List<ScamTypeDefinition>>(
  (ref) async {
    final all = await ref.watch(scamTypeCatalogProvider.future);
    return ScamTypeCatalog.verifiedOnly(all);
  },
);
