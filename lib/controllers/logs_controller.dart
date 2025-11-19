import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/log_entry.dart';
import '../models/pod.dart';

class LogsController extends ChangeNotifier {
  LogsController() {
    _allLogs = List.of(dummyLogs);
    logEntries = ValueNotifier(List.of(_allLogs));
  }

  late List<LogEntry> _allLogs;
  late ValueNotifier<List<LogEntry>> logEntries;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> typeFilter = ValueNotifier(null);
  final ValueNotifier<String?> podFilter = ValueNotifier(null);
  final ValueNotifier<String> searchQuery = ValueNotifier('');
  int page = 1;

  final _podLookup = {for (final pod in dummyPods) pod.id: pod};

  List<String> get podIds => {
        for (final log in _allLogs) log.podId,
      }.toList()
        ..sort();

  Future<void> refresh() async {
    if (isLoading.value) return;
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _allLogs.shuffle();
    _emit();
    isLoading.value = false;
  }

  Future<void> loadMore() async {
    if (isLoading.value) return;
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    page += 1;
    final more = dummyLogs
        .map(
          (log) => log.copyWith(
            id: '${log.id}-p$page',
            timestamp: log.timestamp.add(Duration(minutes: page * 2)),
          ),
        )
        .toList();
    _allLogs.addAll(more);
    _emit();
    isLoading.value = false;
  }

  void filterByType(String? type) {
    typeFilter.value = type;
    _emit();
  }

  void filterByPod(String? podId) {
    podFilter.value = podId;
    _emit();
  }

  void applySearch(String query) {
    searchQuery.value = query.toLowerCase();
    _emit();
  }

  void _emit() {
    var filtered = List.of(_allLogs);
    final type = typeFilter.value;
    final pod = podFilter.value;
    if (type != null) {
      filtered = filtered.where((log) => log.type == type).toList();
    }
    if (pod != null && pod.isNotEmpty) {
      filtered = filtered.where((log) => log.podId == pod).toList();
    }
    final query = searchQuery.value.trim();
    if (query.isNotEmpty) {
      filtered = filtered.where((log) {
        final podData = _podLookup[log.podId];
        final buffer = [
          log.message,
          log.type,
          if (podData != null) ...[
            podData.name,
            podData.location,
            _statusFor(podData),
          ]
        ].join(' ').toLowerCase();
        return buffer.contains(query);
      }).toList();
    }
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    logEntries.value = filtered;
    notifyListeners();
  }

  String _statusFor(Pod pod) {
    if (pod.waterLevelPercent < 0.4) return 'low';
    if (pod.waterLevelPercent < 0.7) return 'medium';
    return 'full';
  }
}
