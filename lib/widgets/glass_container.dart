import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({super.key, this.child, this.onTap});

  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor.withOpacity(0.8);
    final radius = BorderRadius.circular(24);
    final content = Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: content,
    );
  }
}
