import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_strings.dart';
import '../models/enums.dart';
import '../models/fuel_stop.dart';
import '../models/tour_entry.dart';
import '../services/location_service.dart';
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
    TourRepository? repository,
  })  : _locationService = locationService ?? LocationService(),
        _repository = repository ??
            TourRepository(FirebaseFirestore.instance, FirebaseAuth.instance) {
    startMileageController.addListener(_onMileageChanged);
    endMileageController.addListener(_onMileageChanged);
  }

  final LocationServiceBase _locationService;
  final TourRepository _repository;
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
  }

  void removeStop(int index) {
    if (index < 0 || index >= _stops.length) {
      return;
    }
    _stops.removeAt(index);
    notifyListeners();
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
    startMileageController.dispose();
    endMileageController.dispose();
    titleController.dispose();
    fuelAmountController.dispose();
    fuelLitersController.dispose();
    _isDisposed = true;
    super.dispose();
  }
}
