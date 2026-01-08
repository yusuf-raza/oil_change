import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../viewmodels/oil_change_view_model.dart';
import '../../viewmodels/oil_view_model.dart';
import '../../services/offline_sync_service.dart';
import '../home/widgets/home_drawer.dart';
import '../home/widgets/status_pill.dart';

class OilChangeScreen extends StatefulWidget {
  const OilChangeScreen({super.key});

  @override
  State<OilChangeScreen> createState() => _OilChangeScreenState();
}

class _OilChangeScreenState extends State<OilChangeScreen> {
  late final OilChangeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OilChangeViewModel(oilViewModel: context.read<OilViewModel>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.ensureLoaded();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _buildSyncStatus(
    BuildContext context,
    OfflineSyncService syncService,
  ) {
    if (syncService.isSyncing) {
      return AppStrings.syncing;
    }
    if (syncService.lastError != null) {
      return '${AppStrings.syncFailed} ${syncService.lastError}';
    }
    final lastSyncAt = syncService.lastSyncAt;
    if (lastSyncAt == null) {
      return AppStrings.syncNever;
    }
    final localizations = MaterialLocalizations.of(context);
    final dateText = localizations.formatShortDate(lastSyncAt);
    final timeText = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(lastSyncAt),
    );
    return '${AppStrings.syncStatusLabel} $dateText • $timeText';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OilViewModel>(
      builder: (context, _, child) {
        if (_viewModel.needsControllerSync) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _viewModel.syncControllers();
          });
        }
        final syncService = context.watch<OfflineSyncService>();

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundGradient = LinearGradient(
          colors: isDark
              ? const [Color(AppColors.darkBackgroundStart), Color(AppColors.darkBackgroundEnd)]
              : const [Color(AppColors.lightBackgroundStart), Color(AppColors.lightBackgroundEnd)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

        return Scaffold(
          backgroundColor: const Color(AppColors.transparent),
          drawer: HomeDrawer(
            viewModel: _viewModel.oilState,
            authService: _viewModel.authService,
            isSyncing: syncService.isSyncing,
            syncStatusText: _buildSyncStatus(context, syncService),
            onSync: () async {
              Navigator.of(context).pop();
              await syncService.syncAll();
              if (!mounted) {
                return;
              }
              final error = syncService.lastError;
              _showSnack(
                error == null
                    ? AppStrings.syncComplete
                    : '${AppStrings.syncFailed} $error',
              );
            },
            onSignOut: () async {
              if (!mounted) {
                return;
              }
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const Center(child: CircularProgressIndicator());
                },
              );
              final error = await _viewModel.signOut();
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              if (error != null) {
                _showSnack('Sign out failed: $error');
              }
            },
          ),
          body: Container(
            decoration: BoxDecoration(gradient: backgroundGradient),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18, 16, 18, 28 + MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '🛢️ ${AppStrings.headline}',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                            Row(
                              children: [
                                Builder(
                                  builder: (context) => IconButton(
                                    onPressed: () => Scaffold.of(context).openDrawer(),
                                    icon: const Icon(Icons.menu),
                                    tooltip: 'Menu',
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final error = await _viewModel.confirmReset(
                                      confirm: () {
                                        return showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(AppStrings.resetTitle),
                                              content: const Text(AppStrings.resetBody),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text(AppStrings.cancel),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text(AppStrings.reset),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                    if (error != null) {
                                      _showSnack(error);
                                    }
                                  },
                                  icon: const Icon(Icons.refresh),
                                  tooltip: AppStrings.resetTooltip,
                                ),
                                if (_viewModel.showStatus)
                                  StatusPill(isDue: _viewModel.isDue, isWarning: _viewModel.isWarning),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.subtitle,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        if (_viewModel.isLoading) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.tourLoading,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          '🧮 ${AppStrings.yourMileageTitle}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _viewModel.currentController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '${AppStrings.currentMileageLabel} (${_viewModel.unitLabel})',
                            suffixIcon: IconButton(
                              onPressed: () async {
                                await _viewModel.captureMileage(
                                  pickImagePath: () async {
                                    final picker = ImagePicker();
                                    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                                    return photo?.path;
                                  },
                                  confirmMileage: (detected) async {
                                    if (!mounted) {
                                      return null;
                                    }

                                    final controller = TextEditingController(text: detected?.toString() ?? '');
                                    final confirmed = await showDialog<int>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(AppStrings.confirmMileageTitle),
                                          content: TextField(
                                            controller: controller,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: AppStrings.confirmMileageLabel,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text(AppStrings.cancel),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                final value = int.tryParse(controller.text.trim());
                                                Navigator.of(context).pop(value);
                                              },
                                              child: const Text(AppStrings.save),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    controller.dispose();
                                    return confirmed;
                                  },
                                );
                              },
                              icon: const Icon(Icons.camera_alt),
                              tooltip: AppStrings.scanMileageTooltip,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _viewModel.lastChangeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '${AppStrings.lastChangeLabel} (${_viewModel.unitLabel})',
                            suffixIcon: IconButton(
                              onPressed: () async {
                                await _viewModel.captureMileage(
                                  pickImagePath: () async {
                                    final picker = ImagePicker();
                                    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
                                    return photo?.path;
                                  },
                                  confirmMileage: (detected) async {
                                    if (!mounted) {
                                      return null;
                                    }

                                    final controller = TextEditingController(text: detected?.toString() ?? '');
                                    final confirmed = await showDialog<int>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(AppStrings.confirmMileageTitle),
                                          content: TextField(
                                            controller: controller,
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              labelText: AppStrings.confirmLastChangeLabel,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text(AppStrings.cancel),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                final value = int.tryParse(controller.text.trim());
                                                Navigator.of(context).pop(value);
                                              },
                                              child: const Text(AppStrings.save),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    controller.dispose();
                                    return confirmed;
                                  },
                                );
                              },
                              icon: const Icon(Icons.camera_alt),
                              tooltip: AppStrings.scanMileageTooltip,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _viewModel.intervalController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: '${AppStrings.intervalLabel} (${_viewModel.unitLabel})',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ValueListenableBuilder<bool>(
                              valueListenable: _viewModel.isMarkingOilChanged,
                              builder: (context, isMarking, child) {
                                return OutlinedButton.icon(
                                  onPressed: _viewModel.canMarkOilChanged && !isMarking
                                      ? () async {
                                          await _viewModel.runMarkOilChanged();
                                        }
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: Icon(
                                    isMarking ? Icons.timelapse : Icons.check_circle_outline,
                                  ),
                                  label: Text(
                                    isMarking
                                        ? AppStrings.oilChangedSaving
                                        : AppStrings.oilChanged,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _viewModel.isSavingForm,
                            builder: (context, isSaving, child) {
                              return ElevatedButton(
                                onPressed: _viewModel.canSave && !isSaving
                                    ? () async {
                                        final error = await _viewModel.runSave();
                                        if (error != null) {
                                          _showSnack(error);
                                        }
                                        FocusScope.of(context).unfocus();
                                      }
                                    : null,
                                child: isSaving
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(AppStrings.save),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '📊 ${AppStrings.tourSummaryHeader}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🛢️ ${AppStrings.metricsLastChange} '
                          '${_viewModel.lastChangeSummary}',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '⏭️ ${AppStrings.metricsNextDue} '
                          '${_viewModel.nextDueSummary}',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '⛽ ${AppStrings.metricsRemaining} '
                          '${_viewModel.remainingSummary}',
                          style: TextStyle(
                            color: _viewModel.isDue
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_viewModel.statusMessage != null)
                          Text(
                            _viewModel.statusMessage!,
                            style: TextStyle(
                              color: _viewModel.isDue
                                  ? Theme.of(context).colorScheme.error
                                  : const Color(AppColors.warning),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          );
      },
    );
  }
}
