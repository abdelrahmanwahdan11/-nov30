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
    elementType: 'pod',
    isFavorite: true,
    tags: const ['Hydroponic', 'Indoor'],
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
    elementType: 'sensor',
    tags: const ['Soil', 'Monitoring'],
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
    elementType: 'pump',
    tags: const ['Irrigation', 'Outdoor'],
  ),
  Pod(
    id: 'pod-4',
    name: 'Azure Drop',
    location: 'West Wing',
    waterLevelPercent: 0.9,
    humidityPercent: 0.58,
    waterTemperature: 19,
    isOnline: true,
    imageUrl: 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=800&q=60',
    elementType: 'pod',
    isFavorite: true,
    tags: const ['Indoor', 'Cooling'],
  ),
  Pod(
    id: 'pod-5',
    name: 'Polar Dew',
    location: 'Cooling Lab',
    waterLevelPercent: 0.21,
    humidityPercent: 0.35,
    waterTemperature: 16,
    isOnline: true,
    imageUrl: 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=900&q=60',
    elementType: 'sensor',
    tags: const ['Cooling', 'Alert'],
  ),
  Pod(
    id: 'pod-6',
    name: 'Lagoon Pulse',
    location: 'Greenhouse 02',
    waterLevelPercent: 0.62,
    humidityPercent: 0.6,
    waterTemperature: 24,
    isOnline: false,
    imageUrl: 'https://images.unsplash.com/photo-1470246973918-29a93221c455?auto=format&fit=crop&w=900&q=60',
    elementType: 'pump',
    tags: const ['Maintenance', 'Outdoor'],
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
  ScheduleRule(
    id: 'rule-3',
    podId: 'pod-5',
    startTime: const TimeOfDay(hour: 5, minute: 45),
    durationMinutes: 25,
    daysOfWeek: const [1, 2, 3, 4, 5],
  ),
];

final dummyLogs = List.generate(16, (index) {
  final pod = dummyPods[index % dummyPods.length];
  final isAlert = index % 3 == 0;
  final messages = [
    'Automatic refill completed',
    'Low water detected',
    'Humidity optimized for ${pod.name}',
    'Pump cycle finished',
  ];
  return LogEntry(
    id: 'log-$index',
    podId: pod.id,
    timestamp: DateTime.now().subtract(Duration(hours: index * 4)),
    message: messages[index % messages.length],
    type: isAlert ? 'alert' : 'info',
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
