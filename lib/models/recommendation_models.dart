class MenRecommendationRequest {
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final String weatherCondition;
  final String timeOfDay;
  final String season;
  final String? mood;
  final String occasion;

  MenRecommendationRequest({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCondition,
    required this.timeOfDay,
    required this.season,
    this.mood,
    required this.occasion,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'temperature': temperature,
      'feels_like': feelsLike,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'weather_condition': weatherCondition,
      'time_of_day': timeOfDay,
      'season': season,
      'occasion': occasion,
    };
    if (mood != null) {
      data['mood'] = mood;
    }
    return data;
  }
}

class WomenRecommendationRequest {
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final String weatherCondition;
  final String timeOfDay;
  final String season;
  final String occasion;

  WomenRecommendationRequest({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCondition,
    required this.timeOfDay,
    required this.season,
    required this.occasion,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feels_like': feelsLike,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'weather_condition': weatherCondition,
      'time_of_day': timeOfDay,
      'season': season,
      'occasion': occasion,
    };
  }
}

class OutfitResponse {
  final String top;
  final String bottom;
  final String outer;

  OutfitResponse({
    required this.top,
    required this.bottom,
    required this.outer,
  });

  factory OutfitResponse.fromJson(Map<String, dynamic> json) {
    return OutfitResponse(
      top: json['top'] ?? '',
      bottom: json['bottom'] ?? '',
      outer: json['outer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'top': top, 'bottom': bottom, 'outer': outer};
  }
}

class CloudImageData {
  final String url;
  final String? label;
  final String? gender;

  CloudImageData({required this.url, this.label, this.gender});

  factory CloudImageData.fromJson(Map<String, dynamic> json) {
    return CloudImageData(
      url: json['url'] ?? json['imageUrl'] ?? '',
      label: json['label'],
      gender: json['gender'],
    );
  }
}

class CloudImagesResponse {
  final int count;
  final List<CloudImageData> images;

  CloudImagesResponse({required this.count, required this.images});

  factory CloudImagesResponse.fromJson(Map<String, dynamic> json) {
    // API returns 'items' but we'll also check for 'images' or 'data' for compatibility
    final imagesList = json['items'] ?? json['images'] ?? json['data'] ?? [];
    return CloudImagesResponse(
      count: json['count'] ?? (imagesList as List).length,
      images: (imagesList as List)
          .map((item) => CloudImageData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
