import 'package:flutter/material.dart';

import '../../controllers/analytics_controller.dart';
import '../../models/analytics_point.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final AnalyticsController controller = AnalyticsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: [
              controller.currentTab == 'daily',
              controller.currentTab == 'weekly',
              controller.currentTab == 'monthly',
            ],
            onPressed: (index) {
              final tabs = ['daily', 'weekly', 'monthly'];
              setState(() => controller.selectTab(tabs[index]));
            },
            children: const [Text('Daily'), Text('Weekly'), Text('Monthly')],
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _Chart(
                key: ValueKey(controller.currentTab),
                points: _currentPoints(),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
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
}

class _Chart extends StatelessWidget {
  const _Chart({super.key, required this.points, required this.color});

  final List<AnalyticsPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
