import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../../models/clothing_backend_model.dart';
import 'auth_service.dart';
import '../config/api_config.dart';

class ClothingApiService {
  static const String _baseUrl = ApiConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Upload clothing item with image
  Future<ClothingItemBackend> uploadClothingItem(
    ClothingUploadRequest request,
  ) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final multipartRequest = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/clothing/upload'),
      );

      multipartRequest.headers['Authorization'] = 'Bearer $token';

      // Add image file
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('image', request.imageFile.path),
      );

      // Add other fields
      multipartRequest.fields.addAll({
        'name': request.name,
        'category': request.category,
        'gender': request.gender,
        if (request.description != null) 'description': request.description!,
        if (request.brand != null) 'brand': request.brand!,
        if (request.color != null) 'color': request.color!,
        if (request.size != null) 'size': request.size!,
        if (request.season != null) 'season': request.season!,
        if (request.tags != null) 'tags': jsonEncode(request.tags!),
      });

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ClothingItemBackend.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  // Get user's clothing items
  Future<ClothingResponse> getClothingItems({
    ClothingFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (filter != null) {
        if (filter.category != null) queryParams['category'] = filter.category!;
        if (filter.gender != null) queryParams['gender'] = filter.gender!;
        if (filter.brand != null) queryParams['brand'] = filter.brand!;
        if (filter.color != null) queryParams['color'] = filter.color!;
        if (filter.season != null) queryParams['season'] = filter.season!;
        if (filter.isFavorite != null)
          queryParams['isFavorite'] = filter.isFavorite.toString();
        if (filter.tags != null) queryParams['tags'] = filter.tags!.join(',');
        if (filter.sortBy != null) queryParams['sortBy'] = filter.sortBy!;
        if (filter.sortOrder != null)
          queryParams['sortOrder'] = filter.sortOrder!;
      }

      final uri = Uri.parse(
        '$_baseUrl/clothing',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ClothingResponse.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch clothing items');
      }
    } catch (e) {
      throw Exception('Failed to fetch clothing items: $e');
    }
  }

  // Get single clothing item
  Future<ClothingItemBackend> getClothingItem(String id) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.get(
        Uri.parse('$_baseUrl/clothing/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClothingItemBackend.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch clothing item');
      }
    } catch (e) {
      throw Exception('Failed to fetch clothing item: $e');
    }
  }

  // Update clothing item
  Future<ClothingItemBackend> updateClothingItem(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.put(
        Uri.parse('$_baseUrl/clothing/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClothingItemBackend.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Update failed');
      }
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  // Delete clothing item
  Future<void> deleteClothingItem(String id) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.delete(
        Uri.parse('$_baseUrl/clothing/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Delete failed');
      }
    } catch (e) {
      throw Exception('Delete failed: $e');
    }
  }

  // Toggle favorite status
  Future<ClothingItemBackend> toggleFavorite(String id) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.patch(
        Uri.parse('$_baseUrl/clothing/$id/favorite'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClothingItemBackend.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Toggle favorite failed');
      }
    } catch (e) {
      throw Exception('Toggle favorite failed: $e');
    }
  }

  // Search clothing items
  Future<ClothingResponse> searchClothingItems(
    String query, {
    ClothingFilter? filter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (filter != null) {
        if (filter.category != null) queryParams['category'] = filter.category!;
        if (filter.gender != null) queryParams['gender'] = filter.gender!;
        if (filter.brand != null) queryParams['brand'] = filter.brand!;
        if (filter.color != null) queryParams['color'] = filter.color!;
        if (filter.season != null) queryParams['season'] = filter.season!;
        if (filter.isFavorite != null)
          queryParams['isFavorite'] = filter.isFavorite.toString();
        if (filter.tags != null) queryParams['tags'] = filter.tags!.join(',');
        if (filter.sortBy != null) queryParams['sortBy'] = filter.sortBy!;
        if (filter.sortOrder != null)
          queryParams['sortOrder'] = filter.sortOrder!;
      }

      final uri = Uri.parse(
        '$_baseUrl/clothing/search',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ClothingResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Search failed');
      }
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // Get clothing statistics
  Future<Map<String, dynamic>> getClothingStats() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.get(
        Uri.parse('$_baseUrl/clothing/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch statistics');
      }
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }

  // Get categories
  Future<List<String>> getCategories() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.get(
        Uri.parse('$_baseUrl/clothing/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dynamic maybeWrapped = data is Map<String, dynamic>
            ? (data['data'] ?? data)
            : data;
        final categories = (maybeWrapped is Map<String, dynamic>
            ? (maybeWrapped['categories'] ?? [])
            : []);
        return List<String>.from(categories);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Upload one asset image for each available backend category
  // Useful for emulator testing when camera/gallery is unavailable
  Future<void> uploadAssetsForAllCategories({String gender = 'men'}) async {
    try {
      print('Starting asset upload seeding...');
      final categories = await getCategories();
      print('Fetched categories: ' + categories.join(', '));
      if (categories.isEmpty) {
        throw Exception('No categories returned by backend');
      }

      // Cycle through available bundled asset images
      final assetPaths = <String>[
        'assets/images/avatar.png',
        'assets/images/avatar2.png',
        'assets/images/avat3.png',
        'assets/images/try1.png',
        'assets/images/try2.png',
      ];

      for (var i = 0; i < categories.length; i++) {
        final category = categories[i];
        final assetPath = assetPaths[i % assetPaths.length];

        // Load asset bytes and write to a temporary file (no path_provider needed)
        print(
          'Preparing upload for category: ' + category + ' using ' + assetPath,
        );
        final byteData = await rootBundle.load(assetPath);
        final tempDir = await Directory.systemTemp.createTemp('samrtwhere_');
        final tempFilePath =
            '${tempDir.path}${Platform.pathSeparator}${category.replaceAll(' ', '_').toLowerCase()}.png';
        final file = File(tempFilePath);
        await file.writeAsBytes(byteData.buffer.asUint8List());

        final request = ClothingUploadRequest(
          name: '${category} asset test',
          category: category,
          gender: gender,
          imageFile: file,
          description: 'Seeded from assets for emulator testing',
          tags: ['seed', 'emulator', 'assets'],
        );

        try {
          final uploaded = await uploadClothingItem(request);
          print(
            'Uploaded ${uploaded.name} (${uploaded.category}) from $assetPath',
          );
        } catch (e) {
          print(
            'Failed to upload for category "$category" using $assetPath: $e',
          );
        }
      }
    } catch (e) {
      throw Exception('Asset uploads failed: $e');
    }
  }

  // Get brands
  Future<List<String>> getBrands() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.get(
        Uri.parse('$_baseUrl/clothing/brands'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['brands'] ?? []);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch brands');
      }
    } catch (e) {
      throw Exception('Failed to fetch brands: $e');
    }
  }

  // Bulk delete clothing items
  Future<void> bulkDeleteClothingItems(List<String> ids) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await http.delete(
        Uri.parse('$_baseUrl/clothing/bulk'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'ids': ids}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Bulk delete failed');
      }
    } catch (e) {
      throw Exception('Bulk delete failed: $e');
    }
  }
}
