/// Vertical identifiers for the unified post engine.
enum PostVertical {
  housing('housing'),
  jobs('jobs'),
  business('business'),
  services('services'),
  marketplace('marketplace');

  const PostVertical(this.id);
  final String id;

  static PostVertical? fromId(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final v in PostVertical.values) {
      if (v.id == raw) return v;
    }
    return null;
  }
}
