import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class AuthService {
  static const String _baseUrl = ApiConfig.baseUrl;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Current user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await StorageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Get stored access token
  Future<String?> getAccessToken() async {
    return await StorageService.getAccessToken();
  }

  // Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await StorageService.getRefreshToken();
  }

  // Store authentication data
  Future<void> _storeAuthData(AuthResponse authResponse) async {
    await StorageService.storeAccessToken(authResponse.accessToken);
    await StorageService.storeRefreshToken(authResponse.refreshToken);
    await StorageService.storeUserData(jsonEncode(authResponse.user.toJson()));

    // Store token expiry time in a dedicated key
    final expiryTime = DateTime.now().add(
      Duration(seconds: authResponse.expiresIn),
    );
    await StorageService.storeTokenExpiry(expiryTime.toIso8601String());

    _currentUser = authResponse.user;
  }

  // Clear authentication data
  Future<void> clearAuthData() async {
    await StorageService.clearAll();
    _currentUser = null;
  }

  // Load user from storage
  Future<void> loadUserFromStorage() async {
    try {
      final userJson = await StorageService.getUserData();
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = UserModel.fromJson(userData);
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    }
  }

  // Check if token is expired
  Future<bool> isTokenExpired() async {
    try {
      final expiryString = await StorageService.getTokenExpiry();
      if (expiryString == null) return true;
      final expiryTime = DateTime.parse(expiryString);
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      return true;
    }
  }

  // Login
  Future<AuthResponse> login(LoginRequest loginRequest) async {
    try {
      print('🔗 Making login request to: $_baseUrl/auth/login');
      print('📤 Request data: ${jsonEncode(loginRequest.toJson())}');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginRequest.toJson()),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final authResponse = AuthResponse.fromJson(data['data']);
        await _storeAuthData(authResponse);
        return authResponse;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register
  Future<AuthResponse> register(RegisterRequest registerRequest) async {
    try {
      print('🔗 Making register request to: $_baseUrl/auth/register');
      print('📤 Request data: ${jsonEncode(registerRequest.toJson())}');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registerRequest.toJson()),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final authResponse = AuthResponse.fromJson(data['data']);
        await _storeAuthData(authResponse);
        return authResponse;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $refreshToken',
          },
        );
      }
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      await clearAuthData();
    }
  }

  // Refresh token
  Future<AuthResponse?> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final authResponse = AuthResponse.fromJson(data['data']);
        await _storeAuthData(authResponse);
        return authResponse;
      } else {
        await clearAuthData();
        return null;
      }
    } catch (e) {
      await clearAuthData();
      return null;
    }
  }

  // Get authenticated headers
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Update profile
  Future<UserModel> updateProfile(UpdateProfileRequest updateRequest) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/user/profile'),
        headers: headers,
        body: jsonEncode(updateRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        _currentUser = user;

        // Update stored user data
        await StorageService.storeUserData(jsonEncode(user.toJson()));
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  // Change password
  Future<void> changePassword(
    ChangePasswordRequest changePasswordRequest,
  ) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/user/change-password'),
        headers: headers,
        body: jsonEncode(changePasswordRequest.toJson()),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Password change failed');
      }
    } catch (e) {
      throw Exception('Password change failed: $e');
    }
  }

  // Upload avatar
  Future<UserModel> uploadAvatar(String imagePath) async {
    try {
      final token = await getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/user/avatar'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('avatar', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        _currentUser = user;

        // Update stored user data
        await StorageService.storeUserData(jsonEncode(user.toJson()));
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Avatar upload failed');
      }
    } catch (e) {
      throw Exception('Avatar upload failed: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/user/account'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await clearAuthData();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Account deletion failed');
      }
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  // Verify email
  Future<void> verifyEmail(String verificationToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': verificationToken}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Email verification failed');
      }
    } catch (e) {
      throw Exception('Email verification failed: $e');
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/resend-verification'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to resend verification email',
        );
      }
    } catch (e) {
      throw Exception('Failed to resend verification email: $e');
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to send reset email');
      }
    } catch (e) {
      throw Exception('Failed to send reset email: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'password': newPassword}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
}
