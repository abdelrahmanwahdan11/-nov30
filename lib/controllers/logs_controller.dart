import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/log_entry.dart';

class LogsController extends ChangeNotifier {
  LogsController() {
    logEntries = List.of(dummyLogs);
  }

  late List<LogEntry> logEntries;
  int page = 1;

  Future<void> loadMore() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    page += 1;
    logEntries = [...logEntries, ...dummyLogs];
    notifyListeners();
  }
}
