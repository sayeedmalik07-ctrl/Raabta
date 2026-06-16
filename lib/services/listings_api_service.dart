import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:raabta/models/housing_models.dart';

class ListingsApiService {
  ListingsApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://localhost:3000';

  final http.Client _client;
  final String _baseUrl;

  Future<List<HousingListing>> fetchListings(HousingFilters filters) async {
    final params = <String, String>{
      'minPrice': filters.minPrice.round().toString(),
      'maxPrice': filters.maxPrice.round().toString(),
    };

    if (filters.area != null && filters.area!.isNotEmpty) {
      params['area'] = areaSlug(filters.area!);
    }
    if (filters.type != ListingType.all) {
      params['type'] = filters.type.name;
    }
    if (filters.gender != GenderPreference.any) {
      params['gender'] = filters.gender.name;
    }
    if (filters.nationality != NationalityPreference.any) {
      params['nationality'] = filters.nationality.name;
    }
    if (filters.searchQuery.trim().isNotEmpty) {
      params['q'] = filters.searchQuery.trim();
    }

    final uri = Uri.parse('$_baseUrl/listings').replace(queryParameters: params);
    final response =
        await _client.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw ListingsApiException('Failed to load listings (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['listings'] as List<dynamic>;
    return items
        .map((e) => HousingListing.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<HousingListing> getListing(String id) async {
    final uri = Uri.parse('$_baseUrl/listings/$id');
    final response =
        await _client.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode == 404) {
      throw ListingsApiException('Listing not found');
    }
    if (response.statusCode != 200) {
      throw ListingsApiException('Failed to load listing');
    }

    return HousingListing.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<HousingListing> createListing(CreateListingRequest request) async {
    final uri = Uri.parse('$_baseUrl/listings');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201 && response.statusCode != 200) {
      final error = jsonDecode(response.body) as Map<String, dynamic>?;
      throw ListingsApiException(
        error?['error'] as String? ?? 'Failed to create listing',
      );
    }

    return HousingListing.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> reportListing(String id, ListingReport report) async {
    final uri = Uri.parse('$_baseUrl/listings/$id/report');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(report.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ListingsApiException('Failed to submit report');
    }
  }

  Future<String> uploadPhoto(File file) async {
    final uri = Uri.parse('$_baseUrl/listings/upload-photo');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('photo', file.path));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ListingsApiException('Photo upload failed');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['url'] as String;
  }
}

class ListingsApiException implements Exception {
  ListingsApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
