import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../controllers/analytics_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/analytics_point.dart';
import '../../widgets/glass_container.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final AnalyticsController controller = AnalyticsController();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('analytics.title'))),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final points = _currentPoints();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ToggleButtons(
                  isSelected: [
                    controller.currentTab == 'daily',
                    controller.currentTab == 'weekly',
                    controller.currentTab == 'monthly',
                  ],
                  onPressed: (index) {
                    final tabs = ['daily', 'weekly', 'monthly'];
                    controller.selectTab(tabs[index]);
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(strings.t('analytics.daily')),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(strings.t('analytics.weekly')),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(strings.t('analytics.monthly')),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(IconlyLight.info_square),
                              onPressed: () {},
                            ),
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: _Chart(
                                key: ValueKey(controller.currentTab),
                                points: points,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SummaryTile(
                                label: strings.t('analytics.summary.min'),
                                value: _min(points).toStringAsFixed(1),
                              ),
                              _SummaryTile(
                                label: strings.t('analytics.summary.avg'),
                                value: _avg(points).toStringAsFixed(1),
                              ),
                              _SummaryTile(
                                label: strings.t('analytics.summary.max'),
                                value: _max(points).toStringAsFixed(1),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<AnalyticsPoint> _currentPoints() {
    switch (controller.currentTab) {
      case 'weekly':
        return controller.weeklyStats;
      case 'monthly':
        return controller.monthlyStats;
      default:
        return controller.dailyStats;
    }
  }

  double _min(List<AnalyticsPoint> points) =>
      points.isEmpty ? 0 : points.map((e) => e.value).reduce((a, b) => a < b ? a : b);
  double _max(List<AnalyticsPoint> points) =>
      points.isEmpty ? 0 : points.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  double _avg(List<AnalyticsPoint> points) =>
      points.isEmpty ? 0 : points.map((e) => e.value).reduce((a, b) => a + b) / points.length;
}

class _Chart extends StatelessWidget {
  const _Chart({super.key, required this.points, required this.color});

  final List<AnalyticsPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        painter: _ChartPainter(points, color),
        child: Container(),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter(this.points, this.color);

  final List<AnalyticsPoint> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i].value / 100) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => oldDelegate.points != points;
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label),
      ],
    );
  }
}
