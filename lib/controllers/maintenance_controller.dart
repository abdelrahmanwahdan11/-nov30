import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/maintenance_task.dart';

class MaintenanceController {
  MaintenanceController() {
    tasks.value = List.of(dummyMaintenanceTasks);
  }

  final ValueNotifier<List<MaintenanceTask>> tasks = ValueNotifier(const []);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> refresh() async {
    if (isLoading.value) return;
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    tasks.value = [...tasks.value]..shuffle();
    isLoading.value = false;
  }

  void toggleCompleted(String id) {
    tasks.value = [
      for (final task in tasks.value)
        if (task.id == id) task.copyWith(isCompleted: !task.isCompleted) else task,
    ];
  }

  void postpone(String id, {int days = 1}) {
    tasks.value = [
      for (final task in tasks.value)
        if (task.id == id)
          task.copyWith(dueDate: task.dueDate.add(Duration(days: days)))
        else
          task,
    ];
  }

  List<MaintenanceTask> dueSoon({int withinDays = 3}) {
    final now = DateTime.now();
    final limit = now.add(Duration(days: withinDays));
    return tasks.value
        .where((task) => !task.isCompleted && task.dueDate.isBefore(limit))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<MaintenanceTask> tasksForPod(String podId) {
    return tasks.value.where((task) => task.podId == podId).toList();
  }
}
