import 'package:flutter/material.dart';

import '../../controllers/logs_controller.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final LogsController controller = LogsController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logs')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: controller.logEntries.length,
              itemBuilder: (context, index) {
                final entry = controller.logEntries[index];
                return ListTile(
                  title: Text(entry.message),
                  subtitle: Text(entry.timestamp.toIso8601String()),
                  trailing: Text(entry.type.toUpperCase()),
                );
              },
            ),
          ),
          TextButton(
            onPressed: () async {
              await controller.loadMore();
              setState(() {});
            },
            child: const Text('Load more'),
          ),
        ],
      ),
    );
  }
}
