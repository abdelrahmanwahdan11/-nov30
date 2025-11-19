import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../controllers/app_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.appController});

  final AppController appController;

  @override
  Widget build(BuildContext context) {
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
              title: const Text('Language'),
              trailing: DropdownButton<Locale>(
                value: appController.locale,
                onChanged: (locale) {
                  if (locale != null) appController.updateLocale(locale);
                },
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('ar'), child: Text('Arabic')),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(IconlyLight.show),
              title: const Text('Theme'),
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
            const SizedBox(height: 12),
            const Text('Primary color'),
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
            SwitchListTile(
              title: const Text('Alert sounds'),
              value: true,
              onChanged: (value) {},
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Clear local data'),
            ),
          ],
        );
      },
    );
  }
}
