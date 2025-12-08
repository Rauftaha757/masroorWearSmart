# Flutter Backend Integration Guide

## Overview

This guide explains how to integrate your Flutter wardrobe app with the Node.js backend API.

## Backend Setup

### 1. Start Your Backend Server

```bash
# Navigate to your backend directory
cd your-backend-directory

# Install dependencies
npm install

# Start the server
npm run dev
```

The backend should be running on `http://localhost:3000`

### 2. Verify Backend is Running

Open your browser and go to:

- `http://localhost:3000/api/health` - Should return health status
- `http://localhost:3000/api/clothing/categories` - Should return clothing categories

## Flutter Integration

### 1. Configuration

The app is configured to connect to `http://localhost:3000/api` by default.

To change the backend URL, edit `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  // For development
  static const String baseUrl = 'http://localhost:3000/api';

  // For production
  // static const String baseUrl = 'https://your-backend-url.com/api';
}
```

### 2. Authentication Flow

The app uses JWT tokens stored in Flutter Secure Storage:

1. **Login**: User enters credentials → Backend returns access & refresh tokens
2. **Token Storage**: Tokens stored securely in device storage
3. **API Calls**: Access token sent with each request
4. **Token Refresh**: Automatically refreshes when access token expires
5. **Logout**: Clears all stored tokens

### 3. Clothing Upload Flow

1. User taps on clothing category
2. Image picker opens (camera or gallery)
3. Image uploaded to Cloudinary via backend
4. Backend stores image URL in MongoDB
5. Success message shown to user

## Testing the Integration

### 1. Run Integration Tests

Add this to your main.dart for testing:

```dart
import 'package:samrtwhere/core/services/integration_test.dart';

// In your main function
void main() {
  runApp(MyApp());

  // Run integration tests
  IntegrationTest.runAllTests();
}
```

### 2. Test Authentication

```dart
// Test login
final loginRequest = LoginRequest(
  email: 'test@example.com',
  password: 'password123',
);
final authResponse = await AuthService().login(loginRequest);
```

### 3. Test Clothing Upload

```dart
// Test clothing upload
final uploadRequest = ClothingUploadRequest(
  name: 'T-Shirt',
  category: 't-shirt',
  gender: 'men',
  imageFile: File('path/to/image.jpg'),
  description: 'Test upload',
);
final uploadedItem = await ClothingApiService().uploadClothingItem(uploadRequest);
```

## API Endpoints Used

### Authentication

- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - User logout
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update user profile

### Clothing

- `POST /api/clothing/upload` - Upload clothing item
- `GET /api/clothing/items` - Get clothing items
- `GET /api/clothing/items/:id` - Get specific clothing item
- `PUT /api/clothing/items/:id` - Update clothing item
- `DELETE /api/clothing/items/:id` - Delete clothing item
- `GET /api/clothing/categories` - Get clothing categories

## Error Handling

The app handles various error scenarios:

1. **Network Errors**: Shows user-friendly error messages
2. **Authentication Errors**: Redirects to login screen
3. **Upload Errors**: Shows specific error messages
4. **Token Expiry**: Automatically refreshes tokens

## Security Features

1. **JWT Tokens**: Secure authentication
2. **Secure Storage**: Tokens stored securely on device
3. **HTTPS**: Production backend should use HTTPS
4. **Input Validation**: All inputs validated before sending

## Troubleshooting

### Common Issues

1. **Connection Refused**

   - Check if backend server is running
   - Verify the URL in `api_config.dart`

2. **Authentication Failed**

   - Check if user exists in database
   - Verify JWT secret in backend

3. **Upload Failed**

   - Check Cloudinary configuration
   - Verify file size limits

4. **Token Expired**
   - Check token expiry settings
   - Verify refresh token logic

### Debug Mode

Enable debug logging by adding this to your main.dart:

```dart
import 'package:flutter/foundation.dart';

void main() {
  if (kDebugMode) {
    print('Debug mode enabled');
  }
  runApp(MyApp());
}
```

## Production Deployment

### 1. Update Backend URL

Change the URL in `api_config.dart` to your production backend:

```dart
static const String baseUrl = 'https://your-production-backend.com/api';
```

### 2. Enable HTTPS

Ensure your production backend uses HTTPS for security.

### 3. Update Cloudinary Settings

Configure Cloudinary for production with proper security settings.

## Support

If you encounter issues:

1. Check the console logs for error messages
2. Verify backend server is running
3. Test API endpoints directly with Postman
4. Check network connectivity

## Next Steps

1. **User Registration**: Implement user registration flow
2. **Profile Management**: Add user profile editing
3. **Clothing Management**: Add edit/delete clothing items
4. **Search & Filter**: Implement search and filtering
5. **Offline Support**: Add offline data caching
