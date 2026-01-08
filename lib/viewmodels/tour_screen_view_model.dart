import 'package:flutter/material.dart';

import '../services/ocr_service.dart';

class TourScreenViewModel {
  TourScreenViewModel({OcrService? ocrService})
      : _ocrService = ocrService ?? OcrService();

  final OcrService _ocrService;

  Future<void> scanToController({
    required TextEditingController controller,
    required bool allowDecimal,
    required Future<String?> Function() pickImagePath,
    required Future<String?> Function(String? detected) confirmValue,
  }) async {
    final path = await pickImagePath();
    if (path == null) {
      return;
    }

    final detected = await _ocrService.readNumeric(
      path,
      allowDecimal: allowDecimal,
    );
    final detectedText = detected == null
        ? null
        : _formatDetected(detected, allowDecimal);
    final confirmed = await confirmValue(detectedText);
    if (confirmed == null || confirmed.isEmpty) {
      return;
    }
    controller.text = confirmed;
  }

  String _formatDetected(double value, bool allowDecimal) {
    if (!allowDecimal) {
      return value.toStringAsFixed(0);
    }
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}
