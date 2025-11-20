import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../controllers/app_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../data/dummy_data.dart';
import '../../l10n/app_localizations.dart';
import '../../models/log_entry.dart';
import '../../models/pod.dart';
import '../../models/pod_alert.dart';
import '../../utils/audio_stub.dart';
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
  final Set<String> dismissedAlertIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -80,
          child: _bubble(180, Theme.of(context).colorScheme.primary.withOpacity(0.15)),
        ),
        Positioned(
          bottom: -100,
          left: -60,
          child: _bubble(220, Theme.of(context).colorScheme.primary.withOpacity(0.1)),
        ),
        RefreshIndicator(
          onRefresh: () async {
            await dashboardController.refresh();
            final pod = dashboardController.currentPod.value;
            if (pod != null && pod.waterLevelPercent < 0.3) {
              playAlertSound('onLowWaterLevel');
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(strings.t('dashboard.title')),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: dashboardController.refresh,
                    tooltip: strings.t('dashboard.refresh'),
                  ),
                  IconButton(
                    icon: const Icon(IconlyLight.danger),
                    onPressed: () => playAlertSound('onPodOffline'),
                  ),
                  IconButton(
                    icon: const Icon(IconlyLight.setting),
                    onPressed: () => _showQuickActions(context, strings),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetrics(strings),
                      const SizedBox(height: 16),
                      _buildModes(strings),
                      const SizedBox(height: 16),
                      _buildGaugeSection(strings),
                      const SizedBox(height: 16),
                      _buildUpcoming(strings),
                      const SizedBox(height: 16),
                      _buildPodsList(strings),
                      const SizedBox(height: 16),
                      _buildAlerts(strings),
                      const SizedBox(height: 16),
                      _buildRecentActivity(strings),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showQuickActions(BuildContext context, AppLocalizations strings) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(IconlyLight.chart),
                title: Text(strings.t('analytics.title')),
                subtitle: Text(strings.t('comparison.selector')),
              ),
              ListTile(
                leading: const Icon(IconlyLight.setting),
                title: Text(strings.t('settings.title')),
                subtitle: Text(strings.t('settings.alerts')),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildMetrics(AppLocalizations strings) {
    final metrics = [
      (strings.t('dashboard.metrics.online'), '6/8'),
      (strings.t('dashboard.metrics.humidity'), '64%'),
      (strings.t('dashboard.metrics.temperature'), '22°C'),
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
                        Text(metric.$1, style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            metric.$2,
                            key: ValueKey(metric.$2),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
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

  Widget _buildModes(AppLocalizations strings) {
    final modes = [
      ('auto', IconlyLight.tick_square, strings.t('dashboard.modes.auto')),
      ('eco', IconlyLight.chart, strings.t('dashboard.modes.eco')),
      ('boost', IconlyLight.flash, strings.t('dashboard.modes.boost')),
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
                                Text(mode.$3.toUpperCase()),
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

  Widget _buildGaugeSection(AppLocalizations strings) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strings.t('dashboard.active')),
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
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(IconlyLight.discovery),
                      label: Text(strings.t('ai.button')),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcoming(AppLocalizations strings) {
    return ValueListenableBuilder<Pod?>(
      valueListenable: dashboardController.currentPod,
      builder: (context, pod, _) {
        if (pod == null) return const Skeleton(height: 120);
        final rules = dummyRules.where((rule) => rule.podId == pod.id).toList()
          ..sort(
            (a, b) => a.startTime.hour.compareTo(b.startTime.hour),
          );
        if (rules.isEmpty) {
          return GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(IconlyLight.calendar),
                  const SizedBox(width: 12),
                  Expanded(child: Text(strings.t('dashboard.upcoming.empty'))),
                ],
              ),
            ),
          );
        }
        return GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(strings.t('dashboard.upcoming.title'),
                        style: Theme.of(context).textTheme.titleMedium),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text(strings.t('dashboard.next_run') +
                          ' ${rules.first.startTime.format(context)}'),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                ...rules.map(
                  (rule) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(rule.label, style: Theme.of(context).textTheme.titleSmall),
                              Chip(
                                label: Text(rule.isEnabled
                                    ? strings.t('schedule.enabled')
                                    : strings.t('schedule.disabled')),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: rule.isEnabled
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                              ),
                            ],
                          ),
                          Text(
                            '${rule.startTime.format(context)} · ${rule.durationMinutes} ${strings.t('schedule.mins')}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(_daysLabel(rule.daysOfWeek, strings)),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPodsList(AppLocalizations strings) {
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
                        Text(
                          '${(pod.waterLevelPercent * 100).toStringAsFixed(0)}% • ${_statusText(pod, strings)}',
                        ),
                        Text(
                          pod.isOnline
                              ? strings.t('catalog.filters.online_label')
                              : strings.t('catalog.filters.offline'),
                          style: TextStyle(
                            color: pod.isOnline ? Colors.green : Colors.orange,
                          ),
                        ),
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

  Widget _buildAlerts(AppLocalizations strings) {
    return ValueListenableBuilder<List<PodAlert>>(
      valueListenable: dashboardController.alerts,
      builder: (context, alerts, child) {
        final visibleAlerts =
            alerts.where((alert) => !dismissedAlertIds.contains(alert.id)).toList();
        if (visibleAlerts.isEmpty) {
          return GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(IconlyLight.shield_done),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(strings.t('dashboard.alerts.empty')),
                  ),
                ],
              ),
            ),
          );
        }
        return GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      strings.t('dashboard.alerts.title'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(IconlyLight.danger),
                      tooltip: strings.t('dashboard.refresh'),
                      onPressed: () {
                        playAlertSound('onPodOffline');
                        dashboardController.refresh();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...visibleAlerts.map((alert) {
                  final color = alert.severity == 'critical'
                      ? Colors.redAccent
                      : Colors.amber;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withOpacity(0.15),
                              ),
                              child: Icon(
                                alert.reason == 'offline'
                                    ? IconlyLight.danger
                                    : Icons.water_drop,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${alert.podName} • ${_alertLabel(alert, strings)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    alert.location,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              TimeOfDay.fromDateTime(alert.timestamp).format(context),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            spacing: 8,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.snooze),
                                label: Text(strings.t('dashboard.actions.snooze')),
                                onPressed: () =>
                                    _showSnack(strings.t('dashboard.actions.snooze')),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.check_circle_outline),
                                label: Text(strings.t('dashboard.actions.resolve')),
                                onPressed: () {
                                  setState(() => dismissedAlertIds.add(alert.id));
                                  _showSnack(strings.t('dashboard.actions.resolve'));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity(AppLocalizations strings) {
    return ValueListenableBuilder<List<LogEntry>>(
      valueListenable: dashboardController.recentLogs,
      builder: (context, logs, child) {
        if (logs.isEmpty) {
          return const SizedBox.shrink();
        }
        return GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(strings.t('dashboard.recent_activity'),
                        style: Theme.of(context).textTheme.titleMedium),
                    IconButton(
                      icon: const Icon(IconlyLight.paper),
                      tooltip: strings.t('logs.title'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.t('logs.updated'))),
                        );
                      },
                    )
                  ],
                ),
                const SizedBox(height: 12),
                ...logs.take(4).map((log) {
                  final isAlert = log.type == 'alert';
                  final time = TimeOfDay.fromDateTime(log.timestamp).format(context);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAlert
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                          ),
                          child: Icon(
                            isAlert ? IconlyLight.danger : IconlyLight.info_square,
                            color: isAlert ? Colors.orange : Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.message,
                                  style: Theme.of(context).textTheme.bodyLarge),
                              Text(time, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

String _statusText(Pod pod, AppLocalizations strings) {
  if (pod.waterLevelPercent < 0.4) return strings.t('common.status.low');
  if (pod.waterLevelPercent < 0.7) return strings.t('common.status.medium');
  return strings.t('common.status.full');
}

String _daysLabel(List<int> days, AppLocalizations strings) {
  return days.map((d) => strings.t('schedule.day.$d')).join(', ');
}

String _alertLabel(PodAlert alert, AppLocalizations strings) {
  switch (alert.reason) {
    case 'offline':
      return strings.t('dashboard.alerts.offline');
    case 'lowWater':
      return strings.t('dashboard.alerts.low_water');
    default:
      return strings.t('dashboard.alerts.title');
  }
}
