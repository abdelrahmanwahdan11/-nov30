import 'package:flutter/material.dart';

class ScheduleRule {
  ScheduleRule({
    required this.id,
    required this.podId,
    required this.startTime,
    required this.durationMinutes,
    required this.daysOfWeek,
    this.label = '',
    this.isEnabled = true,
  });

  final String id;
  final String podId;
  final TimeOfDay startTime;
  final int durationMinutes;
  final List<int> daysOfWeek;
  final String label;
  final bool isEnabled;

  ScheduleRule copyWith({
    String? id,
    String? podId,
    TimeOfDay? startTime,
    int? durationMinutes,
    List<int>? daysOfWeek,
    String? label,
    bool? isEnabled,
  }) {
    return ScheduleRule(
      id: id ?? this.id,
      podId: podId ?? this.podId,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      daysOfWeek: daysOfWeek ?? List.of(this.daysOfWeek),
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
