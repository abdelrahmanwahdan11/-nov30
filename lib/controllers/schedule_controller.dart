import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/schedule_rule.dart';

class ScheduleController {
  ScheduleController() {
    rules.value = List.of(dummyRules);
  }

  final ValueNotifier<List<ScheduleRule>> rules = ValueNotifier(const []);
  final ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  final ValueNotifier<ScheduleRule?> editingItem = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> refresh() async {
    if (isLoading.value) return;
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    rules.value = List.of(rules.value)..shuffle();
    isLoading.value = false;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void editRule(ScheduleRule? rule) {
    editingItem.value = rule;
  }

  void saveRule(ScheduleRule rule) {
    final list = [...rules.value];
    final index = list.indexWhere((element) => element.id == rule.id);
    if (index == -1) {
      list.add(rule);
    } else {
      list[index] = rule;
    }
    rules.value = list;
    editingItem.value = null;
  }

  void deleteRule(String id) {
    rules.value = rules.value.where((rule) => rule.id != id).toList();
  }

  void toggleEnabled(String id) {
    rules.value = [
      for (final rule in rules.value)
        if (rule.id == id) rule.copyWith(isEnabled: !rule.isEnabled) else rule,
    ];
  }

  void duplicateRule(ScheduleRule rule) {
    final duplicated = rule.copyWith(
      id: '${rule.id}-copy-${DateTime.now().millisecondsSinceEpoch}',
      startTime: TimeOfDay(
        hour: (rule.startTime.hour + 1) % 24,
        minute: rule.startTime.minute,
      ),
      label: '${rule.label} (copy)'.trim(),
      isEnabled: true,
    );
    rules.value = [...rules.value, duplicated];
  }

  List<ScheduleRule> rulesForDay(DateTime date) {
    return rules.value
        .where((rule) => rule.daysOfWeek.contains(date.weekday))
        .toList()
      ..sort(
        (a, b) => _toDateTime(date, a.startTime).compareTo(_toDateTime(date, b.startTime)),
      );
  }

  DateTime? nextRun(DateTime date) {
    final active = rulesForDay(date).where((rule) => rule.isEnabled).toList();
    if (active.isEmpty) return null;
    return active
        .map((rule) => _toDateTime(date, rule.startTime))
        .where((time) => time.isAfter(DateTime.now()))
        .fold<DateTime?>(null, (previous, element) {
      if (previous == null) return element;
      return element.isBefore(previous) ? element : previous;
    });
  }

  DateTime _toDateTime(DateTime date, TimeOfDay timeOfDay) {
    return DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
  }
}
