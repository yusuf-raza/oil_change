import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_strings.dart';
import 'app_logger.dart';
import 'oil_storage.dart';

class OilRepository {
  OilRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final logger = AppLogger.logger;

  Future<DocumentReference<Map<String, dynamic>>> _docRef() async {
    // Resolve or create the user and return the per-user oil state document.
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('User must be signed in.');
    }
    if (currentUser.isAnonymous) {
      throw StateError('Anonymous users are not supported.');
    }
    final uid = currentUser.uid;
    return _firestore
        .collection(AppStrings.firestoreUsersCollection)
        .doc(uid)
        .collection(AppStrings.firestoreOilStateCollection)
        .doc(AppStrings.firestoreOilStateDoc);
  }

  Future<Map<String, dynamic>?> fetchState() async {
    // Fetch the current oil state snapshot for the signed-in user.
    try {
      final doc = await _docRef();
      final snapshot = await doc.get();
      logger.i(
        'Firestore fetchState doc=${doc.path} exists=${snapshot.exists}',
      );
      if (!snapshot.exists) {
        return null;
      }
      return snapshot.data();
    } on FirebaseException catch (error) {
      logger.e(
        'Firestore fetchState failed: ${error.code} ${error.message}',
      );
      rethrow;
    } catch (error) {
      logger.e('Firestore fetchState failed: $error');
      rethrow;
    }
  }

  Future<void> saveState(Map<String, dynamic> data) async {
    // Merge the provided fields into the user's oil state document.
    try {
      final doc = await _docRef();
      await doc.set(data, SetOptions(merge: true));
      logger.i('Firestore saveState doc=${doc.path}');
    } on FirebaseException catch (error) {
      logger.e('Firestore saveState failed: ${error.code} ${error.message}');
      rethrow;
    } catch (error) {
      logger.e('Firestore saveState failed: $error');
      rethrow;
    }
  }

  Future<void> clearState() async {
    // Delete the user's oil state document entirely.
    try {
      final doc = await _docRef();
      await doc.delete();
    } on FirebaseException catch (error) {
      logger.e('Firestore clearState failed: ${error.code} ${error.message}');
      rethrow;
    } catch (error) {
      logger.e('Firestore clearState failed: $error');
      rethrow;
    }
  }

  static Map<String, dynamic> buildUpdateMap({
    int? currentMileage,
    int? intervalKm,
    int? lastChangeMileage,
    int? lastNotifiedDueMileage,
    int? lastNotifiedThreshold,
    int? lastNotifiedDate,
    String? unit,
    int? notificationLeadKm,
    bool? notificationsEnabled,
  }) {
    // Build a Firestore-friendly update map that deletes null fields.
    return {
      OilStorageKeys.currentMileage: currentMileage ?? FieldValue.delete(),
      OilStorageKeys.intervalKm: intervalKm ?? FieldValue.delete(),
      OilStorageKeys.lastChangeMileage: lastChangeMileage ?? FieldValue.delete(),
      OilStorageKeys.lastNotifiedDueMileage:
          lastNotifiedDueMileage ?? FieldValue.delete(),
      OilStorageKeys.lastNotifiedThreshold:
          lastNotifiedThreshold ?? FieldValue.delete(),
      OilStorageKeys.lastNotifiedDate:
          lastNotifiedDate ?? FieldValue.delete(),
      OilStorageKeys.unit: unit ?? FieldValue.delete(),
      OilStorageKeys.notificationLeadKm:
          notificationLeadKm ?? FieldValue.delete(),
      OilStorageKeys.notificationsEnabled:
          notificationsEnabled ?? FieldValue.delete(),
    };
  }
}
