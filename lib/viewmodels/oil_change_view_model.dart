import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../constants/app_strings.dart';
import '../services/app_logger.dart';
import '../services/auth_service.dart';
import '../services/ocr_service.dart';
import 'oil_view_model.dart';

class OilChangeViewModel {
  OilChangeViewModel({
    required this.oilViewModel,
    AuthService? authService,
    OcrService? ocrService,
    Logger? logger,
  })  : _authService = authService ??
            AuthService(FirebaseAuth.instance, GoogleSignIn()),
        _ocrService = ocrService ?? OcrService(),
        _logger = logger ?? AppLogger.logger;

  final OilViewModel oilViewModel;
  final AuthService _authService;
  final OcrService _ocrService;
  final Logger _logger;

  final TextEditingController currentController = TextEditingController();
  final TextEditingController intervalController = TextEditingController();
  final TextEditingController lastChangeController = TextEditingController();
  bool _controllersInitialized = false;
  final ValueNotifier<bool> isSavingForm = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isMarkingOilChanged = ValueNotifier<bool>(false);

  AuthService get authService => _authService;
  OilViewModel get oilState => oilViewModel;

  bool get isDue => oilViewModel.isDue;
  bool get isWarning =>
      oilViewModel.remainingKm != null &&
      oilViewModel.remainingKm! > 0 &&
      oilViewModel.remainingKm! <= 150;
  bool get showStatus => isDue || isWarning;
  bool get isLoading => oilViewModel.isLoading;
  bool get isSaving => oilViewModel.isSaving;
  bool get canSave => oilViewModel.isInitialized && !oilViewModel.isSaving;
  bool get canMarkOilChanged => oilViewModel.currentMileage != null;
  String get unitLabel => oilViewModel.unitLabel;

  String get lastChangeSummary =>
      _formatMetric(oilViewModel.lastChangeMileage);
  String get nextDueSummary => _formatMetric(oilViewModel.nextDueMileage);
  String get remainingSummary => _formatMetric(oilViewModel.remainingKm);
  String? get statusMessage {
    if (isDue) {
      return AppStrings.dueMessage;
    }
    if (isWarning) {
      return AppStrings.soonMessage;
    }
    return null;
  }

  Future<void> ensureLoaded() async {
    await oilViewModel.load();
  }

  bool get needsControllerSync =>
      oilViewModel.isInitialized && !_controllersInitialized;

  void syncControllers() {
    if (!needsControllerSync) {
      return;
    }
    currentController.text = oilViewModel.currentMileage?.toString() ?? '';
    intervalController.text = oilViewModel.intervalKm?.toString() ?? '';
    lastChangeController.text =
        oilViewModel.lastChangeMileage?.toString() ?? '';
    _controllersInitialized = true;
  }

  Future<String?> save() async {
    final current = int.tryParse(currentController.text.trim());
    final interval = int.tryParse(intervalController.text.trim());
    final lastChange = int.tryParse(lastChangeController.text.trim());

    if (current != null) {
      await oilViewModel.updateCurrentMileage(current);
    }
    if (interval != null) {
      await oilViewModel.updateIntervalKm(interval);
    }
    if (lastChange != null) {
      await oilViewModel.updateLastChangeMileage(lastChange);
    }
    return oilViewModel.lastError;
  }

  Future<String?> runSave() async {
    if (isSavingForm.value) {
      return null;
    }
    isSavingForm.value = true;
    try {
      return await save();
    } finally {
      isSavingForm.value = false;
    }
  }

  Future<void> markOilChanged() async {
    await oilViewModel.markOilChanged();
    final current = int.tryParse(currentController.text.trim()) ??
        oilViewModel.currentMileage;
    if (current != null) {
      lastChangeController.text = current.toString();
    }
  }

  Future<void> runMarkOilChanged() async {
    if (isMarkingOilChanged.value) {
      return;
    }
    isMarkingOilChanged.value = true;
    try {
      await markOilChanged();
    } finally {
      isMarkingOilChanged.value = false;
    }
  }

  Future<String?> resetAll() async {
    await oilViewModel.resetAll();
    currentController.clear();
    intervalController.clear();
    lastChangeController.clear();
    _controllersInitialized = false;
    return oilViewModel.lastError;
  }

  Future<int?> readMileage(String path) async {
    return _ocrService.readMileage(path);
  }

  Future<String?> confirmReset({
    required Future<bool?> Function() confirm,
  }) async {
    final confirmed = await confirm();
    if (confirmed != true) {
      return null;
    }
    return resetAll();
  }

  Future<bool> captureMileage({
    required Future<String?> Function() pickImagePath,
    required Future<int?> Function(int? detected) confirmMileage,
  }) async {
    final path = await pickImagePath();
    if (path == null) {
      return false;
    }

    final detected = await readMileage(path);
    final confirmed = await confirmMileage(detected);
    if (confirmed == null) {
      return false;
    }

    await applyCapturedMileage(confirmed);
    return true;
  }

  Future<void> applyCapturedMileage(int value) async {
    currentController.text = value.toString();
    await oilViewModel.updateCurrentMileage(value);
  }

  Future<String?> signOut() async {
    try {
      await _authService.signOut();
      return null;
    } catch (error) {
      _logger.e('Sign out failed: $error');
      return error.toString();
    }
  }

  void dispose() {
    currentController.dispose();
    intervalController.dispose();
    lastChangeController.dispose();
    isSavingForm.dispose();
    isMarkingOilChanged.dispose();
  }

  String _formatMetric(int? value) {
    if (value == null) {
      return AppStrings.placeholder;
    }
    return '$value $unitLabel';
  }
}
