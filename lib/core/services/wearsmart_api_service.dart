import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/recommendation_models.dart';

class WearSmartApiService {
  static const String baseUrl =
      'https://wearsmart-model-production.up.railway.app';

  // Get recommendation for men
  Future<OutfitResponse> getMenRecommendation(
    MenRecommendationRequest request,
  ) async {
    final url = '$baseUrl/recommend/men';
    final requestBody = jsonEncode(request.toJson());

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 API CALL: GET MEN RECOMMENDATION');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 URL: $url');
    print('📦 Request Body:');
    print(jsonEncode(request.toJson()));
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout: API took too long to respond');
            },
          );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body:');
      print(response.body);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully parsed response:');
        print('   Top: ${data['top']}');
        print('   Bottom: ${data['bottom']}');
        print('   Outer: ${data['outer']}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return OutfitResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        print('❌ API Error:');
        print('   ${error['detail'] ?? error['message'] ?? 'Unknown error'}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        throw Exception(
          error['detail'] ?? error['message'] ?? 'Failed to get recommendation',
        );
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      // Provide more helpful error messages
      String errorMessage = 'Failed to get men recommendation';
      if (e.toString().contains('timeout')) {
        errorMessage =
            'Request timeout. Please check your internet connection.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'No internet connection. Please check your network settings.';
      } else if (e.toString().contains('HandshakeException') ||
          e.toString().contains('Certificate')) {
        errorMessage =
            'SSL certificate error. Please check your device date/time settings.';
      }
      throw Exception(errorMessage);
    }
  }

  // Get recommendation for women
  Future<OutfitResponse> getWomenRecommendation(
    WomenRecommendationRequest request,
  ) async {
    final url = '$baseUrl/recommend/women';
    final requestBody = jsonEncode(request.toJson());

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 API CALL: GET WOMEN RECOMMENDATION');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 URL: $url');
    print('📦 Request Body:');
    print(jsonEncode(request.toJson()));
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout: API took too long to respond');
            },
          );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Headers: ${response.headers}');
      print('📥 Response Body:');
      print(response.body);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully parsed response:');
        print('   Top: ${data['top']}');
        print('   Bottom: ${data['bottom']}');
        print('   Outer: ${data['outer']}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return OutfitResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        print('❌ API Error:');
        print('   ${error['detail'] ?? error['message'] ?? 'Unknown error'}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        throw Exception(
          error['detail'] ?? error['message'] ?? 'Failed to get recommendation',
        );
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      // Provide more helpful error messages
      String errorMessage = 'Failed to get women recommendation';
      if (e.toString().contains('timeout')) {
        errorMessage =
            'Request timeout. Please check your internet connection.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'No internet connection. Please check your network settings.';
      } else if (e.toString().contains('HandshakeException') ||
          e.toString().contains('Certificate')) {
        errorMessage =
            'SSL certificate error. Please check your device date/time settings.';
      }
      throw Exception(errorMessage);
    }
  }

  // Get cloud images for a clothing category
  Future<CloudImagesResponse> getCloudImages({
    required String gender,
    required String label,
    int limit = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/cloud-images').replace(
      queryParameters: {
        'gender': gender,
        'label': label,
        'limit': limit.toString(),
      },
    );

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 API CALL: GET CLOUD IMAGES');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 URL: ${uri.toString()}');
    print('📋 Query Parameters:');
    print('   gender: $gender');
    print('   label: $label');
    print('   limit: $limit');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout: API took too long to respond');
            },
          );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body:');
      print(response.body);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imagesResponse = CloudImagesResponse.fromJson(data);
        print('✅ Successfully parsed response:');
        print('   Count: ${imagesResponse.count}');
        print('   Images found: ${imagesResponse.images.length}');
        if (imagesResponse.images.isNotEmpty) {
          print('   First image URL: ${imagesResponse.images.first.url}');
        }
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return imagesResponse;
      } else {
        final error = jsonDecode(response.body);
        print('❌ API Error:');
        print('   ${error['detail'] ?? error['message'] ?? 'Unknown error'}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        throw Exception(
          error['detail'] ?? error['message'] ?? 'Failed to get images',
        );
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Provide more helpful error messages
      String errorMessage = 'Failed to get cloud images';
      if (e.toString().contains('timeout')) {
        errorMessage =
            'Request timeout. Please check your internet connection.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'No internet connection. Please check your network settings.';
      } else if (e.toString().contains('HandshakeException') ||
          e.toString().contains('Certificate')) {
        errorMessage =
            'SSL certificate error. Please check your device date/time settings.';
      }

      throw Exception(errorMessage);
    }
  }

  // Get local images (fallback)
  Future<List<String>> getLocalImages({
    required String gender,
    required String label,
    int limit = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/images').replace(
      queryParameters: {
        'gender': gender,
        'label': label,
        'limit': limit.toString(),
      },
    );

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 API CALL: GET LOCAL IMAGES');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 URL: ${uri.toString()}');
    print('📋 Query Parameters:');
    print('   gender: $gender');
    print('   label: $label');
    print('   limit: $limit');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout: API took too long to respond');
            },
          );

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body:');
      print(response.body);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imagesList = data['images'] ?? data['data'] ?? [];
        final images = (imagesList as List)
            .map((item) => item.toString())
            .toList();
        print('✅ Successfully parsed response:');
        print('   Images found: ${images.length}');
        if (images.isNotEmpty) {
          print('   First image: ${images.first}');
        }
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return images;
      } else {
        print('❌ API Error: Failed to get local images');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        throw Exception('Failed to get local images');
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      // Provide more helpful error messages
      String errorMessage = 'Failed to get local images';
      if (e.toString().contains('timeout')) {
        errorMessage =
            'Request timeout. Please check your internet connection.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'No internet connection. Please check your network settings.';
      } else if (e.toString().contains('HandshakeException') ||
          e.toString().contains('Certificate')) {
        errorMessage =
            'SSL certificate error. Please check your device date/time settings.';
      }
      throw Exception(errorMessage);
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    final url = '$baseUrl/health';

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 API CALL: HEALTH CHECK');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 URL: $url');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final response = await http.get(Uri.parse(url));

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body:');
      print(response.body);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Health check successful');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return data;
      } else {
        print('❌ Health check failed');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        throw Exception('Health check failed');
      }
    } catch (e) {
      print('❌ Exception occurred: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      // Provide more helpful error messages
      String errorMessage = 'Health check failed';
      if (e.toString().contains('timeout')) {
        errorMessage =
            'Request timeout. Please check your internet connection.';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMessage =
            'No internet connection. Please check your network settings.';
      } else if (e.toString().contains('HandshakeException') ||
          e.toString().contains('Certificate')) {
        errorMessage =
            'SSL certificate error. Please check your device date/time settings.';
      }
      throw Exception(errorMessage);
    }
  }
}
