import 'dart:convert';

class Lesson {
  final String id;
  final String pathId;
  final String name;
  final String description;
  final int orderIndex;
  final int estimatedMinutes;
  final List<String> prerequisites;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lesson({
    required this.id,
    required this.pathId,
    required this.name,
    required this.description,
    required this.orderIndex,
    required this.estimatedMinutes,
    required this.prerequisites,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'pathId': pathId,
    'name': name,
    'description': description,
    'orderIndex': orderIndex,
    'estimatedMinutes': estimatedMinutes,
    'prerequisites': prerequisites,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    pathId: json['pathId'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    orderIndex: json['orderIndex'] as int,
    estimatedMinutes: json['estimatedMinutes'] as int,
    prerequisites: List<String>.from(json['prerequisites'] as List),
    tags: List<String>.from(json['tags'] as List),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  // Helper methods for Drift storage
  String get prerequisitesJson => jsonEncode(prerequisites);
  String get tagsJson => jsonEncode(tags);

  factory Lesson.fromDrift({
    required String id,
    required String pathId,
    required String name,
    required String description,
    required int orderIndex,
    required int estimatedMinutes,
    required String prerequisitesJson,
    required String tagsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) => Lesson(
    id: id,
    pathId: pathId,
    name: name,
    description: description,
    orderIndex: orderIndex,
    estimatedMinutes: estimatedMinutes,
    prerequisites: List<String>.from(jsonDecode(prerequisitesJson) as List),
    tags: List<String>.from(jsonDecode(tagsJson) as List),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  Lesson copyWith({
    String? id,
    String? pathId,
    String? name,
    String? description,
    int? orderIndex,
    int? estimatedMinutes,
    List<String>? prerequisites,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Lesson(
    id: id ?? this.id,
    pathId: pathId ?? this.pathId,
    name: name ?? this.name,
    description: description ?? this.description,
    orderIndex: orderIndex ?? this.orderIndex,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    prerequisites: prerequisites ?? this.prerequisites,
    tags: tags ?? this.tags,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lesson &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Lesson(id: $id, name: $name, pathId: $pathId, orderIndex: $orderIndex)';
}