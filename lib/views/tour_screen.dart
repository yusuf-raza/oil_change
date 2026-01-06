import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../viewmodels/tour_view_model.dart';
import '../viewmodels/oil_view_model.dart';
import '../models/enums.dart';
import 'tour_detail_screen.dart';

class TourScreen extends StatefulWidget {
  const TourScreen({super.key});

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  late final TourViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TourViewModel();
    _viewModel.loadTours();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? const Color(AppColors.darkSurface)
        : const Color(AppColors.lightSurface);
    final backgroundGradient = LinearGradient(
      colors: isDark
          ? const [
              Color(AppColors.darkBackgroundStart),
              Color(AppColors.darkBackgroundEnd),
            ]
          : const [
              Color(AppColors.lightBackgroundStart),
              Color(AppColors.lightBackgroundEnd),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return ChangeNotifierProvider<TourViewModel>.value(
      value: _viewModel,
      child: Consumer<TourViewModel>(
        builder: (context, viewModel, child) {
          final oilViewModel = context.watch<OilViewModel>();
          final unitLabel = oilViewModel.unitLabel;
          final currentUnit = oilViewModel.unit;
          final distance = viewModel.distanceKm;
          final summary = viewModel.buildSummary();
          final totalLiters = summary?.totalLiters.toStringAsFixed(2) ??
              AppStrings.placeholder;
          final totalSpend = summary?.totalSpendPkr.toStringAsFixed(0) ??
              AppStrings.placeholder;
          final average = summary?.averageKmPerLiter == null
              ? AppStrings.placeholder
              : summary!.averageKmPerLiter!.toStringAsFixed(2);
          return Container(
            decoration: BoxDecoration(gradient: backgroundGradient),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🏍️ ${AppStrings.tourTitle}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.tourSubtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🧭 ${AppStrings.tourMileageTitle}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: viewModel.titleController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: AppStrings.tourTitleLabel,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: viewModel.startMileageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${AppStrings.tourStartMileage} ($unitLabel)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: viewModel.endMileageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${AppStrings.tourEndMileage} ($unitLabel)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      distance == null
                          ? '📏 ${AppStrings.tourDistancePlaceholder}'
                          : '📏 ${AppStrings.tourDistanceLabel} $distance $unitLabel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '⛽ ${AppStrings.tourFuelStopsTitle}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: viewModel.fuelAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: AppStrings.tourFuelAmount,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: viewModel.fuelLitersController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: AppStrings.tourFuelLiters,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: viewModel.isAddingStop
                            ? null
                            : () async {
                                final error = await viewModel.addFuelStop();
                                if (error != null) {
                                  _showSnack(error);
                                }
                              },
                        icon: viewModel.isAddingStop
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add),
                        label: Text(
                          viewModel.isAddingStop
                              ? AppStrings.tourLoading
                              : '➕ ${AppStrings.tourAddFuelStop}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (viewModel.stops.isEmpty)
                      Text(
                        '🙈 ${AppStrings.tourNoStops}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      ...viewModel.stops.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stop = entry.value;
                        final location = stop.location ??
                            AppStrings.tourLocationUnknown;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '⛽ Stop ${index + 1} • '
                            '🪣 ${stop.liters.toStringAsFixed(2)} L',
                          ),
                          subtitle: Text(
                            '💸 PKR ${stop.amountPkr.toStringAsFixed(0)} • 📍 $location',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => viewModel.removeStop(index),
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    Text(
                      '📊 ${AppStrings.tourSummaryHeader}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🧭 ${AppStrings.tourSummaryMileage} '
                      '${distance ?? AppStrings.placeholder} $unitLabel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⛽ ${AppStrings.tourSummaryAverage} $average $unitLabel/L',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '🪣 ${AppStrings.tourSummaryFuel} $totalLiters L',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '💸 ${AppStrings.tourSummarySpend} PKR $totalSpend',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isSaving
                            ? null
                            : () async {
                                final error =
                                    await viewModel.completeTour(currentUnit);
                                if (error != null) {
                                  _showSnack(error);
                                  return;
                                }
                                _showSnack(AppStrings.tourSaved);
                              },
                        child: viewModel.isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(AppStrings.tourComplete),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '🗂️ ${AppStrings.tourListTitle}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (viewModel.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.tourLoading,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (viewModel.lastError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          viewModel.lastError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    if (viewModel.tours.isEmpty)
                      Text(
                        AppStrings.tourListEmpty,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      ...viewModel.tours.map((tour) {
                        final localizations =
                            MaterialLocalizations.of(context);
                        final dateText =
                            localizations.formatFullDate(tour.createdAt);
                        final timeText = localizations.formatTimeOfDay(
                          TimeOfDay.fromDateTime(tour.createdAt),
                        );
                        final convertedDistance = _convertDistance(
                          tour.distanceKm.toDouble(),
                          tour.unit,
                          currentUnit,
                        );
                        final convertedAverage = _convertDistance(
                          tour.totalLiters > 0
                              ? tour.distanceKm / tour.totalLiters
                              : 0,
                          tour.unit,
                          currentUnit,
                        );
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: surfaceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                          child: ListTile(
                            title: Text(tour.title),
                            subtitle: Text(
                              '$dateText • $timeText\n'
                              '🧭 ${convertedDistance.toStringAsFixed(0)} $unitLabel • '
                              '⛽ ${tour.totalLiters > 0 ? convertedAverage.toStringAsFixed(2) : AppStrings.placeholder} $unitLabel/L\n'
                              '🪣 ${tour.totalLiters.toStringAsFixed(2)} L • '
                              '💸 PKR ${tour.totalSpendPkr.toStringAsFixed(0)}',
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      TourDetailScreen(
                                        tour: tour,
                                        unitLabel: unitLabel,
                                        currentUnit: currentUnit,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _convertDistance(
    double value,
    String fromUnit,
    OilUnit toUnit,
  ) {
    final from = fromUnit == OilUnit.miles.name
        ? OilUnit.miles
        : OilUnit.kilometers;
    if (from == toUnit) {
      return value;
    }
    const factor = 0.621371;
    return toUnit == OilUnit.miles ? value * factor : value / factor;
  }
}
