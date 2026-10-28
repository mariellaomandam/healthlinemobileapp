import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/clinic.dart';
import '../models/doctor.dart';
import '../repositories/clinic_repository.dart';
import '../repositories/doctor_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final clinicRepositoryProvider = Provider<ClinicRepository>(
  (ref) => FirestoreClinicRepository(ref.watch(firestoreProvider)),
);

final doctorRepositoryProvider = Provider<DoctorRepository>(
  (ref) => FirestoreDoctorRepository(ref.watch(firestoreProvider)),
);

final publishedClinicsProvider = StreamProvider<List<Clinic>>(
  (ref) => ref.watch(clinicRepositoryProvider).watchPublishedClinics(),
);

final clinicsForServiceProvider = StreamProvider.family<List<Clinic>, String>(
  (ref, service) => ref
      .watch(clinicRepositoryProvider)
      .watchPublishedClinicsForService(service),
);

final clinicByIdProvider = StreamProvider.family<Clinic?, String>(
  (ref, clinicId) => ref.watch(clinicRepositoryProvider).watchClinic(clinicId),
);

final activeDoctorsProvider = StreamProvider<List<Doctor>>(
  (ref) => ref.watch(doctorRepositoryProvider).watchActiveDoctors(),
);

final clinicDoctorsProvider = StreamProvider.family<List<Doctor>, String>(
  (ref, clinicId) =>
      ref.watch(doctorRepositoryProvider).watchDoctorsForClinic(clinicId),
);
