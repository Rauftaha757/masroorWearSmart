import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'clothing_api_service.dart';
import '../../models/user_model.dart';

class IntegrationTest {
  static final AuthService _authService = AuthService();
  static final ClothingApiService _clothingApiService = ClothingApiService();

  // Test authentication
  static Future<void> testAuth() async {
    try {
      print('Testing authentication...');

      // Test login
      final loginRequest = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final authResponse = await _authService.login(loginRequest);
      print('Login successful: ${authResponse.user.email}');

      // Test token refresh
      final refreshResponse = await _authService.refreshToken();
      if (refreshResponse != null) {
        print('Token refresh successful');
      }

      // Test logout
      await _authService.logout();
      print('Logout successful');
    } catch (e) {
      print('Auth test failed: $e');
    }
  }

  // Test clothing upload
  static Future<void> testClothingUpload() async {
    try {
      print('Testing clothing upload...');

      // This would require an actual image file
      // For now, just test the API structure
      print('Clothing upload test structure ready');
    } catch (e) {
      print('Clothing upload test failed: $e');
    }
  }

  // Test all integrations
  static Future<void> runAllTests() async {
    print('Starting integration tests...');

    await testAuth();
    await testClothingUpload();

    print('Integration tests completed');
  }
}

// Widget to run tests from UI
class IntegrationTestWidget extends StatelessWidget {
  const IntegrationTestWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integration Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await IntegrationTest.testAuth();
              },
              child: const Text('Test Authentication'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await IntegrationTest.testClothingUpload();
              },
              child: const Text('Test Clothing Upload'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await IntegrationTest.runAllTests();
              },
              child: const Text('Run All Tests'),
            ),
          ],
        ),
      ),
    );
  }
}
