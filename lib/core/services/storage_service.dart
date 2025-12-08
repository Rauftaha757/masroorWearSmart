import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry_iso8601';

  // Initialize storage
  static Future<void> initialize() async {
    try {
      // Test if storage is working by trying to read a non-existent key
      await _storage.read(key: 'test_key');
      print('Flutter Secure Storage initialized successfully');
    } catch (e) {
      print('Error initializing Flutter Secure Storage: $e');
      rethrow;
    }
  }

  // Store access token
  static Future<void> storeAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  // Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Store refresh token
  static Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Store user data
  static Future<void> storeUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
  }

  // Get user data
  static Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  // Store token expiry as ISO-8601 string
  static Future<void> storeTokenExpiry(String iso8601Expiry) async {
    await _storage.write(key: _tokenExpiryKey, value: iso8601Expiry);
  }

  // Get token expiry ISO-8601 string
  static Future<String?> getTokenExpiry() async {
    return await _storage.read(key: _tokenExpiryKey);
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Clear specific key
  static Future<void> clearKey(String key) async {
    await _storage.delete(key: key);
  }

  // Check if key exists
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Get all keys
  static Future<Map<String, String>> getAllKeys() async {
    return await _storage.readAll();
  }
}
