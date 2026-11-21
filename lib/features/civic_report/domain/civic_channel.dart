import 'package:raabta/features/civic_report/domain/civic_channel_type.dart';
import 'package:raabta/features/civic_report/domain/civic_channel_validator.dart';
import 'package:raabta/features/civic_report/domain/civic_issue_taxonomy.dart';

class CivicChannel {
  const CivicChannel({
    required this.id,
    required this.displayNameKey,
    required this.authorityNameKey,
    required this.issueTypeIds,
    required this.channelType,
    required this.verificationStatus,
    required this.sourceLabel,
    required this.lastVerified,
    required this.verificationNote,
    this.websiteUrl,
    this.phone,
    this.iosStoreUrl,
    this.androidStoreUrl,
    this.deepLinkScheme,
    this.raabtaRoute,
    this.actionableWebsiteUrl,
    this.actionablePhone,
    this.actionableIosStoreUrl,
    this.actionableAndroidStoreUrl,
    this.actionableDeepLink,
    this.actionableRaabtaRoute,
  });

  final String id;
  final String displayNameKey;
  final String authorityNameKey;
  final List<CivicIssueTypeId> issueTypeIds;
  final CivicChannelType channelType;
  final CivicVerificationStatus verificationStatus;
  final String sourceLabel;
  final String lastVerified;
  final String verificationNote;

  final String? websiteUrl;
  final String? phone;
  final String? iosStoreUrl;
  final String? androidStoreUrl;
  final String? deepLinkScheme;
  final String? raabtaRoute;

  final String? actionableWebsiteUrl;
  final String? actionablePhone;
  final String? actionableIosStoreUrl;
  final String? actionableAndroidStoreUrl;
  final String? actionableDeepLink;
  final String? actionableRaabtaRoute;

  bool get hasAnyEnabledAction =>
      actionableWebsiteUrl != null ||
      actionablePhone != null ||
      actionableIosStoreUrl != null ||
      actionableAndroidStoreUrl != null ||
      actionableDeepLink != null ||
      actionableRaabtaRoute != null;

  bool supportsIssue(CivicIssueTypeId issue) => issueTypeIds.contains(issue);

  static CivicChannel fromJson(Map<String, dynamic> json) {
    final verificationStatus =
        CivicVerificationStatus.tryParse(json['verificationStatus']?.toString());
    final lastVerified = json['lastVerified']?.toString() ?? '';
    final sourceLabel = json['sourceLabel']?.toString() ?? '';

    final websiteUrl = json['websiteUrl'] as String?;
    final phone = json['phone'] as String?;
    final iosStoreUrl = json['iosStoreUrl'] as String?;
    final androidStoreUrl = json['androidStoreUrl'] as String?;
    final deepLinkScheme = json['deepLinkScheme'] as String?;
    final raabtaRoute = json['raabtaRoute'] as String?;

    final issueRaw = json['issueTypeIds'] as List<dynamic>? ?? [];
    final issueTypeIds = <CivicIssueTypeId>[
      for (final raw in issueRaw)
        if (CivicIssueTypeId.tryParse(raw.toString()) case final id?) id,
    ];

    final channelType =
        CivicChannelType.tryParse(json['channelType']?.toString()) ??
            CivicChannelType.officialWebsite;

    final baseArgs = (
      verificationStatus: verificationStatus,
      lastVerified: lastVerified,
      sourceLabel: sourceLabel,
    );

    return CivicChannel(
      id: json['id']?.toString() ?? '',
      displayNameKey: json['displayNameKey']?.toString() ?? '',
      authorityNameKey: json['authorityNameKey']?.toString() ?? '',
      issueTypeIds: issueTypeIds,
      channelType: channelType,
      verificationStatus: verificationStatus,
      sourceLabel: sourceLabel,
      lastVerified: lastVerified,
      verificationNote: json['verificationNote']?.toString() ?? '',
      websiteUrl: websiteUrl,
      phone: phone,
      iosStoreUrl: iosStoreUrl,
      androidStoreUrl: androidStoreUrl,
      deepLinkScheme: deepLinkScheme,
      raabtaRoute: raabtaRoute,
      actionableWebsiteUrl: CivicChannelValidator.enabledHttpsUrl(
        verificationStatus: baseArgs.verificationStatus,
        lastVerified: baseArgs.lastVerified,
        sourceLabel: baseArgs.sourceLabel,
        websiteUrl: websiteUrl,
      ),
      actionablePhone: CivicChannelValidator.enabledPhone(
        verificationStatus: baseArgs.verificationStatus,
        lastVerified: baseArgs.lastVerified,
        sourceLabel: baseArgs.sourceLabel,
        phone: phone,
      ),
      actionableIosStoreUrl: CivicChannelValidator.enabledStoreUrl(
        verificationStatus: baseArgs.verificationStatus,
        lastVerified: baseArgs.lastVerified,
        sourceLabel: baseArgs.sourceLabel,
        storeUrl: iosStoreUrl,
      ),
      actionableAndroidStoreUrl: CivicChannelValidator.enabledStoreUrl(
        verificationStatus: baseArgs.verificationStatus,
        lastVerified: baseArgs.lastVerified,
        sourceLabel: baseArgs.sourceLabel,
        storeUrl: androidStoreUrl,
      ),
      actionableDeepLink: CivicChannelValidator.enabledDeepLink(
        verificationStatus: baseArgs.verificationStatus,
        lastVerified: baseArgs.lastVerified,
        sourceLabel: baseArgs.sourceLabel,
        deepLinkScheme: deepLinkScheme,
      ),
      actionableRaabtaRoute: CivicChannelValidator.enabledRaabtaRoute(
        verificationStatus: baseArgs.verificationStatus,
        lastVerified: baseArgs.lastVerified,
        sourceLabel: baseArgs.sourceLabel,
        raabtaRoute: raabtaRoute,
      ),
    );
  }
}
