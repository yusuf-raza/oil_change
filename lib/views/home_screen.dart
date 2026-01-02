import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/oil_view_model.dart';
import '../widgets/home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();
    _homeViewModel = HomeViewModel(
      oilViewModel: context.read<OilViewModel>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeViewModel.ensureLoaded();
    });
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OilViewModel>(
      builder: (context, viewModel, child) {
        _homeViewModel.syncFromState();

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark
            ? const Color(AppColors.darkSurface)
            : const Color(AppColors.lightSurface);
        final overlayColor = isDark
            ? const Color(0x66000000)
            : const Color(0x33000000);
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
        return Scaffold(
          backgroundColor: const Color(AppColors.transparent),
          drawer: HomeDrawer(
            viewModel: viewModel,
            authService: _homeViewModel.authService,
            onSignOut: () async {
              if (!mounted) {
                return;
              }
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
              final error = await _homeViewModel.signOut();
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              if (error != null) {
                _showSnack('Sign out failed: $error');
              }
            },
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: backgroundGradient,
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        AppStrings.headline,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                  Row(
                                    children: [
                                      Builder(
                                        builder: (context) => IconButton(
                                          onPressed: () =>
                                              Scaffold.of(context).openDrawer(),
                                          icon: const Icon(Icons.menu),
                                          tooltip: 'Menu',
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          final error =
                                              await _homeViewModel.confirmReset(
                                            confirm: () {
                                              return showDialog<bool>(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                      AppStrings.resetTitle,
                                                    ),
                                                    content: const Text(
                                                      AppStrings.resetBody,
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                        child: const Text(
                                                          AppStrings.cancel,
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                        child: const Text(
                                                          AppStrings.reset,
                                                        ),
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
                                      StatusPill(
                                        isDue: viewModel.isDue,
                                        isWarning: viewModel.remainingKm !=
                                                null &&
                                            viewModel.remainingKm! > 0 &&
                                            viewModel.remainingKm! <= 150,
                                      ),
                                    ],
                                  ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppStrings.subtitle,
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(AppColors.darkSubtitle)
                                          : const Color(
                                              AppColors.lightSubtitle,
                                            ),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: surfaceColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? const Color(
                                                  AppColors.shadowDark,
                                                )
                                              : const Color(
                                                  AppColors.shadowLight,
                                                ),
                                          blurRadius: 22,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          AppStrings.yourMileageTitle,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        MileageField(
                                          controller:
                                              _homeViewModel.currentController,
                                          label:
                                              '${AppStrings.currentMileageLabel} (${viewModel.unitLabel})',
                                          suffixIcon: IconButton(
                                            onPressed: () async {
                                              await _homeViewModel
                                                  .captureMileage(
                                                pickImagePath: () async {
                                                  final picker = ImagePicker();
                                                  final photo =
                                                      await picker.pickImage(
                                                    source: ImageSource.camera,
                                                    imageQuality: 85,
                                                  );
                                                  return photo?.path;
                                                },
                                                confirmMileage:
                                                    (detected) async {
                                                  if (!mounted) {
                                                    return null;
                                                  }

                                                  final controller =
                                                      TextEditingController(
                                                    text:
                                                        detected?.toString() ??
                                                            '',
                                                  );
                                                  final confirmed =
                                                      await showDialog<int>(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                          AppStrings
                                                              .confirmMileageTitle,
                                                        ),
                                                        content: TextField(
                                                          controller:
                                                              controller,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              const InputDecoration(
                                                            labelText: AppStrings
                                                                .confirmMileageLabel,
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                              context,
                                                            ).pop(),
                                                            child: const Text(
                                                              AppStrings
                                                                  .cancel,
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              final value =
                                                                  int.tryParse(
                                                                controller.text
                                                                    .trim(),
                                                              );
                                                              Navigator.of(
                                                                context,
                                                              ).pop(value);
                                                            },
                                                            child: const Text(
                                                              AppStrings.save,
                                                            ),
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
                                            icon: const Icon(
                                              Icons.camera_alt,
                                            ),
                                            tooltip:
                                                AppStrings.scanMileageTooltip,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        MileageField(
                                          controller:
                                              _homeViewModel.lastChangeController,
                                          label:
                                              '${AppStrings.lastChangeLabel} (${viewModel.unitLabel})',
                                        ),
                                        const SizedBox(height: 16),
                                        MileageField(
                                          controller:
                                              _homeViewModel.intervalController,
                                          label:
                                              '${AppStrings.intervalLabel} (${viewModel.unitLabel})',
                                        ),
                                        const SizedBox(height: 18),
                                        Row(
                                          children: [
                                            Expanded(
                                          child: ElevatedButton(
                                            onPressed: viewModel
                                                        .isInitialized
                                                    && !viewModel.isSaving
                                                ? () async {
                                                    final error =
                                                        await _homeViewModel
                                                            .save();
                                                    if (error != null) {
                                                      _showSnack(error);
                                                    }
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(
                                                        AppColors.seed,
                                                      ),
                                                  foregroundColor: const Color(
                                                    AppColors.textOnPrimary,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 14,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      12,
                                                    ),
                                                  ),
                                                ),
                                            child: viewModel.isSaving
                                                ? const SizedBox(
                                                    height: 18,
                                                    width: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Color(
                                                        AppColors.textOnPrimary,
                                                      ),
                                                    ),
                                                  )
                                                : const Text(AppStrings.save),
                                          ),
                                        ),
                                            const SizedBox(width: 12),
                                            OutlinedButton(
                                          onPressed: viewModel
                                                      .currentMileage ==
                                                  null
                                              ? null
                                              : () async {
                                                  await _homeViewModel
                                                      .markOilChanged();
                                                },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(
                                                  AppColors.seed,
                                                ),
                                                side: const BorderSide(
                                                  color: Color(AppColors.seed),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 14,
                                                  horizontal: 18,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: const Text(
                                                AppStrings.oilChanged,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        MetricRow(
                                          title: AppStrings.metricsLastChange,
                                          value:
                                              viewModel.lastChangeMileage ==
                                                      null
                                                  ? AppStrings.placeholder
                                                  : '${viewModel.lastChangeMileage} ${viewModel.unitLabel}',
                                        ),
                                        const SizedBox(height: 12),
                                        MetricRow(
                                          title: AppStrings.metricsNextDue,
                                          value: viewModel.nextDueMileage == null
                                              ? AppStrings.placeholder
                                              : '${viewModel.nextDueMileage} ${viewModel.unitLabel}',
                                        ),
                                        const SizedBox(height: 12),
                                        MetricRow(
                                          title: AppStrings.metricsRemaining,
                                          value: viewModel.remainingKm == null
                                              ? AppStrings.placeholder
                                              : '${viewModel.remainingKm} ${viewModel.unitLabel}',
                                          highlight: viewModel.isDue,
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          viewModel.isDue
                                              ? AppStrings.dueMessage
                                              : AppStrings.okMessage,
                                          style: TextStyle(
                                            color: viewModel.isDue
                                                ? const Color(AppColors.danger)
                                                : const Color(
                                                    AppColors.success,
                                                  ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (viewModel.isLoading)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          color: overlayColor,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
