# Backend API Documentation for SmartWhere App

## Overview

This document outlines the complete API structure for the SmartWhere Flutter app backend. The backend should be built with Node.js, Express, and MongoDB.

## Base URL

```
https://your-backend-url.com/api
```

## Authentication

### 1. User Registration

**POST** `/auth/register`

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "John Doe",
  "phone": "+1234567890",
  "gender": "male"
}
```

**Response (201):**

```json
{
  "user": {
    "_id": "user_id",
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+1234567890",
    "gender": "male",
    "avatar": null,
    "isEmailVerified": false,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  },
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "tokenType": "Bearer",
  "expiresIn": 3600
}
```

### 2. User Login

**POST** `/auth/login`

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**

```json
{
  "user": {
    "_id": "user_id",
    "email": "user@example.com",
    "name": "John Doe",
    "phone": "+1234567890",
    "gender": "male",
    "avatar": "https://example.com/avatar.jpg",
    "isEmailVerified": true,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  },
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "tokenType": "Bearer",
  "expiresIn": 3600
}
```

### 3. Token Refresh

**POST** `/auth/refresh`

**Request Body:**

```json
{
  "refreshToken": "jwt_refresh_token"
}
```

**Response (200):**

```json
{
  "accessToken": "new_jwt_access_token",
  "refreshToken": "new_jwt_refresh_token",
  "tokenType": "Bearer",
  "expiresIn": 3600
}
```

### 4. Logout

**POST** `/auth/logout`

**Headers:**

```
Authorization: Bearer <refresh_token>
```

**Response (200):**

```json
{
  "message": "Logged out successfully"
}
```

### 5. Forgot Password

**POST** `/auth/forgot-password`

**Request Body:**

```json
{
  "email": "user@example.com"
}
```

**Response (200):**

```json
{
  "message": "Password reset email sent"
}
```

### 6. Reset Password

**POST** `/auth/reset-password`

**Request Body:**

```json
{
  "token": "reset_token",
  "password": "new_password"
}
```

**Response (200):**

```json
{
  "message": "Password reset successfully"
}
```

### 7. Email Verification

**POST** `/auth/verify-email`

**Request Body:**

```json
{
  "token": "verification_token"
}
```

**Response (200):**

```json
{
  "message": "Email verified successfully"
}
```

### 8. Resend Verification Email

**POST** `/auth/resend-verification`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200):**

```json
{
  "message": "Verification email sent"
}
```

## User Management

### 1. Get User Profile

**GET** `/user/profile`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200):**

```json
{
  "_id": "user_id",
  "email": "user@example.com",
  "name": "John Doe",
  "phone": "+1234567890",
  "gender": "male",
  "avatar": "https://example.com/avatar.jpg",
  "isEmailVerified": true,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### 2. Update User Profile

**PUT** `/user/profile`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Request Body:**

```json
{
  "name": "John Smith",
  "phone": "+1234567891",
  "gender": "male"
}
```

**Response (200):**

```json
{
  "_id": "user_id",
  "email": "user@example.com",
  "name": "John Smith",
  "phone": "+1234567891",
  "gender": "male",
  "avatar": "https://example.com/avatar.jpg",
  "isEmailVerified": true,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T12:00:00.000Z"
}
```

### 3. Change Password

**PUT** `/user/change-password`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Request Body:**

```json
{
  "currentPassword": "old_password",
  "newPassword": "new_password"
}
```

**Response (200):**

```json
{
  "message": "Password changed successfully"
}
```

### 4. Upload Avatar

**POST** `/user/avatar`

**Headers:**

```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Request Body:**

```
avatar: <image_file>
```

**Response (200):**

```json
{
  "_id": "user_id",
  "email": "user@example.com",
  "name": "John Doe",
  "phone": "+1234567890",
  "gender": "male",
  "avatar": "https://example.com/new_avatar.jpg",
  "isEmailVerified": true,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T12:00:00.000Z"
}
```

### 5. Delete Account

**DELETE** `/user/account`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200):**

```json
{
  "message": "Account deleted successfully"
}
```

## Clothing Management

### 1. Upload Clothing Item

**POST** `/clothing/upload`

**Headers:**

```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Request Body:**

```
image: <image_file>
name: "Blue T-Shirt"
category: "t-shirt"
gender: "men"
description: "Comfortable cotton t-shirt"
brand: "Nike"
color: "Blue"
size: "M"
season: "Summer"
tags: ["casual", "cotton"]
```

**Response (201):**

```json
{
  "_id": "clothing_id",
  "name": "Blue T-Shirt",
  "category": "t-shirt",
  "gender": "men",
  "imageUrl": "https://example.com/clothing_image.jpg",
  "description": "Comfortable cotton t-shirt",
  "brand": "Nike",
  "color": "Blue",
  "size": "M",
  "season": "Summer",
  "tags": ["casual", "cotton"],
  "isFavorite": false,
  "userId": "user_id",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### 2. Get Clothing Items

**GET** `/clothing`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Query Parameters:**

- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)
- `category` (optional): Filter by category
- `gender` (optional): Filter by gender
- `brand` (optional): Filter by brand
- `color` (optional): Filter by color
- `season` (optional): Filter by season
- `isFavorite` (optional): Filter by favorite status
- `tags` (optional): Filter by tags (comma-separated)
- `sortBy` (optional): Sort field (createdAt, name, etc.)
- `sortOrder` (optional): Sort order (asc, desc)

**Response (200):**

```json
{
  "items": [
    {
      "_id": "clothing_id",
      "name": "Blue T-Shirt",
      "category": "t-shirt",
      "gender": "men",
      "imageUrl": "https://example.com/clothing_image.jpg",
      "description": "Comfortable cotton t-shirt",
      "brand": "Nike",
      "color": "Blue",
      "size": "M",
      "season": "Summer",
      "tags": ["casual", "cotton"],
      "isFavorite": false,
      "userId": "user_id",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 20,
  "hasNext": false,
  "hasPrev": false
}
```

### 3. Get Single Clothing Item

**GET** `/clothing/:id`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200):**

```json
{
  "_id": "clothing_id",
  "name": "Blue T-Shirt",
  "category": "t-shirt",
  "gender": "men",
  "imageUrl": "https://example.com/clothing_image.jpg",
  "description": "Comfortable cotton t-shirt",
  "brand": "Nike",
  "color": "Blue",
  "size": "M",
  "season": "Summer",
  "tags": ["casual", "cotton"],
  "isFavorite": false,
  "userId": "user_id",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### 4. Update Clothing Item

**PUT** `/clothing/:id`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Request Body:**

```json
{
  "name": "Updated T-Shirt",
  "description": "Updated description",
  "brand": "Adidas",
  "color": "Red",
  "size": "L",
  "season": "Winter",
  "tags": ["sport", "warm"]
}
```

**Response (200):**

```json
{
  "_id": "clothing_id",
  "name": "Updated T-Shirt",
  "category": "t-shirt",
  "gender": "men",
  "imageUrl": "https://example.com/clothing_image.jpg",
  "description": "Updated description",
  "brand": "Adidas",
  "color": "Red",
  "size": "L",
  "season": "Winter",
  "tags": ["sport", "warm"],
  "isFavorite": false,
  "userId": "user_id",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T12:00:00.000Z"
}
```

### 5. Delete Clothing Item

**DELETE** `/clothing/:id`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200):**

```json
{
  "message": "Clothing item deleted successfully"
}
```

### 6. Toggle Favorite

**PATCH** `/clothing/:id/favorite`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200):**

```json
{
  "_id": "clothing_id",
  "name": "Blue T-Shirt",
  "category": "t-shirt",
  "gender": "men",
  "imageUrl": "https://example.com/clothing_image.jpg",
  "description": "Comfortable cotton t-shirt",
  "brand": "Nike",
  "color": "Blue",
  "size": "M",
  "season": "Summer",
  "tags": ["casual", "cotton"],
  "isFavorite": true,
  "userId": "user_id",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T12:00:00.000Z"
}
```

### 7. Search Clothing Items

**GET** `/clothing/search`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Query Parameters:**

- `q`: Search query
- `page` (optional): Page number
- `limit` (optional): Items per page
- All other filter parameters from GET /clothing

**Response (200):**

```json
{
  "items": [...],
  "total": 1,
  "page": 1,
  "limit": 20,
  "hasNext": false,
  "hasPrev": false
}
```

### 8. Get Clothing Statistics

**GET** `/clothing/stats`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200):**

```json
{
  "totalItems": 25,
  "categories": {
    "t-shirt": 5,
    "jeans": 3,
    "shirt": 4,
    "jacket": 2
  },
  "favorites": 8,
  "recentUploads": 3
}
```

### 9. Get Categories

**GET** `/clothing/categories`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200):**

