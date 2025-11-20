import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';

import '../../controllers/logs_controller.dart';
import '../../data/dummy_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/log_entry.dart';
import '../../models/pod.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final LogsController controller = LogsController();
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final podById = {for (final pod in dummyPods) pod.id: pod};
    final podName = {for (final pod in dummyPods) pod.id: pod.name};
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.t('logs.title')),
        actions: [
          IconButton(
            tooltip: strings.t('logs.export'),
            icon: const Icon(IconlyLight.download),
            onPressed: () async {
              final buffer = controller.logEntries.value
                  .map(
                    (e) =>
                        '[${e.timestamp.toIso8601String()}] ${podName[e.podId] ?? e.podId} • ${e.type.toUpperCase()} • ${e.message}',
                  )
                  .join('\n');
              await Clipboard.setData(ClipboardData(text: buffer));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.t('logs.exported'))),
                );
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ValueListenableBuilder<String>(
              valueListenable: controller.searchQuery,
              builder: (context, query, _) {
                return TextField(
                  controller: searchController,
                  onChanged: controller.applySearch,
                  decoration: InputDecoration(
                    hintText: strings.t('logs.search_hint'),
                    prefixIcon: const Icon(IconlyLight.search),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              controller.applySearch('');
                            },
                          ),
                  ),
                );
              },
            ),
          ),
          _FilterBar(controller: controller, strings: strings, podName: podName),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: ValueListenableBuilder<List<LogEntry>>(
                valueListenable: controller.logEntries,
                builder: (context, entries, _) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(IconlyLight.close_square),
                          const SizedBox(height: 12),
                          Text(strings.t('logs.empty')),
                          TextButton(
                            onPressed: () {
                              searchController.clear();
                              controller.applySearch('');
                              controller.filterByPod(null);
                              controller.filterByType(null);
                            },
                            child: Text(strings.t('catalog.filters.reset')),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final isAlert = entry.type == 'alert';
                      final pod = podById[entry.podId];
                      final elementLabel = pod == null
                          ? ''
                          : strings.t('catalog.element.${pod.elementType}');
                      final statusLabel = pod == null
                          ? ''
                          : _statusLabel(pod, strings);
                      final time = TimeOfDay.fromDateTime(entry.timestamp).format(context);
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
                                  Text('${podName[entry.podId] ?? entry.podId} • $time'),
                                  if (pod != null)
                                    Wrap(
                                      spacing: 6,
                                      children: [
                                        Chip(
                                          visualDensity: VisualDensity.compact,
                                          label: Text(elementLabel),
                                        ),
                                        Chip(
                                          visualDensity: VisualDensity.compact,
                                          label: Text(statusLabel),
                                        ),
                                      ],
                                    ),
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

String _statusLabel(Pod pod, AppLocalizations strings) {
  if (pod.waterLevelPercent < 0.4) return strings.t('common.status.low');
  if (pod.waterLevelPercent < 0.7) return strings.t('common.status.medium');
  return strings.t('common.status.full');
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
