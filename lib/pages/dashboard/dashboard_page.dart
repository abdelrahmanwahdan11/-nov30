import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/pod.dart';
import '../../widgets/ai_info_button.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/pod_gauge.dart';
import '../../widgets/skeleton.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController dashboardController = DashboardController();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: dashboardController.refresh,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('WaterPod'),
            actions: const [
              IconButton(icon: Icon(Icons.refresh), onPressed: null),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetrics(),
                  const SizedBox(height: 16),
                  _buildModes(),
                  const SizedBox(height: 16),
                  _buildGaugeSection(),
                  const SizedBox(height: 16),
                  _buildPodsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    final metrics = [
      ('Pods Online', '3/4'),
      ('Humidity', '64%'),
      ('Water Temp', '22°C'),
    ];
    return Row(
      children: metrics
          .map(
            (metric) => Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: GlassContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(metric.$1),
                        const SizedBox(height: 8),
                        Text(
                          metric.$2,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildModes() {
    final modes = [
      ('auto', IconlyLight.tick_square),
      ('eco', IconlyLight.chart),
      ('boost', IconlyLight.flash),
    ];
    return ValueListenableBuilder<String>(
      valueListenable: dashboardController.selectedMode,
      builder: (context, value, child) {
        return Row(
          children: modes
              .map((mode) => Expanded(
                    child: AnimatedScale(
                      scale: value == mode.$1 ? 1 : 0.95,
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GlassContainer(
                          onTap: () => dashboardController.updateMode(mode.$1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(mode.$2),
                                const SizedBox(width: 8),
                                Text(mode.$1.toUpperCase()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildGaugeSection() {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active Pod'),
                const AiInfoButton(),
              ],
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<Pod?>(
              valueListenable: dashboardController.currentPod,
              builder: (context, pod, child) {
                if (pod == null) {
                  return const Skeleton(height: 200);
                }
                return Column(
                  children: [
                    PodGauge(value: pod.waterLevelPercent),
                    const SizedBox(height: 12),
                    Text(pod.name, style: Theme.of(context).textTheme.titleLarge),
                    Text(pod.location),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodsList() {
    return ValueListenableBuilder<List<Pod>>(
      valueListenable: dashboardController.podsSummary,
      builder: (context, pods, child) {
        return SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final pod = pods[index];
              return SizedBox(
                width: 160,
                child: GlassContainer(
                  onTap: () => dashboardController.selectPod(pod),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(pod.imageUrl, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(pod.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${(pod.waterLevelPercent * 100).toStringAsFixed(0)}% water'),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: pods.length,
          ),
        );
      },
    );
  }
}
