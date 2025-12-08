class LocalClothingItem {
  final int? id;
  final String name;
  final String category;
  final String gender;
  final String imagePath;
  final String description;
  final DateTime createdAt;

  LocalClothingItem({
    this.id,
    required this.name,
    required this.category,
    required this.gender,
    required this.imagePath,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'gender': gender,
      'imagePath': imagePath,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory LocalClothingItem.fromMap(Map<String, dynamic> map) {
    return LocalClothingItem(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      gender: map['gender'] ?? '',
      imagePath: map['imagePath'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  LocalClothingItem copyWith({
    int? id,
    String? name,
    String? category,
    String? gender,
    String? imagePath,
    String? description,
    DateTime? createdAt,
  }) {
    return LocalClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      gender: gender ?? this.gender,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
