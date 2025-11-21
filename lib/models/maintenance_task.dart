import 'package:flutter/material.dart';

class MaintenanceTask {
  const MaintenanceTask({
    required this.id,
    required this.podId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  });

  final String id;
  final String podId;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;

  MaintenanceTask copyWith({
    String? id,
    String? podId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
  }) {
    return MaintenanceTask(
      id: id ?? this.id,
      podId: podId ?? this.podId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

enum TaskPriority { low, medium, high }

extension TaskPriorityLabel on TaskPriority {
  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }
}
