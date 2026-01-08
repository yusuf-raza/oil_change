import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../../constants/app_strings.dart';
import '../../../viewmodels/tour_detail_view_model.dart';

class TourMapPreview extends StatelessWidget {
  const TourMapPreview({
    super.key,
    required this.viewModel,
    required this.markerData,
    required this.onStopTap,
    required this.points,
  });

  final TourDetailViewModel viewModel;
  final List<TourMapMarkerData> markerData;
  final void Function(TourMapMarkerData marker) onStopTap;
  final List<LatLng> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Text(
        '🧭 ${AppStrings.tourMapEmpty}',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 220,
        child: _buildMap(context, _buildMarkers(context), points),
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
    return markerData
        .map(
          (marker) => Marker(
            point: marker.point,
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => onStopTap(marker),
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
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                      ),
                      child: Text(
                        '${marker.index}',
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
        )
        .toList();
  }

  Widget _buildMap(BuildContext context, List<Marker> markers, List<LatLng> points) {
    final theme = Theme.of(context);
    final controller = MapController();
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
            initialCenter: viewModel.initialCenter(points),
            initialZoom: viewModel.initialZoom(points),
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(urlTemplate: urlTemplate, userAgentPackageName: 'com.oil.change'),
            PolylineLayer(polylines: polylines),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                markers: markers,
                maxClusterRadius: 45,
                size: const Size(42, 42),
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
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
            heroTag: '${viewModel.tour.id}-recenter',
            onPressed: () => viewModel.recenter(controller, points),
            backgroundColor: theme.colorScheme.surface,
            child: Icon(Icons.my_location, color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
