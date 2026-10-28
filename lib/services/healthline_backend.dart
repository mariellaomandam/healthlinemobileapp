
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthLineBackend {
  HealthLineBackend._();

  static final instance = HealthLineBackend._();

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String get uid {
    final user = auth.currentUser;
    if (user == null) throw StateError('Please sign in first.');
    return user.uid;
  }

  // Account roles are stored at users/{uid}.
  Future<void> saveUserRole({
    required String role,
    required String name,
    required String email,
  }) async {
    if (role != 'patient' && role != 'clinic') {
      throw ArgumentError('Role must be patient or clinic.');
    }

    await db.collection('users').doc(uid).set({
      'uid': uid,
      'role': role,
      'name': name.trim(),
      'email': email.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchMyAccount() {
    return db.collection('users').doc(uid).snapshots();
  }

  // A clinic profile is keyed by the owner's Firebase UID.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchMyClinic() {
    return db.collection('clinics').doc(uid).snapshots();
  }

  Future<void> saveClinicProfile({
    required String name,
    required String address,
    required String contact,
    required String description,
    required List<String> services,
    String imageUrl = '',
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Clinic name is required.');
    }

    await db.collection('clinics').doc(uid).set({
      'ownerUid': uid,
      'name': cleanName,
      'address': address.trim(),
      'contact': contact.trim(),
      'description': description.trim(),
      'services': services,
      'imageUrl': imageUrl.trim(),
      'published': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Patient-facing directory: only published clinic profiles.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchClinics() {
    return db.collection('clinics')
        .where('published', isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchClinicsOffering(
    String service,
  ) {
    return db.collection('clinics')
        .where('published', isEqualTo: true)
        .where('services', arrayContains: service)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDoctors() {
    return db.collection('doctors')
        .where('active', isEqualTo: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchClinicDoctors(
    String clinicId,
  ) {
    return db.collection('doctors')
        .where('clinicId', isEqualTo: clinicId)
        .where('active', isEqualTo: true)
        .snapshots();
  }

  Future<String> saveDoctor({
    String? doctorId,
    required String name,
    required String specialty,
    required String bio,
    String photoUrl = '',
    String clinicName = '',
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Doctor name is required.');
    }

    final ref = doctorId == null
        ? db.collection('doctors').doc()
        : db.collection('doctors').doc(doctorId);

    final existing = await ref.get();
    if (existing.exists && existing.data()?['clinicId'] != uid) {
      throw StateError('You cannot edit another clinic’s doctor.');
    }

    await ref.set({
      'clinicId': uid,
      'clinicName': clinicName.trim(),
      'name': cleanName,
      'specialty': specialty.trim(),
      'bio': bio.trim(),
      'photoUrl': photoUrl.trim(),
      'active': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return ref.id;
  }

  Future<void> deactivateDoctor(String doctorId) async {
    final ref = db.collection('doctors').doc(doctorId);
    final snapshot = await ref.get();

    if (!snapshot.exists || snapshot.data()?['clinicId'] != uid) {
      throw StateError('Doctor not found or not owned by this clinic.');
    }

    await ref.update({
      'active': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Schedules use actual Firestore timestamps.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchDoctorAvailability(
    String doctorId,
  ) {
    return db.collection('availability')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'available')
        .where('startAt', isGreaterThan: Timestamp.now())
        .orderBy('startAt')
        .snapshots();
  }

  Future<String> addAvailability({
    required String doctorId,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    if (!endAt.isAfter(startAt) || !startAt.isAfter(DateTime.now())) {
      throw ArgumentError('Choose a future time with a valid end time.');
    }

    final doctor = await db.collection('doctors').doc(doctorId).get();
    if (!doctor.exists || doctor.data()?['clinicId'] != uid) {
      throw StateError('You can only schedule your own clinic’s doctors.');
    }

    final ref = db.collection('availability').doc();
    await ref.set({
      'clinicId': uid,
      'doctorId': doctorId,
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // Patient creates a request against an existing availability slot.
  Future<String> requestAppointment({
    required String slotId,
    required String doctorId,
    required String clinicId,
    required String patientName,
    required String reason,
  }) async {
    final slotRef = db.collection('availability').doc(slotId);
    final appointmentRef = db.collection('appointments').doc();

    await db.runTransaction((transaction) async {
      final slot = await transaction.get(slotRef);
      if (!slot.exists) throw StateError('This time is no longer available.');

      final data = slot.data()!;
      if (data['status'] != 'available' ||
          data['doctorId'] != doctorId ||
          data['clinicId'] != clinicId) {
        throw StateError('This time is no longer available.');
      }

      transaction.update(slotRef, {'status': 'requested'});
      transaction.set(appointmentRef, {
        'patientUid': uid,
        'patientName': patientName.trim(),
        'clinicId': clinicId,
        'doctorId': doctorId,
        'slotId': slotId,
        'reason': reason.trim(),
        'status': 'requested',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return appointmentRef.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyAppointments() {
    return db.collection('appointments')
        .where('patientUid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchClinicAppointments() {
    return db.collection('appointments')
        .where('clinicId', isEqualTo: uid)
        .snapshots();
  }

  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    if (!{'confirmed', 'declined', 'completed', 'cancelled'}.contains(status)) {
      throw ArgumentError('Invalid appointment status.');
    }

    final ref = db.collection('appointments').doc(appointmentId);
    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.data()?['clinicId'] != uid) {
      throw StateError('Appointment not found or not owned by this clinic.');
    }

    await ref.update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // When declined/cancelled, release the slot for another request.
    if (status == 'declined' || status == 'cancelled') {
      final slotId = snapshot.data()?['slotId'];
      if (slotId is String) {
        await db.collection('availability').doc(slotId).update({
          'status': 'available',
        });
      }
    }
  }

  // Conversation IDs are deterministic for a patient/clinic pair.
  String conversationId(String patientUid, String clinicUid) {
    final ids = [patientUid, clinicUid]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<String> startConversation({
    required String patientUid,
    required String clinicUid,
    required String otherName,
  }) async {
    final id = conversationId(patientUid, clinicUid);
    await db.collection('conversations').doc(id).set({
      'participantUids': [patientUid, clinicUid],
      'patientUid': patientUid,
      'clinicUid': clinicUid,
      'otherName': otherName.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyConversations() {
    return db.collection('conversations')
        .where('participantUids', arrayContains: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(
    String conversationId,
  ) {
    return db.collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final conversationRef =
        db.collection('conversations').doc(conversationId);
    final conversation = await conversationRef.get();

    if (!conversation.exists ||
        !(conversation.data()?['participantUids'] as List<dynamic>? ?? [])
            .contains(uid)) {
      throw StateError('You are not a participant in this conversation.');
    }

    final batch = db.batch();
    final messageRef = conversationRef.collection('messages').doc();
    batch.set(messageRef, {
      'senderUid': uid,
      'text': cleanText,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
    batch.update(conversationRef, {
      'lastMessage': cleanText,
      'lastSenderUid': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
