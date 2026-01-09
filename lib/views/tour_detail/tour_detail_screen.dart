import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/app_strings.dart';
import '../../models/enums.dart';
import '../../models/fuel_stop.dart';
import '../../models/tour_entry.dart';
import '../../models/tour_expense.dart';
import '../../viewmodels/tour_detail_view_model.dart';
import 'widgets/tour_full_screen_map.dart';
import 'widgets/tour_map_preview.dart';
import 'widgets/tour_timeline_item.dart';

class TourDetailScreen extends StatefulWidget {
  const TourDetailScreen({super.key, required this.tour, required this.unitLabel, required this.currentUnit});

  final TourEntry tour;
  final String unitLabel;
  final OilUnit currentUnit;

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  bool _showOtherBreakdown = false;
  bool _isSharing = false;
  final GlobalKey _summaryCardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final viewModel = TourDetailViewModel(
      tour: widget.tour,
      unitLabel: widget.unitLabel,
      currentUnit: widget.currentUnit,
    );
    final localizations = MaterialLocalizations.of(context);
    final summary = viewModel.buildSummary(localizations);
    final timelineItems = viewModel.buildTimelineItems(localizations);
    final points = viewModel.mapPoints;
    final markerData = viewModel.buildMapMarkers();
    final groupTotal = _sumCategory(widget.tour.expenses, AppStrings.tourExtraExpenseGroupCategory);
    final otherTotal = _sumCategory(widget.tour.expenses, AppStrings.tourExtraExpenseOtherCategory);
    final extraTotal = groupTotal + otherTotal;
    final combinedTotal = widget.tour.totalSpendPkr + extraTotal;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = TextStyle(color: colorScheme.onSurfaceVariant);
    final valueStyle = const TextStyle(fontWeight: FontWeight.w600);
    final rangeText = _formatRange(
      startAt: widget.tour.startAt ?? widget.tour.createdAt,
      endAt: widget.tour.endAt ?? widget.tour.createdAt,
      localizations: localizations,
    );
    final otherBreakdown = _buildOtherBreakdown(widget.tour.expenses);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Stack(
              children: [
                RepaintBoundary(
                  key: _summaryCardKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 54),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              widget.tour.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('🗓️ $rangeText', style: labelStyle),
                          const SizedBox(height: 14),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '🧭 ${AppStrings.tourSummaryMileage} ', style: labelStyle),
                                TextSpan(text: summary.distanceText, style: valueStyle),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '⛽ ${AppStrings.tourSummaryAverage} ', style: labelStyle),
                                TextSpan(text: summary.averageText, style: valueStyle),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '🪣 ${AppStrings.tourSummaryFuel} ', style: labelStyle),
                                TextSpan(text: summary.fuelText, style: valueStyle),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '💸 ${AppStrings.tourSummarySpend} ', style: labelStyle),
                                TextSpan(text: summary.spendText, style: valueStyle),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '👥 ${AppStrings.tourExtraExpenseGroupCategory} ', style: labelStyle),
                                TextSpan(text: 'PKR ${groupTotal.toStringAsFixed(0)}', style: valueStyle),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: otherBreakdown.isEmpty
                                ? null
                                : () {
                                    setState(() {
                                      _showOtherBreakdown = !_showOtherBreakdown;
                                    });
                                  },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '🧾 ${AppStrings.tourExtraExpenseOtherCategory} PKR ${otherTotal.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  if (otherBreakdown.isNotEmpty)
                                    Icon(
                                      _showOtherBreakdown ? Icons.expand_less : Icons.expand_more,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_showOtherBreakdown && otherBreakdown.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            ...otherBreakdown.entries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key, style: labelStyle),
                                    Text('PKR ${entry.value.toStringAsFixed(0)}', style: valueStyle),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '💰 ${AppStrings.tourExpenseCombinedTotalLabel} PKR ${combinedTotal.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Center(
                    child: OutlinedButton.icon(
                      onPressed: _isSharing ? null : () => _shareSummaryCard(context),
                      icon: const Icon(Icons.share),
                      label: const Text(AppStrings.share),
                    ),
                  ),
                ),
              ],
            ),
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
            Text('🗺️ ${AppStrings.tourMapTitle}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TourMapPreview(
              viewModel: viewModel,
              markerData: markerData,
              onStopTap: (marker) => _showStopDetails(context, viewModel, marker.stop, marker.index),
              points: points,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _openFullScreenMap(context, viewModel, markerData, points),
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
        builder: (context) => TourFullScreenMap(viewModel: viewModel, markerData: markerData, points: points),
      ),
    );
  }

  void _showStopDetails(BuildContext context, TourDetailViewModel viewModel, FuelStop stop, int index) {
    final details = viewModel.buildStopDetail(stop, index, MaterialLocalizations.of(context));
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
              ...details.lines.map((line) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(line))),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareSummaryCard(BuildContext context) async {
    if (_isSharing) {
      return;
    }
    setState(() {
      _isSharing = true;
    });
    try {
      final boundary = _summaryCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        return;
      }
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        return;
      }
      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/tour-summary-${widget.tour.id}.png');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppStrings.shareFailed)));
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSharing = false;
      });
    }
  }
}

double _sumCategory(List<TourExpense> expenses, String category) {
  return expenses
      .where((expense) => (expense.category ?? expense.title) == category)
      .fold(0.0, (sum, expense) => sum + expense.amountPkr);
}

Map<String, double> _buildOtherBreakdown(List<TourExpense> expenses) {
  final breakdown = <String, double>{};
  for (final expense in expenses) {
    if ((expense.category ?? expense.title) != AppStrings.tourExtraExpenseOtherCategory) {
      continue;
    }
    final key = (expense.subcategory == null || expense.subcategory!.isEmpty)
        ? AppStrings.tourExtraExpenseUncategorized
        : expense.subcategory!;
    breakdown.update(key, (value) => value + expense.amountPkr, ifAbsent: () => expense.amountPkr);
  }
  return breakdown;
}

String _formatRange({
  required DateTime startAt,
  required DateTime endAt,
  required MaterialLocalizations localizations,
}) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final startDate = '${startAt.day} ${months[startAt.month - 1]}';
  final endDate = '${endAt.day} ${months[endAt.month - 1]}';
  final startTime = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(startAt), alwaysUse24HourFormat: false);
  final endTime = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(endAt), alwaysUse24HourFormat: false);
  return '$startDate ($startTime) - $endDate ($endTime)';
}
