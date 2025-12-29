import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/enums.dart';
import '../services/ocr_service.dart';
import '../viewmodels/oil_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _currentController = TextEditingController();
  final _intervalController = TextEditingController();
  final _lastChangeController = TextEditingController();
  bool _controllersInitialized = false;
  final _ocrService = OcrService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OilViewModel>().load();
    });
  }

  @override
  void dispose() {
    _currentController.dispose();
    _intervalController.dispose();
    _lastChangeController.dispose();
    super.dispose();
  }

  Future<void> _save(OilViewModel viewModel) async {
    final current = int.tryParse(_currentController.text.trim());
    final interval = int.tryParse(_intervalController.text.trim());
    final lastChange = int.tryParse(_lastChangeController.text.trim());

    if (current != null) {
      await viewModel.updateCurrentMileage(current);
    }
    if (interval != null) {
      await viewModel.updateIntervalKm(interval);
    }
    if (lastChange != null) {
      await viewModel.updateLastChangeMileage(lastChange);
    }

    if (!mounted) {
      return;
    }

    if (viewModel.lastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.lastError!)),
      );
    }

    FocusScope.of(context).unfocus();
  }

  Future<void> _markOilChanged(OilViewModel viewModel) async {
    await viewModel.markOilChanged();
    final current = int.tryParse(_currentController.text.trim()) ??
        viewModel.currentMileage;
    if (current != null) {
      _lastChangeController.text = current.toString();
    }
  }

  void _openSettings(OilViewModel viewModel) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer<OilViewModel>(
          builder: (context, sheetViewModel, child) {
            return Padding(
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                  const Text(
                    AppStrings.settingsTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.unitsTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  RadioListTile<OilUnit>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.kilometers),
                    value: OilUnit.kilometers,
                    groupValue: sheetViewModel.unit,
                        onChanged: (value) {
                          if (value != null) {
                            sheetViewModel.updateUnit(value);
                          }
                        },
                      ),
                  RadioListTile<OilUnit>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.miles),
                    value: OilUnit.miles,
                    groupValue: sheetViewModel.unit,
                        onChanged: (value) {
                          if (value != null) {
                            sheetViewModel.updateUnit(value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                  const Text(
                    AppStrings.themeTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.notificationsTitle),
                    value: sheetViewModel.notificationsEnabled,
                    onChanged: (value) {
                      sheetViewModel.updateNotificationsEnabled(value);
                    },
                  ),
                  RadioListTile<AppThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.light),
                    value: AppThemeMode.light,
                    groupValue: sheetViewModel.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            sheetViewModel.updateThemeMode(value);
                          }
                        },
                      ),
                  RadioListTile<AppThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.dark),
                    value: AppThemeMode.dark,
                    groupValue: sheetViewModel.themeMode,
                        onChanged: (value) {
                          if (value != null) {
                            sheetViewModel.updateThemeMode(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmReset(OilViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed != true) {
      return;
    }

    await viewModel.resetAll();
    _currentController.clear();
    _intervalController.clear();
    _lastChangeController.clear();
    _controllersInitialized = false;
  }

  Future<void> _captureMileage(OilViewModel viewModel) async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo == null) {
      return;
    }

    final detected = await _ocrService.readMileage(photo.path);
    if (!mounted) {
      return;
    }

    final controller = TextEditingController(
      text: detected?.toString() ?? '',
    );
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

    if (confirmed == null) {
      return;
    }

    _currentController.text = confirmed.toString();
    await viewModel.updateCurrentMileage(confirmed);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OilViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isInitialized && !_controllersInitialized) {
          _currentController.text =
              viewModel.currentMileage?.toString() ?? '';
          _intervalController.text = viewModel.intervalKm?.toString() ?? '';
          _lastChangeController.text =
              viewModel.lastChangeMileage?.toString() ?? '';
          _controllersInitialized = true;
        }

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
        return Scaffold(
          backgroundColor: const Color(AppColors.transparent),
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
                                      IconButton(
                                        onPressed: () =>
                                            _confirmReset(viewModel),
                                        icon: const Icon(Icons.refresh),
                                        tooltip: AppStrings.resetTooltip,
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _openSettings(viewModel),
                                        icon: const Icon(
                                          Icons.settings_outlined,
                                        ),
                                        tooltip: AppStrings.settingsTooltip,
                                      ),
                                      _StatusPill(
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
                                        _MileageField(
                                          controller: _currentController,
                                          label:
                                              '${AppStrings.currentMileageLabel} (${viewModel.unitLabel})',
                                          suffixIcon: IconButton(
                                            onPressed: () =>
                                                _captureMileage(viewModel),
                                            icon: const Icon(
                                              Icons.camera_alt,
                                            ),
                                            tooltip:
                                                AppStrings.scanMileageTooltip,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _MileageField(
                                          controller: _lastChangeController,
                                          label:
                                              '${AppStrings.lastChangeLabel} (${viewModel.unitLabel})',
                                        ),
                                        const SizedBox(height: 16),
                                        _MileageField(
                                          controller: _intervalController,
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
                                                ? () => _save(viewModel)
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
                                              : () => _markOilChanged(viewModel),
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
                                        _MetricRow(
                                          title: AppStrings.metricsLastChange,
                                          value:
                                              viewModel.lastChangeMileage ==
                                                      null
                                                  ? AppStrings.placeholder
                                                  : '${viewModel.lastChangeMileage} ${viewModel.unitLabel}',
                                        ),
                                        const SizedBox(height: 12),
                                        _MetricRow(
                                          title: AppStrings.metricsNextDue,
                                          value: viewModel.nextDueMileage == null
                                              ? AppStrings.placeholder
                                              : '${viewModel.nextDueMileage} ${viewModel.unitLabel}',
                                        ),
                                        const SizedBox(height: 12),
                                        _MetricRow(
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
                const Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: CircularProgressIndicator(),
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

class _MileageField extends StatelessWidget {
  const _MileageField({
    required this.controller,
    required this.label,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark
            ? const Color(AppColors.darkField)
            : const Color(AppColors.lightField),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.title,
    required this.value,
    this.highlight = false,
  });

  final String title;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final valueColor = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: subtitleColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                highlight ? const Color(AppColors.danger) : valueColor,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatefulWidget {
  const _StatusPill({
    required this.isDue,
    required this.isWarning,
  });

  final bool isDue;
  final bool isWarning;

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _updateAnimation();
  }

  @override
  void didUpdateWidget(covariant _StatusPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDue != widget.isDue ||
        oldWidget.isWarning != widget.isWarning) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.isDue || widget.isWarning) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.isDue
        ? const Color(AppColors.pillDueBackground)
        : widget.isWarning
            ? const Color(AppColors.pillWarningBackground)
            : const Color(AppColors.pillOkBackground);
    final foreground = widget.isDue
        ? const Color(AppColors.danger)
        : widget.isWarning
            ? const Color(AppColors.warning)
            : const Color(AppColors.success);
    final label = widget.isDue
        ? AppStrings.statusDue
        : widget.isWarning
            ? AppStrings.statusSoon
            : AppStrings.statusOk;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final scale = 1.0 + (0.1 * t);
        final opacity = 1.0 - (0.12 * t);
        final baseColor = background;
        final flickerStrength = widget.isDue || widget.isWarning ? 0.25 : 0.0;
        final flickerColor = Color.lerp(
          baseColor,
          const Color(AppColors.textOnPrimary),
          flickerStrength * t,
        );
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: flickerColor ?? background,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
