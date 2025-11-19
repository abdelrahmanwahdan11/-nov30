import 'package:flutter/material.dart';

import '../../controllers/schedule_controller.dart';
import '../../data/dummy_data.dart';
import '../../models/schedule_rule.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleController controller = ScheduleController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final selected = controller.selectedDate.day == date.day;
                return GestureDetector(
                  onTap: () => setState(() => controller.selectDate(date)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? Theme.of(context).colorScheme.primary : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${date.day}'),
                        Text('${date.month}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: controller.rules.length,
              itemBuilder: (context, index) {
                final rule = controller.rules[index];
                return ExpansionTile(
                  title: Text('Rule ${rule.id}'),
                  subtitle: Text('${rule.startTime.format(context)} • ${rule.durationMinutes} min'),
                  children: [
                    Text('Days: ${rule.daysOfWeek.join(', ')}'),
                    TextButton(
                      onPressed: () => setState(() => controller.editRule(rule)),
                      child: const Text('Edit'),
                    ),
                  ],
                );
              },
            ),
          ),
          if (controller.editingItem != null)
            _RuleEditor(
              rule: controller.editingItem!,
              onSave: (rule) => setState(() => controller.saveRule(rule)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          controller.editRule(
            ScheduleRule(
              id: 'rule-${controller.rules.length + 1}',
              podId: dummyPods.first.id,
              startTime: const TimeOfDay(hour: 6, minute: 0),
              durationMinutes: 30,
              daysOfWeek: const [1, 3, 5],
            ),
          );
        }),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RuleEditor extends StatefulWidget {
  const _RuleEditor({required this.rule, required this.onSave});

  final ScheduleRule rule;
  final ValueChanged<ScheduleRule> onSave;

  @override
  State<_RuleEditor> createState() => _RuleEditorState();
}

class _RuleEditorState extends State<_RuleEditor> {
  late TimeOfDay time = widget.rule.startTime;
  late int duration = widget.rule.durationMinutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Start: ${time.format(context)}'),
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
            label: '$duration min',
            onChanged: (value) => setState(() => duration = value.toInt()),
          ),
          ElevatedButton(
            onPressed: () => widget.onSave(
              ScheduleRule(
                id: widget.rule.id,
                podId: widget.rule.podId,
                startTime: time,
                durationMinutes: duration,
                daysOfWeek: widget.rule.daysOfWeek,
              ),
            ),
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}
