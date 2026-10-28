import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/doctor.dart';

abstract interface class DoctorRepository {
  Stream<List<Doctor>> watchActiveDoctors();
  Stream<List<Doctor>> watchDoctorsForClinic(String clinicId);
  Future<String> saveDoctor({
    String? doctorId,
    required String clinicId,
    required String name,
    required String specialty,
    String bio,
    String imageUrl,
    bool active,
  });
}

class FirestoreDoctorRepository implements DoctorRepository {
  FirestoreDoctorRepository(this._db);
  final FirebaseFirestore _db;

  @override
  Stream<List<Doctor>> watchActiveDoctors() => _db
      .collection('doctors')
      .where('active', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Doctor.fromMap(doc.id, doc.data()))
            .toList(growable: false),
      );

  @override
  Stream<List<Doctor>> watchDoctorsForClinic(String clinicId) => _db
      .collection('doctors')
      .where('clinicId', isEqualTo: clinicId)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => Doctor.fromMap(doc.id, doc.data()))
            .toList(growable: false),
      );

  @override
  Future<String> saveDoctor({
    String? doctorId,
    required String clinicId,
    required String name,
    required String specialty,
    String bio = '',
    String imageUrl = '',
    bool active = true,
  }) async {
    final ref = doctorId == null || doctorId.isEmpty
        ? _db.collection('doctors').doc()
        : _db.collection('doctors').doc(doctorId);
    await ref.set({
      'clinicId': clinicId,
      'name': name.trim(),
      'specialty': specialty.trim(),
      'bio': bio.trim(),
      'imageUrl': imageUrl.trim(),
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return ref.id;
  }
}
