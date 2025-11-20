import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/log_entry.dart';
import '../models/pod.dart';
import '../models/pod_alert.dart';

class DashboardController {
  DashboardController() {
    podsSummary.value = dummyPods;
    currentPod.value = dummyPods.first;
    recentLogs.value = dummyLogs.take(4).toList();
    alerts.value = _buildAlerts(dummyPods);
  }

  final ValueNotifier<List<Pod>> podsSummary = ValueNotifier(dummyPods);
  final ValueNotifier<Pod?> currentPod = ValueNotifier(null);
  final ValueNotifier<String> selectedMode = ValueNotifier('auto');
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<LogEntry>> recentLogs = ValueNotifier(const []);
  final ValueNotifier<List<PodAlert>> alerts = ValueNotifier(const []);

  Future<void> refresh() async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final shuffled = List.from(dummyPods)..shuffle();
    podsSummary.value = shuffled;
    currentPod.value = shuffled.first;
    recentLogs.value = (List.of(dummyLogs)..shuffle()).take(4).toList();
    alerts.value = _buildAlerts(shuffled);
    isLoading.value = false;
  }

  void selectPod(Pod pod) {
    currentPod.value = pod;
  }

  void updateMode(String mode) {
    selectedMode.value = mode;
  }

  List<PodAlert> _buildAlerts(List<Pod> pods) {
    final now = DateTime.now();
    final alerts = <PodAlert>[];
    for (final pod in pods) {
      if (!pod.isOnline) {
        alerts.add(
          PodAlert(
            id: 'offline-${pod.id}',
            podId: pod.id,
            podName: pod.name,
            location: pod.location,
            reason: 'offline',
            severity: 'critical',
            timestamp: now,
          ),
        );
      }
      if (pod.waterLevelPercent < 0.3) {
        alerts.add(
          PodAlert(
            id: 'low-water-${pod.id}',
            podId: pod.id,
            podName: pod.name,
            location: pod.location,
            reason: 'lowWater',
            severity: 'warning',
            timestamp: now,
          ),
        );
      }
    }
    return alerts;
  }
}
