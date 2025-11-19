import 'package:flutter/material.dart';

import '../../controllers/schedule_controller.dart';
import '../../data/dummy_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/schedule_rule.dart';
import '../../widgets/skeleton.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleController controller = ScheduleController();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('schedule.title'))),
      body: Column(
        children: [
          SizedBox(
            height: 90,
            child: ValueListenableBuilder<DateTime>(
              valueListenable: controller.selectedDate,
              builder: (context, selectedDate, _) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final date = DateTime.now().add(Duration(days: index));
                    final selected = date.day == selectedDate.day && date.month == selectedDate.month;
                    return GestureDetector(
                      onTap: () => controller.selectDate(date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${date.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${date.month}/${date.year}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: ValueListenableBuilder<List<ScheduleRule>>(
                valueListenable: controller.rules,
                builder: (context, rules, _) {
                  if (rules.isEmpty) {
                    return Center(child: Text(strings.t('schedule.empty')));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rules.length,
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      final pod = dummyPods.firstWhere((element) => element.id == rule.podId);
                      return Card(
                        child: ExpansionTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(pod.imageUrl)),
                          title: Text(pod.name),
                          subtitle: Text('${rule.startTime.format(context)} • ${rule.durationMinutes} min'),
                          children: [
                            Text('${strings.t('schedule.days')}: ${rule.daysOfWeek.join(', ')}'),
                            ButtonBar(
                              children: [
                                TextButton(
                                  onPressed: () => controller.editRule(rule),
                                  child: Text(strings.t('schedule.add')),
                                ),
                                TextButton(
                                  onPressed: () => controller.deleteRule(rule.id),
                                  child: Text(strings.t('schedule.cancel')),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          ValueListenableBuilder<ScheduleRule?>(
            valueListenable: controller.editingItem,
            builder: (context, rule, _) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: rule == null
                    ? const SizedBox.shrink()
                    : _RuleEditor(
                        key: ValueKey(rule.id),
                        rule: rule,
                        onSave: (updated) => controller.saveRule(updated),
                        onCancel: () => controller.editRule(null),
                      ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: controller.isLoading,
            builder: (context, loading, _) {
              if (!loading) return const SizedBox.shrink();
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Skeleton(height: 60, width: double.infinity),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.editRule(
            ScheduleRule(
              id: 'rule-${DateTime.now().millisecondsSinceEpoch}',
              podId: dummyPods.first.id,
              startTime: const TimeOfDay(hour: 6, minute: 0),
              durationMinutes: 30,
              daysOfWeek: const [1, 3, 5],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RuleEditor extends StatefulWidget {
  const _RuleEditor({super.key, required this.rule, required this.onSave, required this.onCancel});

  final ScheduleRule rule;
  final ValueChanged<ScheduleRule> onSave;
  final VoidCallback onCancel;

  @override
  State<_RuleEditor> createState() => _RuleEditorState();
}

class _RuleEditorState extends State<_RuleEditor> {
  late TimeOfDay time = widget.rule.startTime;
  late int duration = widget.rule.durationMinutes;
  late List<int> days = List.of(widget.rule.daysOfWeek);
  late String podId = widget.rule.podId;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${strings.t('schedule.start')}: ${time.format(context)}'),
              IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () async {
                  final selected = await showTimePicker(context: context, initialTime: time);
                  if (selected != null) setState(() => time = selected);
                },
              ),
            ],
          ),
          Slider(
            value: duration.toDouble(),
            min: 10,
            max: 90,
            divisions: 8,
            label: '$duration',
            onChanged: (value) => setState(() => duration = value.toInt()),
          ),
          DropdownButton<String>(
            value: podId,
            items: [
              for (final pod in dummyPods)
                DropdownMenuItem(value: pod.id, child: Text(pod.name)),
            ],
            onChanged: (value) => setState(() => podId = value ?? podId),
          ),
          Wrap(
            spacing: 8,
            children: [
              for (var day = 1; day <= 7; day++)
                FilterChip(
                  label: Text(day.toString()),
                  selected: days.contains(day),
                  onSelected: (_) {
                    setState(() {
                      if (days.contains(day)) {
                        days.remove(day);
                      } else {
                        days.add(day);
                      }
                    });
                  },
                ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => widget.onSave(
                  widget.rule.copyWith(
                    startTime: time,
                    durationMinutes: duration,
                    daysOfWeek: days,
                    podId: podId,
                  ),
                ),
                child: Text(strings.t('schedule.save')),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: widget.onCancel, child: Text(strings.t('schedule.cancel'))),
            ],
          )
        ],
      ),
    );
  }
}
