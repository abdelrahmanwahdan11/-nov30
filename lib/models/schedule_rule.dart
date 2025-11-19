import 'package:flutter/material.dart';

class ScheduleRule {
  ScheduleRule({
    required this.id,
    required this.podId,
    required this.startTime,
    required this.durationMinutes,
    required this.daysOfWeek,
  });

  final String id;
  final String podId;
  final TimeOfDay startTime;
  final int durationMinutes;
  final List<int> daysOfWeek;

  ScheduleRule copyWith({
    String? id,
    String? podId,
    TimeOfDay? startTime,
    int? durationMinutes,
    List<int>? daysOfWeek,
  }) {
    return ScheduleRule(
      id: id ?? this.id,
      podId: podId ?? this.podId,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      daysOfWeek: daysOfWeek ?? List.of(this.daysOfWeek),
    );
  }
}
