import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../constants/app_strings.dart';
import '../models/enums.dart';
import '../models/fuel_stop.dart';
import '../models/tour_entry.dart';

class TourDetailSummary {
  const TourDetailSummary({
    required this.dateText,
    required this.timeText,
    required this.distanceText,
    required this.averageText,
    required this.fuelText,
    required this.spendText,
    required this.startMileageText,
    required this.endMileageText,
  });

  final String dateText;
  final String timeText;
  final String distanceText;
  final String averageText;
  final String fuelText;
  final String spendText;
  final String startMileageText;
  final String endMileageText;
}

class TourStopTimelineItemData {
  const TourStopTimelineItemData({
    required this.isLast,
    required this.indexLabel,
    required this.title,
    required this.subtitle,
    required this.stop,
  });

  final bool isLast;
  final String indexLabel;
  final String title;
  final String subtitle;
  final FuelStop stop;
}

class TourStopDetailData {
  const TourStopDetailData({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<String> lines;
}

class TourMapMarkerData {
  const TourMapMarkerData({
    required this.point,
    required this.index,
    required this.stop,
  });

  final LatLng point;
  final int index;
  final FuelStop stop;
}

class TourDetailViewModel {
  TourDetailViewModel({
    required this.tour,
    required this.unitLabel,
    required this.currentUnit,
  });

  final TourEntry tour;
  final String unitLabel;
  final OilUnit currentUnit;

  TourDetailSummary buildSummary(MaterialLocalizations localizations) {
    final dateText = localizations.formatFullDate(tour.createdAt);
    final timeText =
        localizations.formatTimeOfDay(TimeOfDay.fromDateTime(tour.createdAt));
    final convertedDistance =
        convertDistance(tour.distanceKm.toDouble(), tour.unit);
    final convertedAverage = tour.totalLiters > 0
        ? convertDistance(tour.distanceKm / tour.totalLiters, tour.unit)
            .toStringAsFixed(2)
        : AppStrings.placeholder;

    return TourDetailSummary(
      dateText: dateText,
      timeText: timeText,
      distanceText:
          '${convertedDistance.toStringAsFixed(0)} $unitLabel',
      averageText: '$convertedAverage $unitLabel/L',
      fuelText: '${tour.totalLiters.toStringAsFixed(2)} L',
      spendText: 'PKR ${tour.totalSpendPkr.toStringAsFixed(0)}',
      startMileageText:
          '${convertDistance(tour.startMileage.toDouble(), tour.unit).toStringAsFixed(0)} $unitLabel',
      endMileageText:
          '${convertDistance(tour.endMileage.toDouble(), tour.unit).toStringAsFixed(0)} $unitLabel',
    );
  }

  List<TourStopTimelineItemData> buildTimelineItems(
    MaterialLocalizations localizations,
  ) {
    final distanceCalc = const Distance();
    return List.generate(tour.stops.length, (index) {
      final stop = tour.stops[index];
      final isLast = index == tour.stops.length - 1;
      final location = stop.location ?? AppStrings.tourLocationUnknown;
      final stopDate = stop.timestamp == null
          ? null
          : localizations.formatFullDate(stop.timestamp!);
      final stopTime = stop.timestamp == null
          ? null
          : localizations.formatTimeOfDay(TimeOfDay.fromDateTime(stop.timestamp!));
      final nextStop = !isLast ? tour.stops[index + 1] : null;
      final segment = segmentDistance(distanceCalc, stop, nextStop);
      final subtitleLines = <String>[
        '💸 PKR ${stop.amountPkr.toStringAsFixed(0)}',
        '📍 $location',
        if (stopDate != null && stopTime != null) '🕒 $stopDate • $stopTime',
        if (segment != null)
          '↔ ${segment.toStringAsFixed(2)} $unitLabel to next stop',
      ];
      return TourStopTimelineItemData(
        isLast: isLast,
        indexLabel: '${index + 1}',
        title: '🪣 ${stop.liters.toStringAsFixed(2)} L',
        subtitle: subtitleLines.join('\n'),
        stop: stop,
      );
    });
  }

  TourStopDetailData buildStopDetail(
    FuelStop stop,
    int index,
    MaterialLocalizations localizations,
  ) {
    final stopDate = stop.timestamp == null
        ? null
        : localizations.formatFullDate(stop.timestamp!);
    final stopTime = stop.timestamp == null
        ? null
        : localizations.formatTimeOfDay(TimeOfDay.fromDateTime(stop.timestamp!));
    final lines = <String>[
      '🪣 ${stop.liters.toStringAsFixed(2)} L',
      '💸 PKR ${stop.amountPkr.toStringAsFixed(0)}',
      '📍 ${stop.location ?? AppStrings.tourLocationUnknown}',
    ];
    if (stopDate != null && stopTime != null) {
      lines.add('🕒 $stopDate • $stopTime');
    }
    return TourStopDetailData(
      title: '⛽ Stop $index',
      lines: lines,
    );
  }

  List<LatLng> get mapPoints => tour.stops
      .where((stop) => stop.latitude != null && stop.longitude != null)
      .map((stop) => LatLng(stop.latitude!, stop.longitude!))
      .toList();

  List<TourMapMarkerData> buildMapMarkers() {
    final points = mapPoints;
    final markers = <TourMapMarkerData>[];
    for (var i = 0; i < tour.stops.length; i++) {
      final stop = tour.stops[i];
      if (stop.latitude == null || stop.longitude == null) {
        continue;
      }
      final basePoint = LatLng(stop.latitude!, stop.longitude!);
      final point = offsetPoint(points, basePoint, i);
      markers.add(
        TourMapMarkerData(
          point: point,
          index: i + 1,
          stop: stop,
        ),
      );
    }
    return markers;
  }

  double convertDistance(double value, String fromUnit) {
    final from =
        fromUnit == OilUnit.miles.name ? OilUnit.miles : OilUnit.kilometers;
    if (from == currentUnit) {
      return value;
    }
    const factor = 0.621371;
    return currentUnit == OilUnit.miles ? value * factor : value / factor;
  }

  double? segmentDistance(
    Distance distanceCalc,
    FuelStop stop,
    FuelStop? nextStop,
  ) {
    if (nextStop == null) {
      return null;
    }
    if (stop.latitude == null ||
        stop.longitude == null ||
        nextStop.latitude == null ||
        nextStop.longitude == null) {
      return null;
    }
    final meters = distanceCalc(
      LatLng(stop.latitude!, stop.longitude!),
      LatLng(nextStop.latitude!, nextStop.longitude!),
    );
    final kilometers = meters / 1000.0;
    const factor = 0.621371;
    return currentUnit == OilUnit.miles ? kilometers * factor : kilometers;
  }

  LatLng initialCenter(List<LatLng> points) {
    if (points.isEmpty) {
      return const LatLng(0, 0);
    }
    return points.first;
  }

  double initialZoom(List<LatLng> points) {
    if (points.length <= 1 || allSame(points)) {
      return 14;
    }
    return 11;
  }

  void recenter(MapController controller, List<LatLng> points) {
    if (points.isEmpty) {
      return;
    }
    if (points.length == 1 || allSame(points)) {
      controller.move(points.first, 14);
      return;
    }
    controller.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(30),
      ),
    );
  }

  bool allSame(List<LatLng> points) {
    if (points.isEmpty) {
      return true;
    }
    final first = points.first;
    for (final point in points) {
      if ((point.latitude - first.latitude).abs() > 0.00001 ||
          (point.longitude - first.longitude).abs() > 0.00001) {
        return false;
      }
    }
    return true;
  }

  LatLng offsetPoint(List<LatLng> points, LatLng point, int index) {
    if (!allSame(points)) {
      return point;
    }
    final angle = (index % 12) * (math.pi / 6);
    final radius = 0.0003 + (index ~/ 12) * 0.0002;
    return LatLng(
      point.latitude + radius * math.sin(angle),
      point.longitude + radius * math.cos(angle),
    );
  }
}
