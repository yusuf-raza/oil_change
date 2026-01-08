import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/app_strings.dart';
import '../../models/enums.dart';
import '../../models/fuel_stop.dart';
import '../../models/tour_entry.dart';
import '../../viewmodels/tour_detail_view_model.dart';
import 'widgets/tour_full_screen_map.dart';
import 'widgets/tour_map_preview.dart';
import 'widgets/tour_timeline_item.dart';

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
    final viewModel = TourDetailViewModel(
      tour: tour,
      unitLabel: unitLabel,
      currentUnit: currentUnit,
    );
    final localizations = MaterialLocalizations.of(context);
    final summary = viewModel.buildSummary(localizations);
    final timelineItems = viewModel.buildTimelineItems(localizations);
    final points = viewModel.mapPoints;
    final markerData = viewModel.buildMapMarkers();

    return Scaffold(
      appBar: AppBar(title: Text(tour.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🗓️ ${summary.dateText} • ${summary.timeText}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Text('🧭 ${AppStrings.tourSummaryMileage} ${summary.distanceText}'),
                    const SizedBox(height: 6),
                    Text('⛽ ${AppStrings.tourSummaryAverage} ${summary.averageText}'),
                    const SizedBox(height: 6),
                    Text('🪣 ${AppStrings.tourSummaryFuel} ${summary.fuelText}'),
                    const SizedBox(height: 6),
                    Text('💸 ${AppStrings.tourSummarySpend} ${summary.spendText}'),
                    const SizedBox(height: 12),
                    Text(
                      '🚩 ${AppStrings.tourStartMileage} ${summary.startMileageText}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '🏁 ${AppStrings.tourEndMileage} ${summary.endMileageText}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '⛽ ${AppStrings.tourFuelStopsTitle}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (timelineItems.isEmpty)
              Text(
                '🙈 ${AppStrings.tourNoStops}',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              )
            else
              ...timelineItems.map(
                (item) => TourTimelineItem(
                  isLast: item.isLast,
                  indexLabel: item.indexLabel,
                  title: item.title,
                  subtitle: item.subtitle,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              '🗺️ ${AppStrings.tourMapTitle}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TourMapPreview(
              viewModel: viewModel,
              markerData: markerData,
              onStopTap: (marker) => _showStopDetails(
                context,
                viewModel,
                marker.stop,
                marker.index,
              ),
              points: points,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _openFullScreenMap(context, viewModel, markerData, points),
                icon: const Icon(Icons.fullscreen),
                label: const Text(AppStrings.tourMapFullscreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreenMap(
    BuildContext context,
    TourDetailViewModel viewModel,
    List<TourMapMarkerData> markerData,
    List<LatLng> points,
  ) {
    if (points.isEmpty) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TourFullScreenMap(
          viewModel: viewModel,
          markerData: markerData,
          points: points,
        ),
      ),
    );
  }

  void _showStopDetails(
    BuildContext context,
    TourDetailViewModel viewModel,
    FuelStop stop,
    int index,
  ) {
    final details =
        viewModel.buildStopDetail(stop, index, MaterialLocalizations.of(context));
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
              Text(details.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ...details.lines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(line),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
