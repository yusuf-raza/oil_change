import 'fuel_stop.dart';

class TourEntry {
  const TourEntry({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.unit,
    required this.startMileage,
    required this.endMileage,
    required this.distanceKm,
    required this.totalLiters,
    required this.totalSpendPkr,
    required this.stops,
  });

  final String id;
  final DateTime createdAt;
  final String title;
  final String unit;
  final int startMileage;
  final int endMileage;
  final int distanceKm;
  final double totalLiters;
  final double totalSpendPkr;
  final List<FuelStop> stops;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.millisecondsSinceEpoch,
      'title': title,
      'unit': unit,
      'start_mileage': startMileage,
      'end_mileage': endMileage,
      'distance_km': distanceKm,
      'total_liters': totalLiters,
      'total_spend_pkr': totalSpendPkr,
      'stops': stops.map((stop) => stop.toMap()).toList(),
    };
  }

  static TourEntry? fromMap(String id, Map<String, dynamic> data) {
    final idValue = data['id'];
    final createdAt = data['created_at'];
    final title = data['title'];
    final unit = data['unit'];
    final startMileage = data['start_mileage'];
    final endMileage = data['end_mileage'];
    final distanceKm = data['distance_km'];
    final totalLiters = data['total_liters'];
    final totalSpend = data['total_spend_pkr'];
    final stopsRaw = data['stops'];
    if (createdAt is! int ||
        title is! String ||
        startMileage is! int ||
        endMileage is! int ||
        distanceKm is! int ||
        totalLiters is! num ||
        totalSpend is! num ||
        stopsRaw is! List) {
      return null;
    }
    final stops = <FuelStop>[];
    for (final item in stopsRaw) {
      if (item is Map) {
        final stop = FuelStop.fromMap(Map<String, dynamic>.from(item));
        if (stop != null) {
          stops.add(stop);
        }
      }
    }
    final resolvedId = id.isNotEmpty
        ? id
        : idValue is String && idValue.isNotEmpty
            ? idValue
            : createdAt is int
                ? createdAt.toString()
                : '';
    if (resolvedId.isEmpty) {
      return null;
    }
    return TourEntry(
      id: resolvedId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      title: title,
      unit: unit is String && unit.isNotEmpty ? unit : 'kilometers',
      startMileage: startMileage,
      endMileage: endMileage,
      distanceKm: distanceKm,
      totalLiters: totalLiters.toDouble(),
      totalSpendPkr: totalSpend.toDouble(),
      stops: stops,
    );
  }
}
