import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/post_engine/config/post_engine_config.dart';

/// Local monthly AI usage tracker for Post Engine (mirrors ScamShield pattern).
class PostIntelligenceUsageRepository {
  PostIntelligenceUsageRepository({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  static const _prefix = 'post_engine_ai_usage_';

  Future<SharedPreferences> get _storage async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<bool> canUse(String requestType) async {
    final cap = _capFor(requestType);
    if (cap <= 0) return true;
    final used = await countFor(requestType);
    return used < cap;
  }

  Future<void> record(String requestType) async {
    final prefs = await _storage;
    final key = _monthKey(requestType);
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
  }

  Future<int> countFor(String requestType) async {
    final prefs = await _storage;
    return prefs.getInt(_monthKey(requestType)) ?? 0;
  }

  int _capFor(String requestType) {
    return switch (requestType) {
      PostEngineConfig.detectCategoryRequestType =>
        PostEngineConfig.freeMonthlyDetectCategory,
      PostEngineConfig.extractAttributesRequestType =>
        PostEngineConfig.freeMonthlyExtractAttributes,
      PostEngineConfig.generateTitleRequestType =>
        PostEngineConfig.freeMonthlyGenerateTitle,
      PostEngineConfig.generateDescriptionRequestType =>
        PostEngineConfig.freeMonthlyGenerateDescription,
      PostEngineConfig.improveListingRequestType =>
        PostEngineConfig.freeMonthlyImproveListing,
      PostEngineConfig.detectRiskRequestType =>
        PostEngineConfig.freeMonthlyDetectRisk,
      PostEngineConfig.extractServiceRequestRequestType =>
        PostEngineConfig.freeMonthlyExtractServiceRequest,
      _ => 0,
    };
  }

  String _monthKey(String requestType) {
    final now = DateTime.now();
    return '$_prefix${requestType}_${now.year}_${now.month}';
  }
}
