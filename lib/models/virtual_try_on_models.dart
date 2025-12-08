import 'dart:io';

/// Model for Virtual Try-On request
class VirtualTryOnRequest {
  final File personImage;
  final File garmentImage;
  final ClothType clothType;

  VirtualTryOnRequest({
    required this.personImage,
    required this.garmentImage,
    required this.clothType,
  });

  /// Convert clothType enum to API string
  String get clothTypeString {
    switch (clothType) {
      case ClothType.upper:
        return 'upper';
      case ClothType.lower:
        return 'lower';
    }
  }
}

/// Enum for cloth type
enum ClothType { upper, lower }

/// Model for Virtual Try-On response
class VirtualTryOnResponse {
  final String resultImageUrl;
  final DateTime processedAt;

  VirtualTryOnResponse({
    required this.resultImageUrl,
    required this.processedAt,
  });

  factory VirtualTryOnResponse.fromUrl(String url) {
    return VirtualTryOnResponse(
      resultImageUrl: url,
      processedAt: DateTime.now(),
    );
  }
}

/// Model for Virtual Try-On progress
class VirtualTryOnProgress {
  final double progress; // 0.0 to 1.0
  final String? statusMessage;

  VirtualTryOnProgress({required this.progress, this.statusMessage});
}
