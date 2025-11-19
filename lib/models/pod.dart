class Pod {
  Pod({
    required this.id,
    required this.name,
    required this.location,
    required this.waterLevelPercent,
    required this.humidityPercent,
    required this.waterTemperature,
    required this.isOnline,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String location;
  final double waterLevelPercent;
  final double humidityPercent;
  final double waterTemperature;
  final bool isOnline;
  final String imageUrl;

  Pod copyWith({
    String? id,
    String? name,
    String? location,
    double? waterLevelPercent,
    double? humidityPercent,
    double? waterTemperature,
    bool? isOnline,
    String? imageUrl,
  }) {
    return Pod(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      waterLevelPercent: waterLevelPercent ?? this.waterLevelPercent,
      humidityPercent: humidityPercent ?? this.humidityPercent,
      waterTemperature: waterTemperature ?? this.waterTemperature,
      isOnline: isOnline ?? this.isOnline,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
