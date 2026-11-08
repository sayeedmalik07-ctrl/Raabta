/// Local recent Global Search query (S8).
class SearchRecentQuery {
  const SearchRecentQuery({
    required this.text,
    required this.recordedAt,
  });

  final String text;
  final DateTime recordedAt;
}
