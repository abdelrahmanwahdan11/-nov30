import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../l10n/app_localizations.dart';

class AiInfoButton extends StatelessWidget {
  const AiInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return IconButton(
      tooltip: strings.t('ai.tooltip'),
      icon: const Icon(IconlyLight.info_circle),
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.t('ai.button')),
            content: Text(strings.t('ai.dialog')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}
