import 'dart:io';

class ClothingItemBackend {
  final String? id;
  final String name;
  final String category;
  final String gender;
  final String? imageUrl;
  final File? imageFile;
  final String? description;
  final String? brand;
  final String? color;
  final String? size;
  final String? season;
  final List<String>? tags;
  final bool isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String userId;

  ClothingItemBackend({
    this.id,
    required this.name,
    required this.category,
    required this.gender,
    this.imageUrl,
    this.imageFile,
    this.description,
    this.brand,
    this.color,
    this.size,
    this.season,
    this.tags,
    this.isFavorite = false,
    this.createdAt,
    this.updatedAt,
    required this.userId,
  });

  factory ClothingItemBackend.fromJson(Map<String, dynamic> json) {
    return ClothingItemBackend(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      gender: json['gender'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'],
      description: json['description'],
      brand: json['brand'],
      color: json['color'],
      size: json['size'],
      season: json['season'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isFavorite: json['isFavorite'] ?? json['is_favorite'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      userId: json['userId'] ?? json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'gender': gender,
      'imageUrl': imageUrl,
      'description': description,
      'brand': brand,
      'color': color,
      'size': size,
      'season': season,
      'tags': tags,
      'isFavorite': isFavorite,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'category': category,
      'gender': gender,
      'description': description,
      'brand': brand,
      'color': color,
      'size': size,
      'season': season,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  ClothingItemBackend copyWith({
    String? id,
    String? name,
    String? category,
    String? gender,
    String? imageUrl,
    File? imageFile,
    String? description,
    String? brand,
    String? color,
    String? size,
    String? season,
    List<String>? tags,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return ClothingItemBackend(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      gender: gender ?? this.gender,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      size: size ?? this.size,
      season: season ?? this.season,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}

class ClothingUploadRequest {
  final String name;
  final String category;
  final String gender;
  final File imageFile;
  final String? description;
  final String? brand;
  final String? color;
  final String? size;
  final String? season;
  final List<String>? tags;

  ClothingUploadRequest({
    required this.name,
    required this.category,
    required this.gender,
    required this.imageFile,
    this.description,
    this.brand,
    this.color,
    this.size,
    this.season,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'gender': gender,
      'description': description,
      'brand': brand,
      'color': color,
      'size': size,
      'season': season,
      'tags': tags,
    };
  }
}

class ClothingResponse {
  final List<ClothingItemBackend> items;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  ClothingResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ClothingResponse.fromJson(Map<String, dynamic> json) {
    return ClothingResponse(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ClothingItemBackend.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      hasNext: json['hasNext'] ?? json['has_next'] ?? false,
      hasPrev: json['hasPrev'] ?? json['has_prev'] ?? false,
    );
  }
}

class ClothingFilter {
  final String? category;
  final String? gender;
  final String? brand;
  final String? color;
  final String? season;
  final List<String>? tags;
  final bool? isFavorite;
  final int? page;
  final int? limit;
  final String? sortBy;
  final String? sortOrder;

  ClothingFilter({
    this.category,
    this.gender,
    this.brand,
    this.color,
    this.season,
    this.tags,
    this.isFavorite,
    this.page,
    this.limit,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'gender': gender,
      'brand': brand,
      'color': color,
      'season': season,
      'tags': tags,
      'isFavorite': isFavorite,
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
  }
}
