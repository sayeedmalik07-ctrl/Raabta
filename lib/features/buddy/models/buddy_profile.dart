import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/buddy/domain/buddy_constants.dart';

class BuddyProfile {
  const BuddyProfile({
    required this.uid,
    required this.isNewcomer,
    required this.isHelper,
    required this.paused,
    required this.displayNickname,
    required this.nationalityCountryId,
    required this.spokenLanguageCodes,
    required this.areaCode,
    required this.yearsInQatarBand,
    required this.interestTagIds,
    required this.consentVersion,
    required this.adultAttestationAt,
    required this.optInAt,
    required this.updatedAt,
    this.lastMatchedAt,
  });

  final String uid;
  final bool isNewcomer;
  final bool isHelper;
  final bool paused;
  final String displayNickname;
  final String nationalityCountryId;
  final List<String> spokenLanguageCodes;
  final String areaCode;
  final String yearsInQatarBand;
  final List<String> interestTagIds;
  final String consentVersion;
  final DateTime? adultAttestationAt;
  final DateTime? optInAt;
  final DateTime? updatedAt;
  final DateTime? lastMatchedAt;

  Map<String, dynamic> toFirestore({bool isCreate = false}) {
    return {
      'uid': uid,
      'isNewcomer': isNewcomer,
      'isHelper': isHelper,
      'paused': paused,
      'displayNickname': displayNickname.trim(),
      'nationalityCountryId': nationalityCountryId,
      'spokenLanguageCodes': List<String>.from(spokenLanguageCodes),
      'areaCode': areaCode,
      'yearsInQatarBand': yearsInQatarBand,
      'interestTagIds': List<String>.from(interestTagIds),
      'consentVersion': consentVersion,
      'adultAttestationAt': adultAttestationAt != null
          ? Timestamp.fromDate(adultAttestationAt!)
          : null,
      if (isCreate && optInAt != null)
        'optInAt': Timestamp.fromDate(optInAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory BuddyProfile.fromFirestore(String docId, Map<String, dynamic> data) {
    return BuddyProfile(
      uid: data['uid'] as String? ?? docId,
      isNewcomer: data['isNewcomer'] as bool? ?? false,
      isHelper: data['isHelper'] as bool? ?? false,
      paused: data['paused'] as bool? ?? false,
      displayNickname: data['displayNickname'] as String? ?? '',
      nationalityCountryId: data['nationalityCountryId'] as String? ?? '',
      spokenLanguageCodes: _stringList(data['spokenLanguageCodes']),
      areaCode: data['areaCode'] as String? ?? '',
      yearsInQatarBand:
          data['yearsInQatarBand'] as String? ?? BuddyConstants.yearsBandUnder1,
      interestTagIds: _stringList(data['interestTagIds']),
      consentVersion: data['consentVersion'] as String? ?? '',
      adultAttestationAt: _timestampToDate(data['adultAttestationAt']),
      optInAt: _timestampToDate(data['optInAt']),
      updatedAt: _timestampToDate(data['updatedAt']),
      lastMatchedAt: _timestampToDate(data['lastMatchedAt']),
    );
  }

  Map<String, dynamic> toExportJson() {
    return {
      'uid': uid,
      'isNewcomer': isNewcomer,
      'isHelper': isHelper,
      'paused': paused,
      'displayNickname': displayNickname,
      'nationalityCountryId': nationalityCountryId,
      'spokenLanguageCodes': spokenLanguageCodes,
      'areaCode': areaCode,
      'yearsInQatarBand': yearsInQatarBand,
      'interestTagIds': interestTagIds,
      'consentVersion': consentVersion,
      'adultAttestationAt': adultAttestationAt?.toUtc().toIso8601String(),
      'optInAt': optInAt?.toUtc().toIso8601String(),
      'updatedAt': updatedAt?.toUtc().toIso8601String(),
    };
  }

  BuddyProfile copyWith({
    bool? isNewcomer,
    bool? isHelper,
    bool? paused,
    String? displayNickname,
    String? nationalityCountryId,
    List<String>? spokenLanguageCodes,
    String? areaCode,
    String? yearsInQatarBand,
    List<String>? interestTagIds,
    DateTime? updatedAt,
  }) {
    return BuddyProfile(
      uid: uid,
      isNewcomer: isNewcomer ?? this.isNewcomer,
      isHelper: isHelper ?? this.isHelper,
      paused: paused ?? this.paused,
      displayNickname: displayNickname ?? this.displayNickname,
      nationalityCountryId: nationalityCountryId ?? this.nationalityCountryId,
      spokenLanguageCodes: spokenLanguageCodes ?? this.spokenLanguageCodes,
      areaCode: areaCode ?? this.areaCode,
      yearsInQatarBand: yearsInQatarBand ?? this.yearsInQatarBand,
      interestTagIds: interestTagIds ?? this.interestTagIds,
      consentVersion: consentVersion,
      adultAttestationAt: adultAttestationAt,
      optInAt: optInAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  static DateTime? _timestampToDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }
}
