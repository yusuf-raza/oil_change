import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../../constants/app_strings.dart';
import '../../../viewmodels/tour_detail_view_model.dart';

class TourFullScreenMap extends StatelessWidget {
  const TourFullScreenMap({
    super.key,
    required this.viewModel,
    required this.markerData,
    required this.points,
  });

  final TourDetailViewModel viewModel;
  final List<TourMapMarkerData> markerData;
  final List<LatLng> points;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.tourMapTitle)),
      body: SafeArea(
        child: _TourFullScreenMapBody(
          viewModel: viewModel,
          markerData: markerData,
          points: points,
        ),
      ),
    );
  }
}

class _TourFullScreenMapBody extends StatefulWidget {
  const _TourFullScreenMapBody({
    required this.viewModel,
    required this.markerData,
    required this.points,
  });

  final TourDetailViewModel viewModel;
  final List<TourMapMarkerData> markerData;
  final List<LatLng> points;

  @override
  State<_TourFullScreenMapBody> createState() => _TourFullScreenMapBodyState();
}

class _TourFullScreenMapBodyState extends State<_TourFullScreenMapBody> {
  late final MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: widget.viewModel.initialCenter(widget.points),
            initialZoom: widget.viewModel.initialZoom(widget.points),
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(urlTemplate: urlTemplate, userAgentPackageName: 'com.oil.change'),
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
                markers: _buildMarkers(context),
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
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'full-recenter',
            onPressed: () {
              widget.viewModel.recenter(_controller, widget.points);
            },
            backgroundColor: theme.colorScheme.surface,
            child: Icon(Icons.my_location, color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
    return widget.markerData
        .map(
          (marker) => Marker(
            point: marker.point,
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () => _showStopDetails(context, marker),
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

  void _showStopDetails(BuildContext context, TourMapMarkerData marker) {
    final details = widget.viewModel.buildStopDetail(
      marker.stop,
      marker.index,
      MaterialLocalizations.of(context),
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
