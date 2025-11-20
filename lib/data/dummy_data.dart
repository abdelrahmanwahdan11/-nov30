import 'package:flutter/material.dart';

import '../models/analytics_point.dart';
import '../models/log_entry.dart';
import '../models/maintenance_task.dart';
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
    label: 'Morning Mist',
  ),
  ScheduleRule(
    id: 'rule-2',
    podId: 'pod-2',
    startTime: const TimeOfDay(hour: 8, minute: 0),
    durationMinutes: 20,
    daysOfWeek: const [2, 4, 6],
    label: 'Sensor Flush',
    isEnabled: false,
  ),
  ScheduleRule(
    id: 'rule-3',
    podId: 'pod-5',
    startTime: const TimeOfDay(hour: 5, minute: 45),
    durationMinutes: 25,
    daysOfWeek: const [1, 2, 3, 4, 5],
    label: 'Cooling baseline',
  ),
];

final dummyMaintenanceTasks = <MaintenanceTask>[
  MaintenanceTask(
    id: 'task-1',
    podId: 'pod-1',
    title: 'Inspect filters',
    description: 'Verify inlet filters are clear and rinse if needed.',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    priority: TaskPriority.high,
  ),
  MaintenanceTask(
    id: 'task-2',
    podId: 'pod-5',
    title: 'Flush cooling line',
    description: 'Run a short flush to keep cooling channels clean.',
    dueDate: DateTime.now(),
    priority: TaskPriority.medium,
  ),
  MaintenanceTask(
    id: 'task-3',
    podId: 'pod-3',
    title: 'Check pump seals',
    description: 'Inspect pump housing for wear and reseat seals.',
    dueDate: DateTime.now().add(const Duration(days: 3)),
    priority: TaskPriority.high,
  ),
  MaintenanceTask(
    id: 'task-4',
    podId: 'pod-6',
    title: 'Calibrate sensor',
    description: 'Calibrate humidity probe after last firmware update.',
    dueDate: DateTime.now().subtract(const Duration(days: 1)),
    priority: TaskPriority.low,
  ),
  MaintenanceTask(
    id: 'task-5',
    podId: 'pod-2',
    title: 'Clean viewport',
    description: 'Wipe viewport to maintain camera clarity.',
    dueDate: DateTime.now().add(const Duration(days: 2)),
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
