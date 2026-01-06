import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_strings.dart';
import '../models/tour_entry.dart';
import 'app_logger.dart';
import 'oil_storage.dart';

class TourRepository {
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
      );
    } on FirebaseException catch (error) {
      logger.e('Firestore saveTour failed: ${error.code} ${error.message}');
      rethrow;
    } catch (error) {
      logger.e('Firestore saveTour failed: $error');
      rethrow;
    }
  }
}
