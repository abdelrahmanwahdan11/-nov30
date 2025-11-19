import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/pod.dart';

class DashboardController {
  DashboardController() {
    podsSummary.value = dummyPods;
    currentPod.value = dummyPods.first;
  }

  final ValueNotifier<List<Pod>> podsSummary = ValueNotifier(dummyPods);
  final ValueNotifier<Pod?> currentPod = ValueNotifier(null);
  final ValueNotifier<String> selectedMode = ValueNotifier('auto');
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> refresh() async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 800));
    podsSummary.value = List.from(dummyPods)..shuffle();
    isLoading.value = false;
  }

  void selectPod(Pod pod) {
    currentPod.value = pod;
  }

  void updateMode(String mode) {
    selectedMode.value = mode;
  }
}
