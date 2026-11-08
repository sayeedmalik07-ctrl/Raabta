import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:raabta/features/quick_actions/scanner/utils/document_paths.dart';

/// Resolves local image paths, downloading cloud [pageUrls] when needed.
class DocumentPathResolver {
  DocumentPathResolver({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final _urlCache = <String, String>{};

  /// Remote URLs from a vault document (pageUrls + imageUrl fallback).
  static List<String> remoteUrlsFor(Map<String, dynamic> data) {
    final urls = <String>[];
    final pageUrls =
        (data['pageUrls'] as List?)?.cast<String>() ?? const <String>[];
    for (final url in pageUrls) {
      if (url.startsWith('http') && !urls.contains(url)) {
        urls.add(url);
      }
    }
    if (urls.isEmpty) {
      final imageUrl = data['imageUrl'] as String? ?? '';
      if (imageUrl.startsWith('http')) urls.add(imageUrl);
    }
    return urls;
  }

  /// Sync count of pages available locally or remotely.
  static int pageCountFor(Map<String, dynamic> data) {
    final local = resolveDocumentImagePaths(data);
    if (local.isNotEmpty) return local.length;
    return remoteUrlsFor(data).length;
  }

  Future<List<String>> resolvePaths(Map<String, dynamic> data) async {
    final local = resolveDocumentImagePaths(data);
    if (local.isNotEmpty) return local;

    final remote = remoteUrlsFor(data);
    if (remote.isEmpty) return const [];

    final paths = <String>[];
    for (var i = 0; i < remote.length; i++) {
      final path = await _downloadToCache(remote[i], i);
      if (path != null) paths.add(path);
    }
    return paths;
  }

  Future<List<String>> resolvePathsFromDocuments(
    Iterable<Map<String, dynamic>> documents,
  ) async {
    final paths = <String>[];
    for (final data in documents) {
      paths.addAll(await resolvePaths(data));
    }
    return paths;
  }

  Future<String?> _downloadToCache(String url, int index) async {
    final cached = _urlCache[url];
    if (cached != null && File(cached).existsSync()) return cached;

    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final dir = await getTemporaryDirectory();
      final hash = url.hashCode.abs();
      final file = File('${dir.path}/raabta_doc_${hash}_$index.jpg');
      await file.writeAsBytes(response.bodyBytes, flush: true);
      _urlCache[url] = file.path;
      return file.path;
    } catch (_) {
      return null;
    }
  }
}

final documentPathResolverProvider = Provider<DocumentPathResolver>(
  (ref) => DocumentPathResolver(),
);
