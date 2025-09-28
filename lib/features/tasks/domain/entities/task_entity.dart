class TaskEntity {
  final String id;
  final String title;
  final String? description;
  final DateTime deadline;
  final bool isCompleted;
  final DateTime? completedAt;

  TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.deadline,
    this.isCompleted = false,
    this.completedAt,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory TaskEntity.fromMap(Map<String, dynamic> map) {
    return TaskEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int),
      isCompleted: (map['is_completed'] as int) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
    );
  }
}
