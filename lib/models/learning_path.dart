class LearningPath {
  final String id;
  final String name;
  final String description;
  final String language;
  final String level;
  final String category;
  final String? imageUrl;
  final int estimatedHours;
  final int totalLessons;
  final bool isOfficial;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearningPath({
    required this.id,
    required this.name,
    required this.description,
    required this.language,
    required this.level,
    required this.category,
    this.imageUrl,
    required this.estimatedHours,
    required this.totalLessons,
    required this.isOfficial,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'language': language,
    'level': level,
    'category': category,
    'imageUrl': imageUrl,
    'estimatedHours': estimatedHours,
    'totalLessons': totalLessons,
    'isOfficial': isOfficial,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory LearningPath.fromJson(Map<String, dynamic> json) => LearningPath(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    language: json['language'] as String,
    level: json['level'] as String,
    category: json['category'] as String,
    imageUrl: json['imageUrl'] as String?,
    estimatedHours: json['estimatedHours'] as int,
    totalLessons: json['totalLessons'] as int,
    isOfficial: json['isOfficial'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  LearningPath copyWith({
    String? id,
    String? name,
    String? description,
    String? language,
    String? level,
    String? category,
    String? imageUrl,
    int? estimatedHours,
    int? totalLessons,
    bool? isOfficial,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LearningPath(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    language: language ?? this.language,
    level: level ?? this.level,
    category: category ?? this.category,
    imageUrl: imageUrl ?? this.imageUrl,
    estimatedHours: estimatedHours ?? this.estimatedHours,
    totalLessons: totalLessons ?? this.totalLessons,
    isOfficial: isOfficial ?? this.isOfficial,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningPath &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'LearningPath(id: $id, name: $name, language: $language, level: $level)';
}