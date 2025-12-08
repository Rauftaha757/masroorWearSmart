class ApiConfig {
  // Backend configuration
  // For real device, use your computer's IP address
  static const String baseUrl = 'http://192.168.18.62:3000/api';
  //
  // // For Android emulator, use 10.0.2.2 instead of localhost
  // static const String baseUrl = 'http://10.0.2.2:3000/api';

  // For production, change to your actual backend URL
  // static const String baseUrl = 'https://your-backend-url.com/api';

  // API endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authProfile = '/auth/profile';
  static const String authChangePassword = '/auth/change-password';
  static const String authUploadAvatar = '/auth/upload-avatar';
  static const String authDeleteAccount = '/auth/delete-account';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authResendVerification = '/auth/resend-verification';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';

  // Clothing endpoints
  static const String clothingUpload = '/clothing/upload';
  static const String clothingItems = '/clothing/items';
  static const String clothingItem = '/clothing/items';
  static const String clothingUpdate = '/clothing/items';
  static const String clothingDelete = '/clothing/items';
  static const String clothingToggleFavorite = '/clothing/items';
  static const String clothingSearch = '/clothing/search';
  static const String clothingStats = '/clothing/stats';
  static const String clothingCategories = '/clothing/categories';
  static const String clothingBrands = '/clothing/brands';
  static const String clothingBulkDelete = '/clothing/bulk-delete';

  // Request timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
