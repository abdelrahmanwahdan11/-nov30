import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/pod.dart';

class CatalogController {
  final ValueNotifier<List<Pod>> items = ValueNotifier(List.of(dummyPods));
  final ValueNotifier<String> searchQuery = ValueNotifier('');
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> currentPage = ValueNotifier(1);

  void applySearch(String query) {
    searchQuery.value = query;
    final lower = query.toLowerCase();
    items.value = dummyPods
        .where(
          (pod) => pod.name.toLowerCase().contains(lower) ||
              pod.location.toLowerCase().contains(lower),
        )
        .toList();
  }

  Future<void> loadMore() async {
    if (isLoading.value) return;
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    currentPage.value += 1;
    items.value = List.of(items.value)..addAll(dummyPods);
    isLoading.value = false;
  }
}
