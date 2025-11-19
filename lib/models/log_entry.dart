class LogEntry {
  LogEntry({
    required this.id,
    required this.podId,
    required this.timestamp,
    required this.message,
    required this.type,
  });

  final String id;
  final String podId;
  final DateTime timestamp;
  final String message;
  final String type;
}
