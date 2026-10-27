import 'dart:typed_data';
import 'package:flutter/material.dart';

class PatientProfile extends ChangeNotifier {
  PatientProfile._();

  static final PatientProfile instance = PatientProfile._();

  // These values will be populated after successful login.
  String name = 'Patient';
  int? userId;
  String email = '';
  DateTime? dateOfBirth;
  String phoneNumber = '';
  String address = '';
  String medicalNotes = '';
  String? photoUrl;
  Uint8List? photoBytes;

  int get age {
    if (dateOfBirth == null) return 0;

    final today = DateTime.now();
    int result = today.year - dateOfBirth!.year;

    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month &&
            today.day < dateOfBirth!.day)) {
      result--;
    }

    return result;
  }

  void loadFromLoginData(Map<String, dynamic> data) {
    userId = data['id'] as int?;
    name = data['name'] as String? ?? 'Patient';
    email = data['email'] as String? ?? '';
    phoneNumber = data['phoneNumber'] as String? ?? '';
    address = data['address'] as String? ?? '';
    medicalNotes = data['medicalNotes'] as String? ?? '';
    photoUrl = data['photoUrl'] as String?;

    final dob = data['dateOfBirth'] as String?;
    dateOfBirth = dob == null || dob.isEmpty
        ? null
        : DateTime.tryParse(dob);

    photoBytes = null;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required DateTime? dateOfBirth,
    required String phoneNumber,
    required String address,
    required String medicalNotes,
    String? photoUrl,
    Uint8List? photoBytes,
  }) {
    this.name = name;
    this.dateOfBirth = dateOfBirth;
    this.phoneNumber = phoneNumber;
    this.address = address;
    this.medicalNotes = medicalNotes;
    this.photoUrl = photoUrl;
    this.photoBytes = photoBytes;

    notifyListeners();
  }

  void clearProfile() {
    userId = null;
    name = 'Patient';
    email = '';
    dateOfBirth = null;
    phoneNumber = '';
    address = '';
    medicalNotes = '';
    photoUrl = null;
    photoBytes = null;

    notifyListeners();
  }
}