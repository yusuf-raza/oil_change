import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_strings.dart';
import 'oil_storage.dart';

class OilRepository {
  OilRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<DocumentReference<Map<String, dynamic>>> _docRef() async {
    // Resolve or create the user and return the per-user oil state document.
    final currentUser = _auth.currentUser;
    final uid = currentUser?.uid ?? (await _auth.signInAnonymously()).user?.uid;
    if (uid == null) {
      throw StateError('Failed to obtain user id.');
    }
    return _firestore
        .collection(AppStrings.firestoreUsersCollection)
        .doc(uid)
        .collection(AppStrings.firestoreOilStateCollection)
        .doc(AppStrings.firestoreOilStateDoc);
  }

  Future<Map<String, dynamic>?> fetchState() async {
    // Fetch the current oil state snapshot for the signed-in user.
    final doc = await _docRef();
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      return null;
    }
    return snapshot.data();
  }

  Future<void> saveState(Map<String, dynamic> data) async {
    // Merge the provided fields into the user's oil state document.
    final doc = await _docRef();
    await doc.set(data, SetOptions(merge: true));
  }

  Future<void> clearState() async {
    // Delete the user's oil state document entirely.
    final doc = await _docRef();
    await doc.delete();
  }

  static Map<String, dynamic> buildUpdateMap({
    int? currentMileage,
    int? intervalKm,
    int? lastChangeMileage,
    int? lastNotifiedDueMileage,
    int? lastNotifiedThreshold,
    String? unit,
    String? themeMode,
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
      OilStorageKeys.unit: unit ?? FieldValue.delete(),
      OilStorageKeys.themeMode: themeMode ?? FieldValue.delete(),
      OilStorageKeys.notificationsEnabled:
          notificationsEnabled ?? FieldValue.delete(),
    };
  }
}
