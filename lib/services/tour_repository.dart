import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_strings.dart';
import '../models/tour_entry.dart';
import 'app_logger.dart';
import 'oil_storage.dart';

abstract class TourRepositoryBase {
  Future<List<TourEntry>> fetchTours();
  Future<TourEntry> saveTour(TourEntry entry);
  Future<TourEntry> updateTour(TourEntry entry);
  Future<void> deleteTour(String id);
}

class TourRepository implements TourRepositoryBase {
  TourRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final logger = AppLogger.logger;

  Future<DocumentReference<Map<String, dynamic>>> _docRef() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('User must be signed in.');
    }
    if (currentUser.isAnonymous) {
      throw StateError('Anonymous users are not supported.');
    }
    return _firestore
        .collection(AppStrings.firestoreUsersCollection)
        .doc(currentUser.uid)
        .collection(AppStrings.firestoreOilStateCollection)
        .doc(AppStrings.firestoreOilStateDoc);
  }

  @override
  Future<List<TourEntry>> fetchTours() async {
    try {
      final doc = await _docRef();
      final snapshot = await doc.get();
      final data = snapshot.data();
      final raw = data?[OilStorageKeys.tourHistory];
      if (raw is! List) {
        return [];
      }
      final entries = <TourEntry>[];
      for (final item in raw) {
        if (item is Map) {
          final mapped = Map<String, dynamic>.from(item);
          final entry = TourEntry.fromMap(
            mapped['id']?.toString() ?? '',
            mapped,
          );
          if (entry != null) {
            entries.add(entry);
          }
        }
      }
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } on FirebaseException catch (error) {
      logger.e('Firestore fetchTours failed: ${error.code} ${error.message}');
      rethrow;
    } catch (error) {
      logger.e('Firestore fetchTours failed: $error');
      rethrow;
    }
  }

  @override
  Future<TourEntry> saveTour(TourEntry entry) async {
    try {
      final doc = await _docRef();
      final snapshot = await doc.get();
      final data = snapshot.data();
      final raw = data?[OilStorageKeys.tourHistory];
      final existing = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map) {
            existing.add(Map<String, dynamic>.from(item));
          }
        }
      }
      final id = entry.id.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : entry.id;
      final payload = {
        ...entry.toMap(),
        'id': id,
      };
      existing.insert(0, payload);
      await doc.set(
        {
          OilStorageKeys.tourHistory: existing,
        },
        SetOptions(merge: true),
      );
      logger.i('Firestore saveTour doc=${doc.path}');
      return TourEntry(
        id: id,
        createdAt: entry.createdAt,
        title: entry.title,
        unit: entry.unit,
        startMileage: entry.startMileage,
        endMileage: entry.endMileage,
        distanceKm: entry.distanceKm,
        totalLiters: entry.totalLiters,
        totalSpendPkr: entry.totalSpendPkr,
        stops: entry.stops,
        expenses: entry.expenses,
        startAt: entry.startAt,
        endAt: entry.endAt,
      );
    } on FirebaseException catch (error) {
      logger.e('Firestore saveTour failed: ${error.code} ${error.message}');
      rethrow;
    } catch (error) {
      logger.e('Firestore saveTour failed: $error');
      rethrow;
    }
  }

  @override
  Future<TourEntry> updateTour(TourEntry entry) async {
    if (entry.id.isEmpty) {
      return saveTour(entry);
    }
    try {
      final doc = await _docRef();
      final snapshot = await doc.get();
      final data = snapshot.data();
      final raw = data?[OilStorageKeys.tourHistory];
      final existing = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is Map) {
            existing.add(Map<String, dynamic>.from(item));
          }
        }
      }
      final payload = {
        ...entry.toMap(),
        'id': entry.id,
      };
      final index =
          existing.indexWhere((item) => item['id']?.toString() == entry.id);
      if (index >= 0) {
        existing[index] = payload;
      } else {
        existing.insert(0, payload);
      }
      await doc.set(
        {
          OilStorageKeys.tourHistory: existing,
        },
        SetOptions(merge: true),
      );
      logger.i('Firestore updateTour doc=${doc.path} id=${entry.id}');
      return entry;
    } on FirebaseException catch (error) {
      logger.e('Firestore updateTour failed: ${error.code} ${error.message}');
      rethrow;
    } catch (error) {
      logger.e('Firestore updateTour failed: $error');
      rethrow;
    }
  }

  @override
  Future<void> deleteTour(String id) async {
    try {
      final doc = await _docRef();
      final snapshot = await doc.get();
      final data = snapshot.data();
      final raw = data?[OilStorageKeys.tourHistory];
      if (raw is! List) {
        return;
      }
      final updated = raw.where((item) {
        if (item is Map) {
          final mapped = Map<String, dynamic>.from(item);
          return mapped['id']?.toString() != id;
        }
        return true;
      }).toList();
      await doc.set(
        {
          OilStorageKeys.tourHistory: updated,
        },
        SetOptions(merge: true),
      );
      logger.i('Firestore deleteTour doc=${doc.path} id=$id');
    } on FirebaseException catch (error) {
      logger.e('Firestore deleteTour failed: ${error.code} ${error.message}');
      rethrow;
    } catch (error) {
      logger.e('Firestore deleteTour failed: $error');
      rethrow;
    }
  }

  Future<void> replaceTours(List<Map<String, dynamic>> payload) async {
    try {
      final doc = await _docRef();
      await doc.set(
        {
          OilStorageKeys.tourHistory: payload,
        },
        SetOptions(merge: true),
      );
      logger.i('Firestore replaceTours doc=${doc.path}');
    } on FirebaseException catch (error) {
      logger.e(
        'Firestore replaceTours failed: ${error.code} ${error.message}',
      );
      rethrow;
    } catch (error) {
      logger.e('Firestore replaceTours failed: $error');
      rethrow;
    }
  }
}
