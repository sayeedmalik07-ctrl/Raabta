class LinkUnrollResult {
  const LinkUnrollResult({
    required this.resolved,
    required this.hops,
    required this.chain,
    this.finalRegistrableDomain,
    this.finalTld,
    this.https = false,
    this.truncatedReason,
  });

  final bool resolved;
  final int hops;
  final List<String> chain;
  final String? finalRegistrableDomain;
  final String? finalTld;
  final bool https;
  final String? truncatedReason;

  static const empty = LinkUnrollResult(resolved: false, hops: 0, chain: []);

  factory LinkUnrollResult.fromJson(Map<String, dynamic> json) {
    return LinkUnrollResult(
      resolved: json['resolved'] == true,
      hops: (json['hops'] as num?)?.toInt() ?? 0,
      chain: (json['chain'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .where((s) => s.isNotEmpty)
          .toList(),
      finalRegistrableDomain: json['finalRegistrableDomain']?.toString(),
      finalTld: json['finalTld']?.toString(),
      https: json['https'] == true,
      truncatedReason: json['truncatedReason']?.toString(),
    );
  }
}
