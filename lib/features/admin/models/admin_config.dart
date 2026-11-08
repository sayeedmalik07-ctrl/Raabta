import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/config/compliance_config_fetch.dart';
import 'package:raabta/config/compliance_flags.dart';

class AdminAppConfig {
  const AdminAppConfig({
    this.maintenanceMode = false,
    this.maintenanceMessage = 'Raabta is under maintenance. Please check back soon.',
    this.forceUpdate = false,
    this.minimumVersion = '1.0.0',
    this.featureFlags = const {},
    this.complianceFlagsRaw = const {},
    this.complianceFlagsUpdatedAt,
    this.configDocumentPresent = false,
    this.costPer1kTokens = 0.05,
  });

  final bool maintenanceMode;
  final String maintenanceMessage;
  final bool forceUpdate;
  final String minimumVersion;
  final Map<String, bool> featureFlags;
  final Map<String, bool> complianceFlagsRaw;
  final DateTime? complianceFlagsUpdatedAt;
  final bool configDocumentPresent;
  final double costPer1kTokens;

  /// Fail-closed resolved flags (uses client last-successful-fetch age).
  ComplianceFlags get complianceFlags => ComplianceConfigFetch.resolve(this);

  static const featureFlagKeys = [
    'doc_scanner',
    'food_inspector',
    'arabic_companion',
    'bill_splitter',
    'warranty_shield',
    'climate_navigator',
    'queue_avoidance',
    'bill_tracker',
    'scam_domain_age',
    'scam_link_unroll',
  ];

  static const defaultFeatureFlags = {
    'doc_scanner': true,
    'food_inspector': true,
    'arabic_companion': true,
    'bill_splitter': true,
    'warranty_shield': true,
    'climate_navigator': true,
    'queue_avoidance': true,
    'bill_tracker': true,
    'scam_domain_age': false,
    'scam_link_unroll': false,
  };

  factory AdminAppConfig.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const AdminAppConfig();

    final complianceRaw = data['complianceFlags'];
    final complianceFlags = <String, bool>{};
    if (complianceRaw is Map) {
      for (final key in ComplianceFlagKeys.all) {
        if (complianceRaw[key] is bool) {
          complianceFlags[key] = complianceRaw[key] as bool;
        }
      }
    }
    DateTime? complianceUpdated;
    final ts = data['complianceFlagsUpdatedAt'];
    if (ts is Timestamp) {
      complianceUpdated = ts.toDate();
    } else if (data['complianceFlagsUpdatedAtIso'] is String) {
      complianceUpdated =
          DateTime.tryParse(data['complianceFlagsUpdatedAtIso'] as String);
    } else if (data['updatedAt'] is String) {
      complianceUpdated = DateTime.tryParse(data['updatedAt'] as String);
    }

    final flagsRaw = data['featureFlags'];
    final flags = Map<String, bool>.from(defaultFeatureFlags);
    if (flagsRaw is Map) {
      for (final key in featureFlagKeys) {
        if (flagsRaw[key] is bool) {
          flags[key] = flagsRaw[key] as bool;
        }
      }
      // Legacy Firestore key from Landmark Translator era.
      if (flagsRaw['landmark_translator'] is bool &&
          !flagsRaw.containsKey('arabic_companion')) {
        flags['arabic_companion'] = flagsRaw['landmark_translator'] as bool;
      }
    }

    return AdminAppConfig(
      maintenanceMode: data['maintenanceMode'] as bool? ?? false,
      maintenanceMessage: data['maintenanceMessage'] as String? ??
          'Raabta is under maintenance. Please check back soon.',
      forceUpdate: data['forceUpdate'] as bool? ?? false,
      minimumVersion: data['minimumVersion'] as String? ?? '1.0.0',
      featureFlags: flags,
      complianceFlagsRaw: complianceFlags,
      complianceFlagsUpdatedAt: complianceUpdated,
      configDocumentPresent: true,
      costPer1kTokens:
          (data['costPer1kTokens'] as num?)?.toDouble() ?? 0.05,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'maintenanceMode': maintenanceMode,
        'maintenanceMessage': maintenanceMessage,
        'forceUpdate': forceUpdate,
        'minimumVersion': minimumVersion,
        'featureFlags': featureFlags,
        'costPer1kTokens': costPer1kTokens,
        'updatedAt': DateTime.now().toIso8601String(),
      };

  AdminAppConfig copyWith({
    bool? maintenanceMode,
    String? maintenanceMessage,
    bool? forceUpdate,
    String? minimumVersion,
    Map<String, bool>? featureFlags,
    Map<String, bool>? complianceFlagsRaw,
    DateTime? complianceFlagsUpdatedAt,
    bool? configDocumentPresent,
    double? costPer1kTokens,
  }) {
    return AdminAppConfig(
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      minimumVersion: minimumVersion ?? this.minimumVersion,
      featureFlags: featureFlags ?? this.featureFlags,
      complianceFlagsRaw: complianceFlagsRaw ?? this.complianceFlagsRaw,
      complianceFlagsUpdatedAt:
          complianceFlagsUpdatedAt ?? this.complianceFlagsUpdatedAt,
      configDocumentPresent:
          configDocumentPresent ?? this.configDocumentPresent,
      costPer1kTokens: costPer1kTokens ?? this.costPer1kTokens,
    );
  }

  bool isFeatureEnabled(String key) => featureFlags[key] ?? true;
}
