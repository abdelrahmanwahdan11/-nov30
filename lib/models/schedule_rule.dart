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
}
