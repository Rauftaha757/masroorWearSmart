class ClothingItem {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final bool isUploaded;
  final DateTime? uploadDate;

  ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    this.isUploaded = false,
    this.uploadDate,
  });

  ClothingItem copyWith({
    String? id,
    String? name,
    String? category,
    String? imageUrl,
    bool? isUploaded,
    DateTime? uploadDate,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadDate: uploadDate ?? this.uploadDate,
    );
  }
}

class ClothingCategory {
  final String name;
  final String icon;
  final List<ClothingItem> items;

  ClothingCategory({
    required this.name,
    required this.icon,
    required this.items,
  });
}
