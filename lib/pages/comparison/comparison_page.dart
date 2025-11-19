import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTable(
        columns: [
          DataColumn(label: Text(strings.t('catalog.title'))),
          DataColumn(label: Text(strings.t('catalog.filters.status'))),
          DataColumn(label: Text(strings.t('dashboard.metrics.humidity'))),
          DataColumn(label: Text(strings.t('dashboard.metrics.temperature'))),
        ],
        rows: [
          for (final pod in pods)
            DataRow(cells: [
              DataCell(Text(pod.name)),
              DataCell(Text('${(pod.waterLevelPercent * 100).toStringAsFixed(0)}%')),
              DataCell(Text('${(pod.humidityPercent * 100).toStringAsFixed(0)}%')),
              DataCell(Text('${pod.waterTemperature}°C')),
            ]),
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
}
