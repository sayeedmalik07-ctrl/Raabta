import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/prospective_migrant/data/prospective_profile_repository.dart';
import 'package:raabta/features/prospective_migrant/domain/models/prospective_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class ProspectiveArrivalFlags {
  static const prefsKey = 'prospective_arrival_pending';
}

/// Migrates guest Hive data into EOSB cache after successful login.
class ProspectiveArrivalMigrationService {
  const ProspectiveArrivalMigrationService();

  static Future<bool> markArrivalPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(ProspectiveArrivalFlags.prefsKey, true);
    return true;
  }

  static Future<bool> isArrivalPending() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(ProspectiveArrivalFlags.prefsKey) ?? false;
  }

  static Future<void> clearArrivalPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ProspectiveArrivalFlags.prefsKey);
  }

  /// Write-then-delete: cache EOSB input first, clear Hive only on success.
  Future<bool> migrateIfPending(WidgetRef ref) async {
    final pending = await isArrivalPending();
    if (!pending) return false;

    final profile = await ProspectiveProfileRepository.instance.load();
    if (profile == null || !profile.contractIntakeComplete) {
      await clearArrivalPending();
      return false;
    }

    try {
      final input = const ProspectiveProfileMapper().toMigrationInput(profile);
      final eosbRepo = await ref.read(eosbRepositoryProvider.future);
      await eosbRepo.cacheInput(input);
      ref.read(eosbProvider.notifier).updateInput(input);
      await ProspectiveProfileRepository.instance.clear();
      await clearArrivalPending();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final prospectiveArrivalMigrationServiceProvider =
    Provider<ProspectiveArrivalMigrationService>(
  (_) => const ProspectiveArrivalMigrationService(),
);
