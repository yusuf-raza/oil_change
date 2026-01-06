import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../constants/app_strings.dart';
import '../models/enums.dart';
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
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeline(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
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
    final markers = <Marker>[];
    for (var i = 0; i < tour.stops.length; i++) {
      final stop = tour.stops[i];
      if (stop.latitude == null || stop.longitude == null) {
        continue;
      }
      markers.add(
        Marker(
          point: LatLng(stop.latitude!, stop.longitude!),
          width: 44,
          height: 44,
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
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: points.first,
            initialZoom: 12,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.oil_change',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
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
