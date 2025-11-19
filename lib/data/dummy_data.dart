import 'package:flutter/material.dart';

import '../models/analytics_point.dart';
import '../models/log_entry.dart';
import '../models/pod.dart';
import '../models/schedule_rule.dart';

final dummyPods = <Pod>[
  Pod(
    id: 'pod-1',
    name: 'Oasis Prime',
    location: 'Greenhouse 01',
    waterLevelPercent: 0.78,
    humidityPercent: 0.64,
    waterTemperature: 23,
    isOnline: true,
    imageUrl: 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6',
  ),
  Pod(
    id: 'pod-2',
    name: 'Desert Bloom',
    location: 'Atrium',
    waterLevelPercent: 0.32,
    humidityPercent: 0.41,
    waterTemperature: 20,
    isOnline: true,
    imageUrl: 'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a',
  ),
  Pod(
    id: 'pod-3',
    name: 'Rain Catcher',
    location: 'Rooftop',
    waterLevelPercent: 0.54,
    humidityPercent: 0.7,
    waterTemperature: 18,
    isOnline: false,
    imageUrl: 'https://images.unsplash.com/photo-1470246973918-29a93221c455',
  ),
];

final dummyRules = <ScheduleRule>[
  ScheduleRule(
    id: 'rule-1',
    podId: 'pod-1',
    startTime: const TimeOfDay(hour: 6, minute: 30),
    durationMinutes: 35,
    daysOfWeek: const [1, 3, 5],
  ),
  ScheduleRule(
    id: 'rule-2',
    podId: 'pod-2',
    startTime: const TimeOfDay(hour: 8, minute: 0),
    durationMinutes: 20,
    daysOfWeek: const [2, 4, 6],
  ),
];

final dummyLogs = List.generate(12, (index) {
  final pod = dummyPods[index % dummyPods.length];
  return LogEntry(
    id: 'log-$index',
    podId: pod.id,
    timestamp: DateTime.now().subtract(Duration(hours: index * 5)),
    message: index.isEven
        ? 'Automatic refill completed'
        : 'Humidity optimized for ${pod.name}',
    type: index.isEven ? 'info' : 'alert',
  );
});

List<AnalyticsPoint> generateAnalytics(int days) {
  return List.generate(days, (index) {
    return AnalyticsPoint(
      timestamp: DateTime.now().subtract(Duration(days: days - index)),
      value: 20 + (index * 3 % 40).toDouble(),
    );
  });
}
