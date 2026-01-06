import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../constants/app_strings.dart';
import '../models/enums.dart';
import '../models/fuel_stop.dart';
import '../models/tour_entry.dart';

class TourDetailScreen extends StatelessWidget {
  const TourDetailScreen({
    super.key,
    required this.tour,
    required this.unitLabel,
    required this.currentUnit,
  });

  final TourEntry tour;
  final String unitLabel;
  final OilUnit currentUnit;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final dateText = localizations.formatFullDate(tour.createdAt);
    final timeText = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(tour.createdAt),
    );
    final convertedDistance = _convertDistance(
      tour.distanceKm.toDouble(),
      tour.unit,
    );
    final convertedAverage = tour.totalLiters > 0
        ? _convertDistance(
            tour.distanceKm / tour.totalLiters,
            tour.unit,
          ).toStringAsFixed(2)
        : AppStrings.placeholder;

    return Scaffold(
      appBar: AppBar(
        title: Text(tour.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🗓️ $dateText • $timeText',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '🧭 ${AppStrings.tourSummaryMileage} '
                      '${convertedDistance.toStringAsFixed(0)} $unitLabel',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⛽ ${AppStrings.tourSummaryAverage} '
                      '$convertedAverage $unitLabel/L',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '🪣 ${AppStrings.tourSummaryFuel} '
                      '${tour.totalLiters.toStringAsFixed(2)} L',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '💸 ${AppStrings.tourSummarySpend} '
                      'PKR ${tour.totalSpendPkr.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '🚩 ${AppStrings.tourStartMileage} '
                      '${_convertDistance(tour.startMileage.toDouble(), tour.unit).toStringAsFixed(0)} $unitLabel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🏁 ${AppStrings.tourEndMileage} '
                      '${_convertDistance(tour.endMileage.toDouble(), tour.unit).toStringAsFixed(0)} $unitLabel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '⛽ ${AppStrings.tourFuelStopsTitle}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (tour.stops.isEmpty)
              Text(
                '🙈 ${AppStrings.tourNoStops}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              ..._buildTimeline(context),
            const SizedBox(height: 20),
            Text(
              '🗺️ ${AppStrings.tourMapTitle}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildMapSection(context),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _openFullScreenMap(context),
                icon: const Icon(Icons.fullscreen),
                label: const Text(AppStrings.tourMapFullscreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeline(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final distanceCalc = const Distance();
    final items = <Widget>[];
    for (var i = 0; i < tour.stops.length; i++) {
      final stop = tour.stops[i];
      final isLast = i == tour.stops.length - 1;
      final location = stop.location ?? AppStrings.tourLocationUnknown;
      final stopDate = stop.timestamp == null
          ? null
          : localizations.formatFullDate(stop.timestamp!);
      final stopTime = stop.timestamp == null
          ? null
          : localizations.formatTimeOfDay(
              TimeOfDay.fromDateTime(stop.timestamp!),
            );
      final nextStop = !isLast ? tour.stops[i + 1] : null;
      final segmentDistance = _segmentDistance(
        distanceCalc,
        stop,
        nextStop,
      );
      items.add(
        _TimelineItem(
          isLast: isLast,
          indexLabel: '${i + 1}',
          title: '🪣 ${stop.liters.toStringAsFixed(2)} L',
          subtitle: [
            '💸 PKR ${stop.amountPkr.toStringAsFixed(0)}',
            '📍 $location',
            if (stopDate != null && stopTime != null)
              '🕒 $stopDate • $stopTime',
            if (segmentDistance != null)
              '↔ ${segmentDistance.toStringAsFixed(2)} $unitLabel to next stop',
          ].join('\n'),
        ),
      );
    }
    return items;
  }

  Widget _buildMapSection(BuildContext context) {
    final points = tour.stops
        .where((stop) => stop.latitude != null && stop.longitude != null)
        .map((stop) => LatLng(stop.latitude!, stop.longitude!))
        .toList();
    if (points.isEmpty) {
      return Text(
        '🧭 ${AppStrings.tourMapEmpty}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    final markers = _buildMarkers(context, points);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: _buildMap(
          context,
          markers,
          points,
        ),
      ),
    );
  }

  void _openFullScreenMap(BuildContext context) {
    final points = tour.stops
        .where((stop) => stop.latitude != null && stop.longitude != null)
        .map((stop) => LatLng(stop.latitude!, stop.longitude!))
        .toList();
    if (points.isEmpty) {
      return;
    }
    final markers = _buildMarkers(context, points);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _FullScreenMap(
          markers: markers,
          points: points,
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context, List<LatLng> points) {
    final markers = <Marker>[];
    for (var i = 0; i < tour.stops.length; i++) {
      final stop = tour.stops[i];
      if (stop.latitude == null || stop.longitude == null) {
        continue;
      }
      final basePoint = LatLng(stop.latitude!, stop.longitude!);
      final point = _offsetPoint(points, basePoint, i);
      markers.add(
        Marker(
          point: point,
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () => _showStopDetails(context, stop, i + 1),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                  size: 34,
                ),
                Positioned(
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildMap(
    BuildContext context,
    List<Marker> markers,
    List<LatLng> points,
  ) {
    final theme = Theme.of(context);
    final controller = MapController();
    final bounds = LatLngBounds.fromPoints(points);
    final polylines = [
      Polyline(
        points: points,
        color: theme.colorScheme.primary.withOpacity(0.5),
        strokeWidth: 4,
      ),
    ];
    const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: _initialCenter(points),
            initialZoom: _initialZoom(points),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: urlTemplate,
              userAgentPackageName: 'com.oil.change',
            ),
            PolylineLayer(polylines: polylines),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                markers: markers,
                maxClusterRadius: 45,
                size: const Size(42, 42),
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: FloatingActionButton.small(
            heroTag: '${tour.id}-recenter',
            onPressed: () {
              _recenter(controller, points);
            },
            backgroundColor: theme.colorScheme.surface,
            child: Icon(
              Icons.my_location,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  double _convertDistance(double value, String fromUnit) {
    final from = fromUnit == OilUnit.miles.name
        ? OilUnit.miles
        : OilUnit.kilometers;
    if (from == currentUnit) {
      return value;
    }
    const factor = 0.621371;
    return currentUnit == OilUnit.miles ? value * factor : value / factor;
  }

  double? _segmentDistance(
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

  LatLng _initialCenter(List<LatLng> points) {
    if (points.isEmpty) {
      return const LatLng(0, 0);
    }
    return points.first;
  }

  double _initialZoom(List<LatLng> points) {
    if (points.length <= 1 || _allSame(points)) {
      return 14;
    }
    return 11;
  }

  void _recenter(MapController controller, List<LatLng> points) {
    if (points.isEmpty) {
      return;
    }
    if (points.length == 1 || _allSame(points)) {
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

  bool _allSame(List<LatLng> points) {
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

  LatLng _offsetPoint(List<LatLng> points, LatLng point, int index) {
    if (!_allSame(points)) {
      return point;
    }
    final angle = (index % 12) * (3.14159 / 6);
    final radius = 0.0003 + (index ~/ 12) * 0.0002;
    return LatLng(
      point.latitude + radius * Math.sin(angle),
      point.longitude + radius * Math.cos(angle),
    );
  }

  void _showStopDetails(BuildContext context, FuelStop stop, int index) {
    final localizations = MaterialLocalizations.of(context);
    final stopDate = stop.timestamp == null
        ? null
        : localizations.formatFullDate(stop.timestamp!);
    final stopTime = stop.timestamp == null
        ? null
        : localizations.formatTimeOfDay(
            TimeOfDay.fromDateTime(stop.timestamp!),
          );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⛽ Stop $index',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text('🪣 ${stop.liters.toStringAsFixed(2)} L'),
              const SizedBox(height: 6),
              Text('💸 PKR ${stop.amountPkr.toStringAsFixed(0)}'),
              const SizedBox(height: 6),
              Text('📍 ${stop.location ?? AppStrings.tourLocationUnknown}'),
              if (stopDate != null && stopTime != null) ...[
                const SizedBox(height: 6),
                Text('🕒 $stopDate • $stopTime'),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FullScreenMap extends StatelessWidget {
  const _FullScreenMap({
    required this.markers,
    required this.points,
  });

  final List<Marker> markers;
  final List<LatLng> points;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tourMapTitle),
      ),
      body: SafeArea(
        child: _FullScreenMapBody(
          markers: markers,
          points: points,
        ),
      ),
    );
  }
}

class _FullScreenMapBody extends StatefulWidget {
  const _FullScreenMapBody({
    required this.markers,
    required this.points,
  });

  final List<Marker> markers;
  final List<LatLng> points;

  @override
  State<_FullScreenMapBody> createState() => _FullScreenMapBodyState();
}

class _FullScreenMapBodyState extends State<_FullScreenMapBody> {
  late final MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bounds = LatLngBounds.fromPoints(widget.points);
    const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter:
                widget.points.isEmpty ? const LatLng(0, 0) : widget.points.first,
            initialZoom: widget.points.length <= 1 ? 14 : 11,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: urlTemplate,
              userAgentPackageName: 'com.oil.change',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: widget.points,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  strokeWidth: 4,
                ),
              ],
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                markers: widget.markers,
                maxClusterRadius: 45,
                size: const Size(42, 42),
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'full-recenter',
            onPressed: () {
              if (widget.points.isEmpty) {
                return;
              }
              if (widget.points.length == 1) {
                _controller.move(widget.points.first, 14);
                return;
              }
              _controller.fitCamera(
                CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(30),
                ),
              );
            },
            backgroundColor: theme.colorScheme.surface,
            child: Icon(
              Icons.my_location,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.isLast,
    required this.indexLabel,
    required this.title,
    required this.subtitle,
  });

  final bool isLast;
  final String indexLabel;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineColor = theme.colorScheme.primary.withOpacity(0.4);
    final dotColor = theme.colorScheme.primary;
    final badgeColor = theme.colorScheme.primary.withOpacity(0.12);
    final badgeTextColor = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    indexLabel,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    height: 56,
                    width: 3,
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: lineColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
