import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ConnectivityTest {
  static Future<void> testBackendConnection() async {
    print('🔍 Testing backend connectivity...');
    print('📍 Backend URL: ${ApiConfig.baseUrl}');

    try {
      // Test basic connectivity by trying the root endpoint
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl.replaceAll('/api', '')}/'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 10));

      print('✅ Backend is reachable!');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.body}');
    } catch (e) {
      print('❌ Backend connection failed!');
      print('🚨 Error: $e');

      // Try alternative URLs
      print('\n🔄 Trying alternative URLs...');

      // Try with localhost
      try {
        final localhostResponse = await http
            .get(
              Uri.parse('http://localhost:3000/health'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(Duration(seconds: 5));

        print('✅ localhost:3000 is reachable!');
        print('📊 Status Code: ${localhostResponse.statusCode}');
      } catch (e) {
        print('❌ localhost:3000 failed: $e');
      }

      // Try with 127.0.0.1
      try {
        final localhostResponse = await http
            .get(
              Uri.parse('http://127.0.0.1:3000/health'),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(Duration(seconds: 5));

        print('✅ 127.0.0.1:3000 is reachable!');
        print('📊 Status Code: ${localhostResponse.statusCode}');
      } catch (e) {
        print('❌ 127.0.0.1:3000 failed: $e');
      }
    }
  }

  static Future<void> testAuthEndpoint() async {
    print('\n🔐 Testing auth endpoint...');

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': 'test@example.com',
              'password': 'testpassword',
            }),
          )
          .timeout(Duration(seconds: 10));

      print('✅ Auth endpoint is reachable!');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.body}');
    } catch (e) {
      print('❌ Auth endpoint failed!');
      print('🚨 Error: $e');
    }
  }
}
