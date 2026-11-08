import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_reporting_channels.dart';

class ReportPackChannel {
  const ReportPackChannel({
    required this.id,
    required this.nameKey,
    required this.bodyKey,
    required this.verified,
    required this.lastVerified,
    required this.sourceLabel,
    this.callNumber,
    this.secondaryCallNumber,
    this.email,
    this.verifyUrl,
    this.openAppUrl,
    this.appRouteNoteKey,
    this.isUserBankLine = false,
  });

  final String id;
  final String nameKey;
  final String bodyKey;
  final bool verified;
  final String lastVerified;
  final String sourceLabel;
  final String? callNumber;
  final String? secondaryCallNumber;
  final String? email;
  final String? verifyUrl;
  final String? openAppUrl;
  final String? appRouteNoteKey;
  final bool isUserBankLine;
}

abstract final class ReportPackChannelCatalog {
  static const assetPath = 'assets/scam_shield/report_pack_channels.json';
  static List<ReportPackChannel>? _cache;

  @visibleForTesting
  static void installForTest(List<ReportPackChannel> channels) => _cache = channels;

  @visibleForTesting
  static void resetForTest() => _cache = null;

  static Future<List<ReportPackChannel>> loadVerified({
    bool includeUserBankChannel = false,
  }) async {
    await _ensureLoaded();
    final out = _cache!.where((c) => c.verified).toList(growable: true);

    if (includeUserBankChannel) {
      out.insert(
        0,
        const ReportPackChannel(
          id: 'user_bank_fraud_line',
          nameKey: 'ss_rp_ch_user_bank',
          bodyKey: 'ss_rp_ch_user_bank_body',
          verified: true,
          lastVerified: 'n/a',
          sourceLabel: 'User-entered bank fraud line',
          isUserBankLine: true,
        ),
      );
    }

    final operators = await ReportPackReportingChannels.loadForPicker();
    for (final op in operators) {
      out.add(
        ReportPackChannel(
          id: 'op_${op.id}',
          nameKey: op.nameKey,
          bodyKey: op.bodyKey,
          verified: true,
          lastVerified: 'bundled',
          sourceLabel: op.sourceLabel,
          callNumber: op.dialNumber,
          verifyUrl: op.verifyUrl,
        ),
      );
    }
    return out;
  }

  static Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final list = decoded['channels'] as List<dynamic>? ?? [];
    _cache = [
      for (final item in list)
        if (item is Map<String, dynamic>) _fromJson(item),
    ];
  }

  static ReportPackChannel _fromJson(Map<String, dynamic> json) {
    return ReportPackChannel(
      id: json['id']?.toString() ?? '',
      nameKey: json['nameKey']?.toString() ?? '',
      bodyKey: json['bodyKey']?.toString() ?? '',
      verified: json['verified'] == true,
      lastVerified: json['lastVerified']?.toString() ?? '',
      sourceLabel: json['sourceLabel']?.toString() ?? '',
      callNumber: json['callNumber'] as String?,
      secondaryCallNumber: json['secondaryCallNumber'] as String?,
      email: json['email'] as String?,
      verifyUrl: json['verifyUrl'] as String?,
      openAppUrl: json['openAppUrl'] as String?,
      appRouteNoteKey: json['appRouteNoteKey'] as String?,
    );
  }
}
