import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/log_entry.dart';
import '../models/pod.dart';

class DashboardController {
  DashboardController() {
    podsSummary.value = dummyPods;
    currentPod.value = dummyPods.first;
    recentLogs.value = dummyLogs.take(4).toList();
  }

  final ValueNotifier<List<Pod>> podsSummary = ValueNotifier(dummyPods);
  final ValueNotifier<Pod?> currentPod = ValueNotifier(null);
  final ValueNotifier<String> selectedMode = ValueNotifier('auto');
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<LogEntry>> recentLogs = ValueNotifier(const []);

  Future<void> refresh() async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final shuffled = List.from(dummyPods)..shuffle();
    podsSummary.value = shuffled;
    currentPod.value = shuffled.first;
    recentLogs.value = (List.of(dummyLogs)..shuffle()).take(4).toList();
    isLoading.value = false;
  }

  void selectPod(Pod pod) {
    currentPod.value = pod;
  }

  void updateMode(String mode) {
    selectedMode.value = mode;
  }
}
