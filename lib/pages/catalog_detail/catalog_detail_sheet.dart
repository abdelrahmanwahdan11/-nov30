import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/pod.dart';
import '../../widgets/ai_info_button.dart';

class CatalogDetailSheet extends StatefulWidget {
  const CatalogDetailSheet({super.key, required this.pod, this.onToggleFavorite});

  final Pod pod;
  final ValueChanged<String>? onToggleFavorite;

  @override
  State<CatalogDetailSheet> createState() => _CatalogDetailSheetState();
}

class _CatalogDetailSheetState extends State<CatalogDetailSheet> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  bool flipped = false;
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.pod.isFavorite;
  }

  void _toggle() {
    setState(() => flipped = !flipped);
    if (flipped) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  void _toggleFavorite() {
    setState(() => isFavorite = !isFavorite);
    widget.onToggleFavorite?.call(widget.pod.id);
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
    final strings = AppLocalizations.of(context);
    final elementLabel = strings.t('catalog.element.${pod.elementType}');
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pod.name, style: Theme.of(context).textTheme.titleLarge),
                    Text(pod.location),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.pinkAccent : null,
                ),
                onPressed: _toggleFavorite,
                tooltip: isFavorite
                    ? strings.t('catalog.favorite_added')
                    : strings.t('catalog.favorite_add'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Chip(label: Text(elementLabel)),
          if (pod.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in pod.tags)
                    Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
          const AiInfoButton(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.t('common.close')),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final pod = widget.pod;
    final strings = AppLocalizations.of(context);
    final elementLabel = strings.t('catalog.element.${pod.elementType}');
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MetricChip(label: strings.t('catalog.filters.element'), value: elementLabel),
              _MetricChip(
                label: strings.t('catalog.filters.status'),
                value: '${(pod.waterLevelPercent * 100).toStringAsFixed(0)}%',
              ),
              _MetricChip(
                label: strings.t('dashboard.metrics.humidity'),
                value: '${(pod.humidityPercent * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
          const SizedBox(height: 8),
          _MetricChip(
            label: strings.t('dashboard.metrics.temperature'),
            value: '${pod.waterTemperature}°C',
          ),
          const SizedBox(height: 12),
          const AiInfoButton(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.t('common.close')),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
