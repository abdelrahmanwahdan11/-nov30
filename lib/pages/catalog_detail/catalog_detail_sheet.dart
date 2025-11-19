import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/pod.dart';
import '../../widgets/ai_info_button.dart';

class CatalogDetailSheet extends StatefulWidget {
  const CatalogDetailSheet({super.key, required this.pod});

  final Pod pod;

  @override
  State<CatalogDetailSheet> createState() => _CatalogDetailSheetState();
}

class _CatalogDetailSheetState extends State<CatalogDetailSheet> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  bool flipped = false;

  void _toggle() {
    setState(() => flipped = !flipped);
    if (flipped) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final angle = controller.value * math.pi;
            final isBack = angle > math.pi / 2;
            return Transform(
              transform: Matrix4.rotationY(angle),
              alignment: Alignment.center,
              child: isBack ? _buildBack() : _buildFront(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront() {
    final pod = widget.pod;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(pod.imageUrl, height: 160, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(pod.name, style: Theme.of(context).textTheme.titleLarge),
          Text(pod.location),
          const SizedBox(height: 12),
          const AiInfoButton(),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final pod = widget.pod;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${(pod.waterLevelPercent * 100).toStringAsFixed(0)}% water'),
          Text('Humidity ${(pod.humidityPercent * 100).toStringAsFixed(0)}%'),
          Text('Temperature ${pod.waterTemperature}°C'),
          const SizedBox(height: 12),
          const AiInfoButton(),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
