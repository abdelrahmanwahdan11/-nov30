class PodAlert {
  const PodAlert({
    required this.id,
    required this.podId,
    required this.podName,
    required this.location,
    required this.reason,
    required this.severity,
    required this.timestamp,
  });

  final String id;
  final String podId;
  final String podName;
  final String location;
  final String reason; // e.g. offline, lowWater
  final String severity; // e.g. warning, critical
  final DateTime timestamp;
}
