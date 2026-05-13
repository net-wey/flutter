class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final bool isAvailable;
  final int? takenByUserId;
  final DateTime? takenAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    this.isAvailable = true,
    this.takenByUserId,
    this.takenAt,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    bool? isAvailable,
    int? takenByUserId,
    DateTime? takenAt,
    bool clearTakenInfo = false,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      takenByUserId: clearTakenInfo ? null : (takenByUserId ?? this.takenByUserId),
      takenAt: clearTakenInfo ? null : (takenAt ?? this.takenAt),
    );
  }

  factory Product.fromMap(Map<String, Object?> map) {
    final takenAtRaw = map['taken_at'] as String?;
    return Product(
      id: map['id'].toString(),
      name: map['name'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      isAvailable: (map['is_available'] as int) == 1,
      takenByUserId: map['taken_by_user_id'] as int?,
      takenAt: takenAtRaw == null ? null : DateTime.tryParse(takenAtRaw),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'is_available': isAvailable ? 1 : 0,
      'taken_by_user_id': takenByUserId,
      'taken_at': takenAt?.toIso8601String(),
    };
  }
}
