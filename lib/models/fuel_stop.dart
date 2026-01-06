class FuelStop {
  const FuelStop({
    required this.amountPkr,
    required this.liters,
    this.location,
    this.timestamp,
    this.latitude,
    this.longitude,
  });

  final double amountPkr;
  final double liters;
  final String? location;
  final DateTime? timestamp;
  final double? latitude;
  final double? longitude;

  Map<String, dynamic> toMap() {
    return {
      'amount_pkr': amountPkr,
      'liters': liters,
      if (location != null) 'location': location,
      if (timestamp != null) 'timestamp': timestamp!.millisecondsSinceEpoch,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  static FuelStop? fromMap(Map<String, dynamic> data) {
    final amount = data['amount_pkr'];
    final liters = data['liters'];
    final location = data['location'];
    final timestamp = data['timestamp'];
    final latitude = data['latitude'];
    final longitude = data['longitude'];
    if (amount is! num || liters is! num) {
      return null;
    }
    return FuelStop(
      amountPkr: amount.toDouble(),
      liters: liters.toDouble(),
      location: location is String && location.isNotEmpty ? location : null,
      timestamp: timestamp is int
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : null,
      latitude: latitude is num ? latitude.toDouble() : null,
      longitude: longitude is num ? longitude.toDouble() : null,
    );
  }
}
