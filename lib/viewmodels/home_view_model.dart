import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../services/app_logger.dart';
import '../services/auth_service.dart';
import '../services/ocr_service.dart';
import 'oil_view_model.dart';

class HomeViewModel {
  HomeViewModel({
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

  AuthService get authService => _authService;

  Future<void> ensureLoaded() async {
    await oilViewModel.load();
  }

  void syncFromState() {
    if (oilViewModel.isInitialized && !_controllersInitialized) {
      currentController.text = oilViewModel.currentMileage?.toString() ?? '';
      intervalController.text = oilViewModel.intervalKm?.toString() ?? '';
      lastChangeController.text =
          oilViewModel.lastChangeMileage?.toString() ?? '';
      _controllersInitialized = true;
    }
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

  Future<void> markOilChanged() async {
    await oilViewModel.markOilChanged();
    final current = int.tryParse(currentController.text.trim()) ??
        oilViewModel.currentMileage;
    if (current != null) {
      lastChangeController.text = current.toString();
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
  }
}
