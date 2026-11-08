import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScamProactiveProtectionStatus {
  const ScamProactiveProtectionStatus({
    required this.linkCheckingActive,
    required this.supportsCallScreening,
    required this.callScreeningActive,
    required this.supportsSmsFilterGuide,
    required this.smsFilterUserConfirmed,
    required this.smsFilteredCount,
    required this.pendingFlaggedCalls,
  });

  final bool linkCheckingActive;
  final bool supportsCallScreening;
  final bool callScreeningActive;
  final bool supportsSmsFilterGuide;
  final bool smsFilterUserConfirmed;
  final int smsFilteredCount;
  final List<ScamFlaggedCallEvent> pendingFlaggedCalls;
}

class ScamFlaggedCallEvent {
  const ScamFlaggedCallEvent({
    required this.maskedNumber,
    required this.timestamp,
    required this.reasons,
    this.stirShakenStatus,
  });

  final String maskedNumber;
  final String timestamp;
  final List<String> reasons;
  final String? stirShakenStatus;
}

/// Platform bridge for Phase 7 proactive protection (call screening / SMS guide).
class ScamProactiveProtectionPlatform {
  ScamProactiveProtectionPlatform({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel('com.sayeed.raabta/scam_proactive');

  final MethodChannel _channel;

  static const _smsConfirmedKey = 'ss_sms_filter_user_confirmed';

  Future<ScamProactiveProtectionStatus> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final caps = await _getCapabilities();
    final supportsCallScreening = caps['supportsCallScreening'] == true;
    final supportsSmsFilterGuide = caps['supportsSmsFilterGuide'] == true;

    var callScreeningActive = false;
    var pending = <ScamFlaggedCallEvent>[];
    if (supportsCallScreening) {
      callScreeningActive =
          await _channel.invokeMethod<bool>('isCallScreeningRoleHeld') ?? false;
      pending = await _consumePendingFlaggedCalls();
    }

    var smsConfirmed = prefs.getBool(_smsConfirmedKey) ?? false;
    var smsCount = 0;
    if (supportsSmsFilterGuide) {
      smsConfirmed =
          await _channel.invokeMethod<bool>('isSmsFilterUserConfirmed') ??
              smsConfirmed;
      smsCount =
          await _channel.invokeMethod<int>('getSmsFilteredCount') ?? 0;
    }

    return ScamProactiveProtectionStatus(
      linkCheckingActive: caps['linkCheckingSupported'] != false,
      supportsCallScreening: supportsCallScreening,
      callScreeningActive: callScreeningActive,
      supportsSmsFilterGuide: supportsSmsFilterGuide,
      smsFilterUserConfirmed: smsConfirmed,
      smsFilteredCount: smsCount,
      pendingFlaggedCalls: pending,
    );
  }

  Future<bool> requestCallScreeningRole() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('requestCallScreeningRole') ??
        false;
  }

  Future<void> confirmSmsFilterEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_smsConfirmedKey, true);
    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('setSmsFilterUserConfirmed');
    }
  }

  Future<Map<String, dynamic>> _getCapabilities() async {
    try {
      final result =
          await _channel.invokeMethod<Map>('getPlatformCapabilities');
      return Map<String, dynamic>.from(result ?? {});
    } catch (_) {
      return {
        'supportsCallScreening': Platform.isAndroid,
        'supportsSmsFilterGuide': Platform.isIOS,
        'linkCheckingSupported': true,
      };
    }
  }

  Future<List<ScamFlaggedCallEvent>> _consumePendingFlaggedCalls() async {
    try {
      final raw = await _channel.invokeMethod<List>('consumePendingFlaggedCalls');
      if (raw == null) return [];
      return raw.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return ScamFlaggedCallEvent(
          maskedNumber: map['number']?.toString() ?? '',
          timestamp: map['timestamp']?.toString() ?? '',
          reasons: (map['reasons'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
          stirShakenStatus: map['stirShakenStatus']?.toString(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
