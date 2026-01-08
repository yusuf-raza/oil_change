import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_strings.dart';
import '../data/local/local_tour_draft_repository.dart';
import '../models/enums.dart';
import '../models/fuel_stop.dart';
import '../models/tour_entry.dart';
import '../services/location_service.dart';
import '../services/ocr_service.dart';
import '../services/tour_repository.dart';

class TourSummary {
  const TourSummary({
    required this.distanceKm,
    required this.totalLiters,
    required this.totalSpendPkr,
  });

  final int distanceKm;
  final double totalLiters;
  final double totalSpendPkr;

  double? get averageKmPerLiter {
    if (totalLiters <= 0) {
      return null;
    }
    return distanceKm / totalLiters;
  }
}

class TourViewModel extends ChangeNotifier {
  TourViewModel({
    LocationServiceBase? locationService,
    TourRepositoryBase? repository,
    OcrService? ocrService,
    LocalTourDraftRepository? draftRepository,
  })  : _locationService = locationService ?? LocationService(),
        _repository = repository ??
            TourRepository(FirebaseFirestore.instance, FirebaseAuth.instance),
        _ocrService = ocrService ?? OcrService(),
        _draftRepository = draftRepository {
    startMileageController.addListener(_onMileageChanged);
    endMileageController.addListener(_onMileageChanged);
    titleController.addListener(_onDraftChanged);
    startMileageController.addListener(_onDraftChanged);
    endMileageController.addListener(_onDraftChanged);
    fuelAmountController.addListener(_onDraftChanged);
    fuelLitersController.addListener(_onDraftChanged);
  }

  final LocationServiceBase _locationService;
  final TourRepositoryBase _repository;
  final OcrService _ocrService;
  final LocalTourDraftRepository? _draftRepository;
  final TextEditingController startMileageController =
      TextEditingController();
  final TextEditingController endMileageController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController fuelAmountController = TextEditingController();
  final TextEditingController fuelLitersController = TextEditingController();

  final List<FuelStop> _stops = [];
  final List<TourEntry> _tours = [];
  bool _isSaving = false;
  bool _isLoading = false;
  bool _isAddingStop = false;
  String? _deletingTourId;
  String? _lastError;
  bool _isDisposed = false;
  bool _isRestoringDraft = false;
  Timer? _draftSaveTimer;

  List<FuelStop> get stops => List.unmodifiable(_stops);
  List<TourEntry> get tours => List.unmodifiable(_tours);
  bool get isSaving => _isSaving;
  bool get isLoading => _isLoading;
  bool get isAddingStop => _isAddingStop;
  String? get deletingTourId => _deletingTourId;
  String? get lastError => _lastError;

  int? get distanceKm {
    final start = _parseInt(startMileageController.text);
    final end = _parseInt(endMileageController.text);
    if (start == null || end == null) {
      return null;
    }
    final distance = end - start;
    return distance >= 0 ? distance : null;
  }

  double get totalLiters =>
      _stops.fold(0, (sum, stop) => sum + stop.liters);

  double get totalSpendPkr =>
      _stops.fold(0, (sum, stop) => sum + stop.amountPkr);

  Future<String?> addFuelStop() async {
    if (_isAddingStop) {
      return null;
    }
    final amount = _parseDouble(fuelAmountController.text);
    final liters = _parseDouble(fuelLitersController.text);
    if (amount == null || liters == null) {
      return AppStrings.tourFuelStopError;
    }
    if (amount <= 0 || liters <= 0) {
      return AppStrings.tourFuelStopPositiveError;
    }
    _isAddingStop = true;
    _notifyListeners();
    final timestamp = DateTime.now();
    _stops.add(
      FuelStop(
        amountPkr: amount,
        liters: liters,
        timestamp: timestamp,
      ),
    );
    fuelAmountController.clear();
    fuelLitersController.clear();
    _isAddingStop = false;
    _notifyListeners();
    _updateStopLocation(_stops.length - 1, timestamp);
    _onDraftChanged();
    return null;
  }

  Future<void> _updateStopLocation(int index, DateTime timestamp) async {
    LocationPoint? locationPoint;
    try {
      locationPoint = await _locationService.getLocationPoint();
    } catch (_) {
      locationPoint = null;
    }
    if (_isDisposed || locationPoint == null) {
      return;
    }
    if (index < 0 || index >= _stops.length) {
      return;
    }
    final current = _stops[index];
    if (current.timestamp != timestamp) {
      return;
    }
    _stops[index] = FuelStop(
      amountPkr: current.amountPkr,
      liters: current.liters,
      location: locationPoint.label,
      timestamp: current.timestamp,
      latitude: locationPoint.latitude,
      longitude: locationPoint.longitude,
    );
    _notifyListeners();
    _onDraftChanged();
  }

  Future<void> scanToController({
    required TextEditingController controller,
    required bool allowDecimal,
    required Future<String?> Function() pickImagePath,
    required Future<String?> Function(String detectedText) confirmText,
  }) async {
    final path = await pickImagePath();
    if (path == null) {
      return;
    }

    final detected =
        await _ocrService.readNumeric(path, allowDecimal: allowDecimal);
    final detectedText =
        detected == null ? '' : _formatDetected(detected, allowDecimal);
    final confirmed = await confirmText(detectedText);
    if (confirmed == null || confirmed.trim().isEmpty) {
      return;
    }
    controller.text = confirmed.trim();
  }

