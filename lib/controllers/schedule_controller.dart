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
}
