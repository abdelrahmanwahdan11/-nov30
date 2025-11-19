import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/pod.dart';

class CatalogController {
  CatalogController() {
    items.value = List.of(_allPods);
    isLoading.value = false;
  }

  final List<Pod> _allPods = List.of(dummyPods);
  final ValueNotifier<List<Pod>> items = ValueNotifier(const []);
  final ValueNotifier<String> searchQuery = ValueNotifier('');
  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<int> currentPage = ValueNotifier(1);
  final ValueNotifier<Set<String>> statusFilters = ValueNotifier(<String>{});
  final ValueNotifier<Set<String>> onlineFilters = ValueNotifier(<String>{});
  final ValueNotifier<Set<String>> locationFilters = ValueNotifier(<String>{});

  List<String> get availableLocations => {
        for (final pod in _allPods) pod.location,
      }.toList()
        ..sort();

  void applySearch(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void toggleStatus(String status) {
    final next = {...statusFilters.value};
    if (!next.add(status)) {
      next.remove(status);
    }
    statusFilters.value = next;
    _applyFilters();
  }

  void toggleOnline(String state) {
    final next = {...onlineFilters.value};
    if (!next.add(state)) {
      next.remove(state);
    }
    onlineFilters.value = next;
    _applyFilters();
  }

  void toggleLocation(String location) {
    final next = {...locationFilters.value};
    if (!next.add(location)) {
      next.remove(location);
    }
    locationFilters.value = next;
    _applyFilters();
  }

  void resetFilters() {
    statusFilters.value = <String>{};
    onlineFilters.value = <String>{};
    locationFilters.value = <String>{};
    searchQuery.value = '';
    _applyFilters();
  }

  Future<void> loadMore() async {
    if (isLoading.value) return;
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    currentPage.value += 1;
    final page = currentPage.value;
    final more = dummyPods
        .map(
          (pod) => pod.copyWith(id: '${pod.id}-p$page-${pod.name}-$page'),
        )
        .toList();
    _allPods.addAll(more);
    _applyFilters();
    isLoading.value = false;
  }

  void _applyFilters() {
    final lower = searchQuery.value.toLowerCase();
    var filtered = List.of(_allPods);
    if (lower.isNotEmpty) {
      filtered = filtered
          .where(
            (pod) => pod.name.toLowerCase().contains(lower) ||
                pod.location.toLowerCase().contains(lower),
          )
          .toList();
    }
    if (statusFilters.value.isNotEmpty) {
      filtered = filtered
          .where((pod) => statusFilters.value.contains(_statusFor(pod)))
          .toList();
    }
    if (onlineFilters.value.isNotEmpty) {
      filtered = filtered
          .where((pod) =>
              onlineFilters.value.contains(pod.isOnline ? 'online' : 'offline'))
          .toList();
    }
    if (locationFilters.value.isNotEmpty) {
      filtered = filtered
          .where((pod) => locationFilters.value.contains(pod.location))
          .toList();
    }
    items.value = filtered;
    if (filtered.isEmpty) {
      isLoading.value = false;
    }
  }

  String _statusFor(Pod pod) {
    if (pod.waterLevelPercent < 0.4) return 'low';
    if (pod.waterLevelPercent < 0.7) return 'medium';
    return 'full';
  }
}
