class DomainAgeLookupResult {
  const DomainAgeLookupResult({
    required this.supported,
    required this.registered,
    this.createdAt,
    this.ageDays,
  });

  final bool supported;
  final bool registered;
  final DateTime? createdAt;
  final int? ageDays;

  factory DomainAgeLookupResult.fromJson(Map<String, dynamic> json) {
    return DomainAgeLookupResult(
      supported: json['supported'] == true,
      registered: json['registered'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      ageDays: json['ageDays'] is num ? (json['ageDays'] as num).toInt() : null,
    );
  }

  static const empty = DomainAgeLookupResult(
    supported: false,
    registered: false,
  );
}