```json
{
  "categories": [
    "t-shirt",
    "jeans",
    "shirt",
    "jacket",
    "hoodie",
    "trousers",
    "shorts",
    "sweater",
    "pants",
    "kurta",
    "coat",
    "capris",
    "dupatta",
    "kurtas",
    "leggings",
    "puffer_jacket",
    "tops",
    "cotton pants"
  ]
}
```

### 10. Get Brands

**GET** `/clothing/brands`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200):**

```json
{
  "brands": ["Nike", "Adidas", "Zara", "H&M", "Uniqlo"]
}
```

### 11. Bulk Delete Clothing Items

**DELETE** `/clothing/bulk`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Request Body:**

```json
{
  "ids": ["clothing_id_1", "clothing_id_2", "clothing_id_3"]
}
```

**Response (200):**

```json
{
  "message": "3 clothing items deleted successfully"
}
```

## Error Responses

All endpoints return appropriate HTTP status codes and error messages:

**400 Bad Request:**

```json
{
  "message": "Validation error",
  "errors": {
    "email": "Email is required",
    "password": "Password must be at least 6 characters"
  }
}
```

**401 Unauthorized:**

```json
{
  "message": "Invalid credentials"
}
```

**403 Forbidden:**

```json
{
  "message": "Access denied"
}
```

