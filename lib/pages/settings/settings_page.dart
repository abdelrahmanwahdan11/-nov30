import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';

import '../../data/dummy_data.dart';
import '../../controllers/app_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/glass_container.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.appController});

  final AppController appController;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = [
      const Color(0xFF909D92),
      const Color(0xFF7AA095),
      const Color(0xFF6C7A89),
      const Color(0xFFAACB73),
    ];
    return AnimatedBuilder(
      animation: appController,
      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              leading: const Icon(IconlyLight.document),
              title: Text(strings.t('settings.language')),
              trailing: DropdownButton<Locale>(
                value: appController.locale,
                onChanged: (locale) {
                  if (locale != null) appController.updateLocale(locale);
                },
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(IconlyLight.show),
              title: Text(strings.t('settings.theme')),
              trailing: DropdownButton<ThemeMode>(
                value: appController.themeMode,
                onChanged: (mode) {
                  if (mode != null) appController.updateTheme(mode);
                },
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(IconlyLight.paper),
              title: Text(strings.t('settings.text_size')),
              subtitle: Text(strings.t('settings.text_size_desc')),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              trailing: Text('${(appController.textScaleFactor * 100).round()}%'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Slider(
                min: 0.9,
                max: 1.3,
                divisions: 8,
                value: appController.textScaleFactor,
                onChanged: appController.updateTextScale,
              ),
            ),
            const SizedBox(height: 12),
            Text(strings.t('settings.color')),
            Wrap(
              spacing: 8,
              children: colors
                  .map((color) => GestureDetector(
                        onTap: () => appController.updatePrimaryColor(color),
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: appController.primaryColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.t('settings.preview'),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(strings.t('settings.preview.subtitle'),
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 12),
                    _ThemePreview(primary: appController.primaryColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text(strings.t('settings.alerts')),
              value: appController.alertsEnabled,
              onChanged: appController.updateAlerts,
            ),
            ListTile(
              leading: const Icon(IconlyLight.download),
              title: Text(strings.t('settings.export')),
              subtitle: Text(strings.t('settings.export_desc')),
              onTap: () => _copySnapshot(context, strings),
            ),
            ListTile(
              leading: const Icon(IconlyLight.play),
              title: Text(strings.t('settings.onboarding_title')),
              subtitle: Text(strings.t('settings.onboarding_subtitle')),
              trailing: const Icon(Icons.refresh),
              onTap: () async {
                await appController.resetOnboarding();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.t('settings.onboarding_reset'))),
                  );
                }
              },
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await appController.clearPreferences();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(strings.t('settings.cleared'))),
                  );
                }
              },
              icon: const Icon(IconlyLight.delete),
              label: Text(strings.t('settings.clear')),
            ),
          ],
        );
      },
    );
  }
  Future<void> _copySnapshot(BuildContext context, AppLocalizations strings) async {
    final podLines = dummyPods.map((pod) {
      final statusKey = pod.isOnline ? 'common.status.online' : 'common.status.offline';
      return '${pod.name} (${pod.location}) • ${(pod.waterLevelPercent * 100).toStringAsFixed(0)}% ${strings.t(statusKey)}';
    }).toList();
    final ruleLines = dummyRules
        .map((rule) =>
            '${rule.label} → ${rule.startTime.format(context)} (${rule.durationMinutes}m) [${rule.daysOfWeek.join(',')}]')
        .toList();
    final maintenanceLines = dummyMaintenanceTasks
        .map((task) => '${task.title} • ${task.priority.name} (${task.dueDate.toLocal()})')
        .toList();

    final snapshot = {
      'pods': podLines,
      'rules': ruleLines,
      'maintenance': maintenanceLines,
    };

    await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(snapshot)));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.t('settings.exported'))));
    }
  }

}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WaterPod',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
