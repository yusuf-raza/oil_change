import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../viewmodels/oil_view_model.dart';
import '../../viewmodels/tour_view_model.dart';
import '../../data/local/local_tour_draft_repository.dart';
import '../../services/tour_repository.dart';
import '../tour_detail/tour_detail_screen.dart';

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
    _viewModel = TourViewModel(
      repository: context.read<TourRepositoryBase>(),
      draftRepository: context.read<LocalTourDraftRepository>(),
    );
    _viewModel.loadTours();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(AppColors.darkSurface) : const Color(AppColors.lightSurface);
    final backgroundGradient = LinearGradient(
      colors: isDark
          ? const [Color(AppColors.darkBackgroundStart), Color(AppColors.darkBackgroundEnd)]
          : const [Color(AppColors.lightBackgroundStart), Color(AppColors.lightBackgroundEnd)],
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
          final totalLiters = summary?.totalLiters.toStringAsFixed(2) ?? AppStrings.placeholder;
          final totalSpend = summary?.totalSpendPkr.toStringAsFixed(0) ?? AppStrings.placeholder;
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
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.tourSubtitle,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🧭 ${AppStrings.tourMileageTitle}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: viewModel.titleController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: AppStrings.tourTitleLabel),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: viewModel.startMileageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${AppStrings.tourStartMileage} ($unitLabel)',
                        suffixIcon: IconButton(
                          onPressed: () => viewModel.scanToController(
                            controller: viewModel.startMileageController,
                            allowDecimal: false,
                            pickImagePath: () async {
                              final picker = ImagePicker();
                              final photo =
                                  await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                              return photo?.path;
                            },
                            confirmText: (detectedText) async {
                              if (!context.mounted) {
                                return null;
                              }
                              final textController = TextEditingController(text: detectedText);
                              final confirmed = await showDialog<String?>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(AppStrings.confirmMileageTitle),
                                    content: TextField(
                                      controller: textController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        labelText: '${AppStrings.tourStartMileage} ($unitLabel)',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(null),
                                        child: const Text(AppStrings.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(textController.text.trim()),
                                        child: const Text(AppStrings.save),
                                      ),
                                    ],
                                  );
                                },
                              );
                              textController.dispose();
                              return confirmed;
                            },
                          ),
                          icon: const Icon(Icons.camera_alt),
                          tooltip: AppStrings.scanMileageTooltip,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: viewModel.endMileageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${AppStrings.tourEndMileage} ($unitLabel)',
                        suffixIcon: IconButton(
                          onPressed: () => viewModel.scanToController(
                            controller: viewModel.endMileageController,
                            allowDecimal: false,
                            pickImagePath: () async {
                              final picker = ImagePicker();
                              final photo =
                                  await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                              return photo?.path;
                            },
                            confirmText: (detectedText) async {
                              if (!context.mounted) {
                                return null;
                              }
                              final textController = TextEditingController(text: detectedText);
                              final confirmed = await showDialog<String?>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(AppStrings.confirmMileageTitle),
                                    content: TextField(
                                      controller: textController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        labelText: '${AppStrings.tourEndMileage} ($unitLabel)',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(null),
                                        child: const Text(AppStrings.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(textController.text.trim()),
                                        child: const Text(AppStrings.save),
                                      ),
                                    ],
                                  );
                                },
                              );
                              textController.dispose();
                              return confirmed;
                            },
                          ),
                          icon: const Icon(Icons.camera_alt),
                          tooltip: AppStrings.scanMileageTooltip,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      distance == null
                          ? '📏 ${AppStrings.tourDistancePlaceholder}'
                          : '📏 ${AppStrings.tourDistanceLabel} $distance $unitLabel',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '⛽ ${AppStrings.tourFuelStopsTitle}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: viewModel.fuelAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: AppStrings.tourFuelAmount,
                        suffixIcon: IconButton(
                          onPressed: () => viewModel.scanToController(
                            controller: viewModel.fuelAmountController,
                            allowDecimal: true,
                            pickImagePath: () async {
                              final picker = ImagePicker();
                              final photo =
                                  await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                              return photo?.path;
                            },
                            confirmText: (detectedText) async {
                              if (!context.mounted) {
                                return null;
                              }
                              final textController = TextEditingController(text: detectedText);
                              final confirmed = await showDialog<String?>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(AppStrings.tourFuelAmount),
                                    content: TextField(
                                      controller: textController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(labelText: AppStrings.tourFuelAmount),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(null),
                                        child: const Text(AppStrings.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(textController.text.trim()),
                                        child: const Text(AppStrings.save),
                                      ),
                                    ],
                                  );
                                },
                              );
                              textController.dispose();
                              return confirmed;
                            },
                          ),
                          icon: const Icon(Icons.camera_alt),
                          tooltip: AppStrings.scanValueTooltip,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: viewModel.fuelLitersController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: AppStrings.tourFuelLiters,
                        suffixIcon: IconButton(
                          onPressed: () => viewModel.scanToController(
                            controller: viewModel.fuelLitersController,
                            allowDecimal: true,
                            pickImagePath: () async {
                              final picker = ImagePicker();
                              final photo =
                                  await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                              return photo?.path;
                            },
                            confirmText: (detectedText) async {
                              if (!context.mounted) {
                                return null;
                              }
                              final textController = TextEditingController(text: detectedText);
                              final confirmed = await showDialog<String?>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(AppStrings.tourFuelLiters),
                                    content: TextField(
                                      controller: textController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(labelText: AppStrings.tourFuelLiters),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(null),
                                        child: const Text(AppStrings.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(textController.text.trim()),
                                        child: const Text(AppStrings.save),
                                      ),
                                    ],
                                  );
                                },
                              );
                              textController.dispose();
                              return confirmed;
                            },
                          ),
                          icon: const Icon(Icons.camera_alt),
                          tooltip: AppStrings.scanValueTooltip,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: viewModel.isAddingStop
                            ? null
                            : () async {
                                final error = await viewModel.addFuelStop();
                                if (error != null) {
                                  _showSnack(error);
                                }
                              },
                        child: viewModel.isAddingStop
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('➕ ${AppStrings.tourAddFuelStop}'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (viewModel.stops.isEmpty)
                      Text(
                        '🙈 ${AppStrings.tourNoStops}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      )
                    else
                      ...viewModel.stops.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stop = entry.value;
                        final location = stop.location ?? AppStrings.tourLocationUnknown;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '⛽ Stop ${index + 1} • '
                            '🪣 ${stop.liters.toStringAsFixed(2)} L',
                          ),
                          subtitle: Text('💸 PKR ${stop.amountPkr.toStringAsFixed(0)} • 📍 $location'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => viewModel.removeStop(index),
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    Text(
                      '📊 ${AppStrings.tourSummaryHeader}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🧭 ${AppStrings.tourSummaryMileage} '
                      '${distance ?? AppStrings.placeholder} $unitLabel',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⛽ ${AppStrings.tourSummaryAverage} $average $unitLabel/L',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '🪣 ${AppStrings.tourSummaryFuel} $totalLiters L',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '💸 ${AppStrings.tourSummarySpend} PKR $totalSpend',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isSaving
                            ? null
                            : () async {
                                final error = await viewModel.completeTour(currentUnit);
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
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(AppStrings.tourComplete),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '🗂️ ${AppStrings.tourListTitle}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (viewModel.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.tourLoading,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    else if (viewModel.lastError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(viewModel.lastError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ),
                    if (viewModel.tours.isEmpty)
                      Text(
                        AppStrings.tourListEmpty,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      )
                    else
                      ...viewModel.tours.map((tour) {
                        final localizations = MaterialLocalizations.of(context);
                        final dateText = localizations.formatFullDate(tour.createdAt);
                        final timeText = localizations.formatTimeOfDay(TimeOfDay.fromDateTime(tour.createdAt));
                        final convertedDistance =
                            viewModel.convertDistance(tour.distanceKm.toDouble(), tour.unit, currentUnit);
                        final convertedAverage = viewModel.convertDistance(
                          tour.totalLiters > 0 ? tour.distanceKm / tour.totalLiters : 0,
                          tour.unit,
                          currentUnit,
                        );
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: surfaceColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
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
                            trailing: viewModel.deletingTourId == tour.id
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: AppStrings.tourDelete,
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(AppStrings.tourDeleteTitle),
                                            content: const Text(AppStrings.tourDeleteBody),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text(AppStrings.cancel),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text(AppStrings.tourDelete),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (confirmed == true) {
                                        final error = await viewModel.deleteTour(tour.id);
                                        if (error != null) {
                                          _showSnack(error);
                                        }
                                      }
                                    },
                                  ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) =>
                                      TourDetailScreen(tour: tour, unitLabel: unitLabel, currentUnit: currentUnit),
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

}
