import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/pod.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> with SingleTickerProviderStateMixin {
  late final TabController tabController = TabController(length: 2, vsync: this);
  final List<Pod> selected = dummyPods.take(3).toList();

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison'),
        bottom: TabBar(
          controller: tabController,
          tabs: const [Tab(text: 'Overview'), Tab(text: 'History')],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildOverview(),
          _buildHistory(),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Pod')),
          DataColumn(label: Text('Water')),
          DataColumn(label: Text('Humidity')),
          DataColumn(label: Text('Temp')),
        ],
        rows: [
          for (final pod in selected)
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

  Widget _buildHistory() {
    return ListView.builder(
      itemCount: selected.length,
      itemBuilder: (context, index) {
        final pod = selected[index];
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(pod.imageUrl)),
          title: Text(pod.name),
          subtitle: Text('Online: ${pod.isOnline}'),
        );
      },
    );
  }
}
