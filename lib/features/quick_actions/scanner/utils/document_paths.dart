import 'dart:io';

/// Resolves local image paths from a vault document map.
List<String> resolveDocumentImagePaths(Map<String, dynamic> data) {
  final pages = (data['pagePaths'] as List?)?.cast<String>() ?? const [];
  final validPages =
      pages.where((p) => p.isNotEmpty && File(p).existsSync()).toList();
  if (validPages.isNotEmpty) return validPages;

  final local = data['localImagePath'] as String? ?? '';
  if (local.isNotEmpty && File(local).existsSync()) return [local];

  final imageUrl = data['imageUrl'] as String? ?? '';
  if (imageUrl.isNotEmpty &&
      !imageUrl.startsWith('http') &&
      File(imageUrl).existsSync()) {
    return [imageUrl];
  }
  return const [];
}

/// Collects all page paths from multiple vault documents (merge order preserved).
List<String> collectPathsFromDocuments(
  Iterable<Map<String, dynamic>> documents,
) {
  final paths = <String>[];
  for (final data in documents) {
    paths.addAll(resolveDocumentImagePaths(data));
  }
  return paths;
}
