import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.mobile, required this.tablet});

  final Widget mobile;
  final Widget tablet;

  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 800;

  @override
  Widget build(BuildContext context) {
    return isTablet(context) ? tablet : mobile;
  }
}
