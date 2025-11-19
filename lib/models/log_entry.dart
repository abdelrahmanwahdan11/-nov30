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

  LogEntry copyWith({
    String? id,
    String? podId,
    DateTime? timestamp,
    String? message,
    String? type,
  }) {
    return LogEntry(
      id: id ?? this.id,
      podId: podId ?? this.podId,
      timestamp: timestamp ?? this.timestamp,
      message: message ?? this.message,
      type: type ?? this.type,
    );
  }
}