  double convertDistance(double value, String fromUnit, OilUnit toUnit) {
    final from =
        fromUnit == OilUnit.miles.name ? OilUnit.miles : OilUnit.kilometers;
    if (from == toUnit) {
      return value;
    }
    const factor = 0.621371;
    return toUnit == OilUnit.miles ? value * factor : value / factor;
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

  void removeStop(int index) {
    if (index < 0 || index >= _stops.length) {
      return;
    }
    _stops.removeAt(index);
    notifyListeners();
    _onDraftChanged();
  }

  TourSummary? buildSummary() {
    final distance = distanceKm;
    if (distance == null) {
      return null;
    }
    return TourSummary(
      distanceKm: distance,
      totalLiters: totalLiters,
      totalSpendPkr: totalSpendPkr,
    );
  }

  void resetTour() {
    titleController.clear();
    startMileageController.clear();
    endMileageController.clear();
    fuelAmountController.clear();
    fuelLitersController.clear();
    _stops.clear();
    notifyListeners();
  }

  Future<void> loadTours() async {
    _isLoading = true;
    _lastError = null;
    _notifyListeners();
    try {
      await _restoreDraft();
      final entries = await _repository.fetchTours();
      _tours
        ..clear()
        ..addAll(entries);
    } catch (error) {
      _lastError = error.toString();
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  Future<String?> completeTour(OilUnit unit) async {
    final summary = buildSummary();
    if (summary == null) {
      return AppStrings.tourSummaryError;
    }
    _isSaving = true;
    _lastError = null;
    _notifyListeners();
    try {
      final entry = TourEntry(
        id: '',
        createdAt: DateTime.now(),
        title: titleController.text.trim().isEmpty
            ? AppStrings.tourTitle
            : titleController.text.trim(),
        unit: unit.name,
        startMileage: int.tryParse(startMileageController.text.trim()) ?? 0,
        endMileage: int.tryParse(endMileageController.text.trim()) ?? 0,
        distanceKm: summary.distanceKm,
        totalLiters: summary.totalLiters,
        totalSpendPkr: summary.totalSpendPkr,
        stops: List<FuelStop>.from(_stops),
      );
      final saved = await _repository.saveTour(entry);
      _tours.insert(0, saved);
      resetTour();
      await _clearDraft();
      return null;
    } catch (error) {
      _lastError = error.toString();
      return _lastError;
    } finally {
      _isSaving = false;
      _notifyListeners();
    }
  }

  Future<String?> deleteTour(String id) async {
    _lastError = null;
    _deletingTourId = id;
    _notifyListeners();
    try {
      await _repository.deleteTour(id);
      _tours.removeWhere((tour) => tour.id == id);
      _deletingTourId = null;
      _notifyListeners();
      return null;
    } catch (error) {
      _lastError = error.toString();
      _deletingTourId = null;
      _notifyListeners();
      return _lastError;
    }
  }

  int? _parseInt(String raw) {
    final value = int.tryParse(raw.trim());
    return value;
  }

  double? _parseDouble(String raw) {
    final cleaned = raw.trim().replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  void _onMileageChanged() {
    _notifyListeners();
  }

  void _onDraftChanged() {
    if (_draftRepository == null || _isRestoringDraft) {
      return;
    }
    _draftSaveTimer?.cancel();
    _draftSaveTimer = Timer(const Duration(milliseconds: 600), _saveDraft);
  }

  Future<void> _restoreDraft() async {
    if (_draftRepository == null || _isRestoringDraft) {
      return;
    }
    _isRestoringDraft = true;
    try {
      final draft = await _draftRepository!.fetchDraft();
      if (draft == null || draft.isEmpty) {
        return;
      }
      titleController.text = (draft['title'] as String?) ?? '';
      startMileageController.text = (draft['startMileage'] as String?) ?? '';
      endMileageController.text = (draft['endMileage'] as String?) ?? '';
      fuelAmountController.text = (draft['fuelAmount'] as String?) ?? '';
      fuelLitersController.text = (draft['fuelLiters'] as String?) ?? '';
      _stops
        ..clear()
        ..addAll(_readDraftStops(draft['stops']));
      _notifyListeners();
    } finally {
      _isRestoringDraft = false;
    }
  }

  Future<void> _saveDraft() async {
    if (_draftRepository == null || _isDisposed) {
      return;
    }
    final data = <String, dynamic>{
      'title': titleController.text.trim(),
      'startMileage': startMileageController.text.trim(),
      'endMileage': endMileageController.text.trim(),
      'fuelAmount': fuelAmountController.text.trim(),
      'fuelLiters': fuelLitersController.text.trim(),
      'stops': _stops.map((stop) => stop.toMap()).toList(),
    };
    await _draftRepository!.saveDraft(data);
  }

  Future<void> _clearDraft() async {
    if (_draftRepository == null) {
      return;
    }
    await _draftRepository!.clearDraft();
  }

  List<FuelStop> _readDraftStops(dynamic raw) {
    if (raw is! List) {
      return [];
    }
    final stops = <FuelStop>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        final stop = FuelStop.fromMap(item);
        if (stop != null) {
          stops.add(stop);
        }
      }
    }
    return stops;
  }

  void _notifyListeners() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    startMileageController.removeListener(_onMileageChanged);
    endMileageController.removeListener(_onMileageChanged);
    titleController.removeListener(_onDraftChanged);
    startMileageController.removeListener(_onDraftChanged);
    endMileageController.removeListener(_onDraftChanged);
    fuelAmountController.removeListener(_onDraftChanged);
    fuelLitersController.removeListener(_onDraftChanged);
    _draftSaveTimer?.cancel();
    startMileageController.dispose();
    endMileageController.dispose();
    titleController.dispose();
    fuelAmountController.dispose();
    fuelLitersController.dispose();
    _isDisposed = true;
    super.dispose();
  }
}
