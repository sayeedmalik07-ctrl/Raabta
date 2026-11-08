/// A deterministic, evidence-linked opportunity surfaced by [OpportunityDetector].
class Opportunity {
  const Opportunity({
    required this.id,
    required this.userId,
    required this.type,
    required this.evidenceReference,
    required this.evidenceCollection,
    required this.actionableInsight,
    required this.createdAt,
  });

  static const typeExchangeRate = 'exchange_rate_opportunity';
  static const typeEntitlementGap = 'entitlement_gap_opportunity';

  final String id;
  final String userId;
  final String type;
  final String evidenceReference;
  final String evidenceCollection;
  final String actionableInsight;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'evidenceReference': evidenceReference,
        'evidenceCollection': evidenceCollection,
        'actionableInsight': actionableInsight,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      evidenceReference: json['evidenceReference'] as String? ?? '',
      evidenceCollection: json['evidenceCollection'] as String? ?? '',
      actionableInsight: json['actionableInsight'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Opportunity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          type == other.type &&
          evidenceReference == other.evidenceReference &&
          evidenceCollection == other.evidenceCollection &&
          actionableInsight == other.actionableInsight &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        type,
        evidenceReference,
        evidenceCollection,
        actionableInsight,
        createdAt,
      );
}
