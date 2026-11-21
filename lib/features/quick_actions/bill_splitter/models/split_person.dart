class SplitPerson {
  const SplitPerson({
    required this.name,
    required this.currency,
    required this.flag,
    this.id,
  });

  final String? id;
  final String name;
  final String currency;
  final String flag;

  String get stableId => id ?? name;

  SplitPerson copyWith({
    String? id,
    String? name,
    String? currency,
    String? flag,
  }) {
    return SplitPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      flag: flag ?? this.flag,
    );
  }
}
