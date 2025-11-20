import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dummy_data.dart';
import '../models/pod.dart';

class CatalogController {
  CatalogController() {
    items.value = List.of(_allPods);
    isLoading.value = false;
    _restoreFavorites();
  }

  final List<Pod> _allPods = List.of(dummyPods);
  final ValueNotifier<List<Pod>> items = ValueNotifier(const []);
  final ValueNotifier<String> searchQuery = ValueNotifier('');
  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<int> currentPage = ValueNotifier(1);
  final ValueNotifier<Set<String>> statusFilters = ValueNotifier(<String>{});
  final ValueNotifier<Set<String>> onlineFilters = ValueNotifier(<String>{});
  final ValueNotifier<Set<String>> locationFilters = ValueNotifier(<String>{});
  final ValueNotifier<Set<String>> elementFilters = ValueNotifier(<String>{});
  final ValueNotifier<Set<String>> favoriteIds = ValueNotifier(<String>{});
  final ValueNotifier<bool> favoritesOnly = ValueNotifier(false);
  final ValueNotifier<List<String>> recentQueries = ValueNotifier(const []);

  static const _favoritesKey = 'catalog_favorites';

  List<String> get availableLocations => {
        for (final pod in _allPods) pod.location,
      }.toList()
        ..sort();

  List<String> get elementTypes => {
        for (final pod in _allPods) pod.elementType,
      }.toList()
        ..sort();

  void applySearch(String query) {
    searchQuery.value = query;
    _trackRecentQuery(query);
    _applyFilters();
  }

  void clearRecentQueries() {
    recentQueries.value = const [];
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
    elementFilters.value = <String>{};
    favoritesOnly.value = false;
    searchQuery.value = '';
    _applyFilters();
  }

  void toggleElement(String element) {
    final next = {...elementFilters.value};
    if (!next.add(element)) {
      next.remove(element);
    }
    elementFilters.value = next;
    _applyFilters();
  }

  Future<void> _restoreFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_favoritesKey) ?? <String>[];
    if (saved.isEmpty) {
      saved.addAll(
        _allPods.where((pod) => pod.isFavorite).map((pod) => pod.id),
      );
    }
    favoriteIds.value = saved.toSet();
    _syncFavorites();
    _applyFilters();
  }

  Future<void> toggleFavorite(String podId) async {
    final next = {...favoriteIds.value};
    if (!next.add(podId)) {
      next.remove(podId);
    }
    favoriteIds.value = next;
    _syncFavorites();
    _applyFilters();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, next.toList());
  }

  void toggleFavoritesOnly() {
    favoritesOnly.value = !favoritesOnly.value;
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
    _syncFavorites();
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
                pod.location.toLowerCase().contains(lower) ||
                pod.elementType.toLowerCase().contains(lower) ||
                pod.tags.any((tag) => tag.toLowerCase().contains(lower)),
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
    if (elementFilters.value.isNotEmpty) {
      filtered = filtered
          .where((pod) => elementFilters.value.contains(pod.elementType))
          .toList();
    }
    if (favoritesOnly.value) {
      filtered = filtered.where((pod) => pod.isFavorite).toList();
    }
    items.value = filtered;
    if (filtered.isEmpty) {
      isLoading.value = false;
    }
  }

  void _syncFavorites() {
    for (var i = 0; i < _allPods.length; i++) {
      final pod = _allPods[i];
      final isFavorite = favoriteIds.value.contains(pod.id);
      if (pod.isFavorite != isFavorite) {
        _allPods[i] = pod.copyWith(isFavorite: isFavorite);
      }
    }
  }

  void _trackRecentQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final next = [trimmed, ...recentQueries.value.where((q) => q != trimmed)];
    recentQueries.value = next.take(6).toList();
  }

  String _statusFor(Pod pod) {
    if (pod.waterLevelPercent < 0.4) return 'low';
    if (pod.waterLevelPercent < 0.7) return 'medium';
    return 'full';
  }
}
