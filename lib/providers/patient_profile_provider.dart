import 'package:flutter_riverpod/legacy.dart';
import '../models/patient_profile.dart';

final patientProfileProvider = ChangeNotifierProvider<PatientProfile>((ref) {
  return PatientProfile.instance;
});
