import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../controllers/logs_controller.dart';
import '../../data/dummy_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/log_entry.dart';
import '../../widgets/skeleton.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final LogsController controller = LogsController();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final podName = {for (final pod in dummyPods) pod.id: pod.name};
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('logs.title'))),
      body: Column(
        children: [
          _FilterBar(controller: controller, strings: strings, podName: podName),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: ValueListenableBuilder<List<LogEntry>>(
                valueListenable: controller.logEntries,
                builder: (context, entries, _) {
                  if (entries.isEmpty) {
                    return const Center(child: Skeleton(height: 120, width: 200));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final isAlert = entry.type == 'alert';
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isAlert ? Colors.orange : Colors.green,
                              child: Icon(isAlert ? IconlyLight.danger : IconlyLight.info_square, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.message, style: Theme.of(context).textTheme.titleMedium),
                                  Text('${podName[entry.podId] ?? entry.podId} • ${entry.timestamp}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<bool>(
              valueListenable: controller.isLoading,
              builder: (context, loading, _) {
                return FilledButton.icon(
                  onPressed: loading ? null : controller.loadMore,
                  icon: loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(IconlyLight.arrow_down_2),
                  label: Text(strings.t('logs.load_more')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller, required this.strings, required this.podName});

  final LogsController controller;
  final AppLocalizations strings;
  final Map<String, String> podName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.t('logs.updated'), style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          ValueListenableBuilder<String?>(
            valueListenable: controller.typeFilter,
            builder: (context, value, _) {
              return Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(strings.t('logs.filter.all')),
                    selected: value == null,
                    onSelected: (_) => controller.filterByType(null),
                  ),
                  ChoiceChip(
                    label: Text(strings.t('logs.filter.alerts')),
                    selected: value == 'alert',
                    onSelected: (selected) =>
                        controller.filterByType(selected ? 'alert' : null),
                  ),
                  ChoiceChip(
                    label: Text(strings.t('logs.filter.info')),
                    selected: value == 'info',
                    onSelected: (selected) =>
                        controller.filterByType(selected ? 'info' : null),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<String?>(
            valueListenable: controller.podFilter,
            builder: (context, selectedPod, _) {
              final podIds = controller.podIds;
              return DropdownButtonFormField<String?>(
                value: selectedPod,
                hint: Text(strings.t('catalog.filters.location')),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...podIds.map(
                    (id) => DropdownMenuItem(value: id, child: Text(podName[id] ?? id)),
                  ),
                ],
                onChanged: controller.filterByPod,
              );
            },
          ),
        ],
      ),
    );
  }
}
