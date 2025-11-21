import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';

import '../../data/dummy_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/pod.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> with SingleTickerProviderStateMixin {
  late final TabController tabController = TabController(length: 2, vsync: this);
  final Set<String> selectedIds = dummyPods.take(2).map((e) => e.id).toSet();

  List<Pod> get selectedPods => dummyPods.where((pod) => selectedIds.contains(pod.id)).toList();

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.t('comparison.title')),
        actions: [
          if (selectedPods.isNotEmpty)
            IconButton(
              tooltip: strings.t('comparison.export'),
              icon: const Icon(IconlyLight.upload),
              onPressed: () => _copyComparison(context, strings),
            ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: [Tab(text: strings.t('catalog.title')), Tab(text: strings.t('comparison.history'))],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.t('comparison.selector')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final pod in dummyPods)
                      ChoiceChip(
                        label: Text(pod.name),
                        selected: selectedIds.contains(pod.id),
                        onSelected: (_) => _togglePod(pod.id, strings),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child: TabBarView(
                key: ValueKey(selectedIds.length + tabController.index),
                controller: tabController,
                children: [
                  _buildOverview(strings),
                  _buildHistory(strings),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePod(String id, AppLocalizations strings) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else if (selectedIds.length < 4) {
        selectedIds.add(id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.t('comparison.limit'))),
        );
      }
    });
  }

  Widget _buildOverview(AppLocalizations strings) {
    final pods = selectedPods;
    if (pods.isEmpty) {
      return Center(child: Text(strings.t('comparison.selector')));
    }
    final healthiest = pods.reduce((a, b) => _healthScore(a).compareTo(_healthScore(b)) >= 0 ? a : b);
    final lowest = pods.reduce((a, b) => a.waterLevelPercent.compareTo(b.waterLevelPercent) <= 0 ? a : b);
    final fullest = pods.reduce((a, b) => a.waterLevelPercent.compareTo(b.waterLevelPercent) >= 0 ? a : b);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                icon: IconlyLight.graph,
                label: strings.t('comparison.best_fill'),
                value: '${fullest.name} · ${(fullest.waterLevelPercent * 100).toStringAsFixed(0)}%',
              ),
              _MetricChip(
                icon: IconlyLight.danger,
                label: strings.t('comparison.lowest_fill'),
                value: '${lowest.name} · ${(lowest.waterLevelPercent * 100).toStringAsFixed(0)}%',
                color: Colors.orange,
              ),
              _MetricChip(
                icon: IconlyLight.shield_done,
                label: strings.t('comparison.health'),
                value: '${healthiest.name} · ${(_healthScore(healthiest) * 100).toStringAsFixed(0)}%',
                color: Colors.green,
              ),
              _MetricChip(
                icon: IconlyLight.info_circle,
                label: strings.t('comparison.offline_count'),
                value: pods.where((pod) => !pod.isOnline).length.toString(),
                color: Colors.blueGrey,
              ),
            ],
          ),
          const SizedBox(height: 16),
          DataTable(
            columns: [
              DataColumn(label: Text(strings.t('catalog.title'))),
              DataColumn(label: Text(strings.t('catalog.filters.status'))),
              DataColumn(label: Text(strings.t('dashboard.metrics.humidity'))),
              DataColumn(label: Text(strings.t('dashboard.metrics.temperature'))),
              DataColumn(label: Text(strings.t('comparison.health'))),
            ],
            rows: [
              for (final pod in pods)
                DataRow(cells: [
                  DataCell(Text(pod.name)),
                  DataCell(Text('${(pod.waterLevelPercent * 100).toStringAsFixed(0)}%')),
                  DataCell(Text('${(pod.humidityPercent * 100).toStringAsFixed(0)}%')),
                  DataCell(Text('${pod.waterTemperature}°C')),
                  DataCell(_HealthBadge(score: _healthScore(pod))),
                ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(AppLocalizations strings) {
    final pods = selectedPods;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pods.length,
      itemBuilder: (context, index) {
        final pod = pods[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(pod.imageUrl)),
            title: Text(pod.name),
            subtitle: Text(
              pod.isOnline
                  ? strings.t('catalog.filters.online_label')
                  : strings.t('catalog.filters.offline'),
            ),
            trailing: Icon(pod.isOnline ? IconlyLight.tick_square : IconlyLight.close_square),
          ),
        );
      },
    );
  }

  double _healthScore(Pod pod) {
    final availability = pod.isOnline ? 1.0 : 0.6;
    final water = pod.waterLevelPercent.clamp(0.0, 1.0);
    final humidityBalance = 1 - (0.5 - pod.humidityPercent).abs();
    return ((availability + water + humidityBalance) / 3).clamp(0.0, 1.0);
  }

  Future<void> _copyComparison(BuildContext context, AppLocalizations strings) async {
    final buffer = StringBuffer(strings.t('comparison.title'))..writeln();
    for (final pod in selectedPods) {
      buffer.writeln(
        '${pod.name} • ${(pod.waterLevelPercent * 100).toStringAsFixed(0)}% | ${(pod.humidityPercent * 100).toStringAsFixed(0)}% | ${pod.waterTemperature}°C | ${(_healthScore(pod) * 100).toStringAsFixed(0)}%',
      );
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.t('comparison.exported'))));
    }
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary, size: 18),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
      backgroundColor: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    final percent = (score * 100).toStringAsFixed(0);
    final color = score > 0.75
        ? Colors.green
        : score > 0.55
            ? Colors.orange
            : Colors.red;
    return Chip(
      label: Text('$percent%'),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }
}
