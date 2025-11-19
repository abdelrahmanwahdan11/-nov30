import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/schedule_rule.dart';

class ScheduleController extends ChangeNotifier {
  ScheduleController() {
    rules = List.of(dummyRules);
  }

  late List<ScheduleRule> rules;
  DateTime selectedDate = DateTime.now();
  ScheduleRule? editingItem;

  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void editRule(ScheduleRule rule) {
    editingItem = rule;
    notifyListeners();
  }

  void saveRule(ScheduleRule rule) {
    final index = rules.indexWhere((element) => element.id == rule.id);
    if (index == -1) {
      rules = [...rules, rule];
    } else {
      rules[index] = rule;
    }
    editingItem = null;
    notifyListeners();
  }
}