**404 Not Found:**

```json
{
  "message": "Resource not found"
}
```

**500 Internal Server Error:**

```json
{
  "message": "Internal server error"
}
```

## Database Schema

### User Collection

```javascript
{
  _id: ObjectId,
  email: String (unique, required),
  password: String (hashed, required),
  name: String (required),
  phone: String,
  gender: String,
  avatar: String,
  isEmailVerified: Boolean (default: false),
  createdAt: Date,
  updatedAt: Date
}
```

### Clothing Collection

```javascript
{
  _id: ObjectId,
  name: String (required),
  category: String (required),
  gender: String (required),
  imageUrl: String (required),
  description: String,
  brand: String,
  color: String,
  size: String,
  season: String,
  tags: [String],
  isFavorite: Boolean (default: false),
  userId: ObjectId (required, ref: 'User'),
  createdAt: Date,
  updatedAt: Date
}
```

## JWT Token Configuration

- **Access Token**: 1 hour expiry
- **Refresh Token**: 7 days expiry
- **Algorithm**: HS256
- **Secret**: Use environment variable

## File Upload Configuration

- **Max file size**: 10MB
- **Allowed formats**: jpg, jpeg, png, webp
- **Storage**: AWS S3 or similar cloud storage
- **Image processing**: Resize to max 1920x1080

## Environment Variables

```env
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://localhost:27017/smartwhere
JWT_SECRET=your_jwt_secret
JWT_REFRESH_SECRET=your_refresh_secret
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
AWS_BUCKET_NAME=your_bucket_name
AWS_REGION=your_region
EMAIL_SERVICE_API_KEY=your_email_api_key
```

This documentation provides everything needed to build the complete backend API for the SmartWhere Flutter app.
