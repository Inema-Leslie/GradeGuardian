enum Priority { high, medium, low }

enum AssignmentType { formative, summative }

class Assignment {
  final String id;
  final String title;
  final DateTime dueDate;
  final String course;
  final Priority priority;
  final AssignmentType type;
  final bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.course,
    required this.priority,
    required this.type,
    this.isCompleted = false,
  });

  Assignment copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    String? course,
    Priority? priority,
    AssignmentType? type,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      course: course ?? this.course,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'course': course,
      'priority': priority.index,
      'type': type.index,
      'isCompleted': isCompleted,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      title: json['title'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      course: json['course'] as String,
      priority: Priority.values[json['priority'] as int],
      type: AssignmentType.values[json['type'] as int? ?? 0],
      isCompleted: json['isCompleted'] as bool,
    );
  }
}
