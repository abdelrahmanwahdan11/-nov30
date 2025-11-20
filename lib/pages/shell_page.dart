import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../controllers/app_controller.dart';
import '../l10n/app_localizations.dart';
import '../widgets/responsive_layout.dart';
import 'analytics/analytics_page.dart';
import 'catalog/catalog_page.dart';
import 'comparison/comparison_page.dart';
import 'dashboard/dashboard_page.dart';
import 'logs/logs_page.dart';
import 'schedule/schedule_page.dart';
import 'settings/settings_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, required this.appController});

  final AppController appController;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int currentIndex = 0;

  late final pages = [
    DashboardPage(controller: widget.appController),
    const CatalogPage(),
    const ComparisonPage(),
    const SchedulePage(),
    const LogsPage(),
    const AnalyticsPage(),
    SettingsPage(appController: widget.appController),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final icons = [
      IconlyLight.home,
      IconlyLight.document,
      IconlyLight.folder,
      IconlyLight.calendar,
      IconlyLight.paper,
      IconlyLight.chart,
      IconlyLight.setting,
    ];
    final labels = [
      strings.t('dashboard.title'),
      strings.t('catalog.title'),
      strings.t('comparison.title'),
      strings.t('schedule.title'),
      strings.t('logs.title'),
      strings.t('analytics.title'),
      strings.t('settings.title'),
    ];

    return ResponsiveLayout(
      mobile: _buildMobileNav(icons, labels),
      tablet: _buildRail(icons, labels),
    );
  }

  Widget _buildMobileNav(List<IconData> icons, List<String> labels) {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: KeyedSubtree(key: ValueKey(currentIndex), child: pages[currentIndex]),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            final active = currentIndex == index;
            return GestureDetector(
              onTap: () => setState(() => currentIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF222527) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icons[index],
                  color: active ? Colors.white : Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRail(List<IconData> icons, List<String> labels) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            selectedIndex: currentIndex,
            onDestinationSelected: (value) => setState(() => currentIndex = value),
            destinations: [
              for (var i = 0; i < icons.length; i++)
                NavigationRailDestination(
                  icon: Icon(icons[i]),
                  label: Text(labels[i]),
                )
            ],
          ),
          Expanded(
            child: PageTransitionSwitcher(
              transitionBuilder: (child, animation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.scaled,
                  child: child,
                );
              },
              child: KeyedSubtree(key: ValueKey(currentIndex), child: pages[currentIndex]),
            ),
          ),
        ],
      ),
    );
  }
}
