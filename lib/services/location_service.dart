import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationPoint {
  const LocationPoint({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  final String label;
  final double latitude;
  final double longitude;
}

abstract class LocationServiceBase {
  Future<String?> getLocationLabel();
  Future<LocationPoint?> getLocationPoint();
}

class LocationService implements LocationServiceBase {
  @override
  Future<String?> getLocationLabel() async {
    final point = await getLocationPoint();
    return point?.label;
  }

  @override
  Future<LocationPoint?> getLocationPoint() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final parts = <String>[
        if ((place?.name ?? '').isNotEmpty) place!.name!,
        if ((place?.locality ?? '').isNotEmpty) place!.locality!,
        if ((place?.administrativeArea ?? '').isNotEmpty)
          place!.administrativeArea!,
      ];
      final label = parts.isEmpty
          ? 'Lat ${position.latitude.toStringAsFixed(4)}, '
              'Lng ${position.longitude.toStringAsFixed(4)}'
          : parts.join(', ');

      return LocationPoint(
        label: label,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }
}
