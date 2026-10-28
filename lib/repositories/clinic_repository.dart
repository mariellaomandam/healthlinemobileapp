import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/clinic.dart';

abstract interface class ClinicRepository {
  Stream<List<Clinic>> watchPublishedClinics();
  Stream<List<Clinic>> watchPublishedClinicsForService(String service);
  Stream<Clinic?> watchClinic(String clinicId);
  Future<void> saveClinic(Clinic clinic);
}

class FirestoreClinicRepository implements ClinicRepository {
  FirestoreClinicRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Stream<List<Clinic>> watchPublishedClinics() => _db
      .collection('clinics')
      .where('published', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Clinic.fromMap(doc.id, doc.data()))
            .toList(growable: false),
      );

  @override
  Stream<List<Clinic>> watchPublishedClinicsForService(String service) => _db
      .collection('clinics')
      .where('published', isEqualTo: true)
      .where('services', arrayContains: service)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Clinic.fromMap(doc.id, doc.data()))
            .toList(growable: false),
      );

  @override
  Stream<Clinic?> watchClinic(String clinicId) => _db
      .collection('clinics')
      .doc(clinicId)
      .snapshots()
      .map(
        (doc) => doc.exists && doc.data() != null
            ? Clinic.fromMap(doc.id, doc.data()!)
            : null,
      );

  @override
  Future<void> saveClinic(Clinic clinic) async {
    await _db.collection('clinics').doc(clinic.id).set({
      ...clinic.toMap(),
      'ownerUid': clinic.id,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
