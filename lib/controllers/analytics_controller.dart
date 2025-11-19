import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/analytics_point.dart';

class AnalyticsController extends ChangeNotifier {
  AnalyticsController() {
    _load();
  }

  String currentTab = 'daily';
  List<AnalyticsPoint> dailyStats = const [];
  List<AnalyticsPoint> weeklyStats = const [];
  List<AnalyticsPoint> monthlyStats = const [];

  void _load() {
    dailyStats = generateAnalytics(7);
    weeklyStats = generateAnalytics(5);
    monthlyStats = generateAnalytics(12);
  }

  void selectTab(String tab) {
    currentTab = tab;
    notifyListeners();
  }
}
