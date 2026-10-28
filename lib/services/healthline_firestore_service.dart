import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Shared Firestore access for HealthLine PH.
/// Document IDs for clinics are the owning Firebase Auth UID.
class HealthLineFirestoreService {
  HealthLineFirestoreService._();
  static final instance = HealthLineFirestoreService._();

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  User get requireUser {
    final user = auth.currentUser;
    if (user == null) throw StateError('Please sign in first.');
    return user;
  }

  Future<void> ensureUser({required String role, String? displayName}) async {
    final user = requireUser;
    final ref = db.collection('users').doc(user.uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({
        'uid': user.uid,
        'role': role,
        'displayName': displayName ?? user.displayName ?? '',
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      final existingRole = snapshot.data()?['role'];
      if (existingRole != role) {
        throw StateError('This account is registered as ${existingRole ?? 'another role'}.');
      }
      await ref.set({
        'displayName': displayName ?? user.displayName ?? '',
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> saveClinicProfile({
    required String name,
    required String address,
    required String contact,
    required String description,
    required List<String> services,
    String? imageUrl,
    bool publish = true,
  }) async {
    final user = requireUser;
    await db.collection('clinics').doc(user.uid).set({
      'ownerUid': user.uid,
      'name': name.trim(),
      'address': address.trim(),
      'contact': contact.trim(),
      'description': description.trim(),
      'services': services,
      'imageUrl': imageUrl?.trim() ?? '',
      'published': publish,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> clinicProfile() =>
      db.collection('clinics').doc(requireUser.uid).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> publishedClinicsForService(String service) =>
      db.collection('clinics')
          .where('published', isEqualTo: true)
          .where('services', arrayContains: service)
          .snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> publishedClinics() =>
      db.collection('clinics').where('published', isEqualTo: true).snapshots();

  Future<String> saveDoctor({
    String? doctorId,
    required String name,
    required String specialty,
    String bio = '',
    String imageUrl = '',
    bool active = true,
  }) async {
    final user = requireUser;
    final ref = doctorId == null
        ? db.collection('doctors').doc()
        : db.collection('doctors').doc(doctorId);
    await ref.set({
      'clinicId': user.uid,
      'name': name.trim(),
      'specialty': specialty.trim(),
      'bio': bio.trim(),
      'imageUrl': imageUrl.trim(),
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> activeDoctors() =>
      db.collection('doctors').where('active', isEqualTo: true).snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> clinicDoctors() =>
      db.collection('doctors')
          .where('clinicId', isEqualTo: requireUser.uid)
          .snapshots();

  Future<String> addAvailability({
    required String doctorId,
    required DateTime start,
    required DateTime end,
  }) async {
    final user = requireUser;
    final ref = db.collection('availability').doc();
    await ref.set({
      'clinicId': user.uid,
      'doctorId': doctorId,
      'startAt': Timestamp.fromDate(start),
      'endAt': Timestamp.fromDate(end),
      'status': 'available',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> availableSlots(String doctorId) =>
      db.collection('availability')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'available')
          .orderBy('startAt')
          .snapshots();

  Future<String> requestAppointment({
    required String clinicId,
    required String doctorId,
    required String slotId,
    required DateTime startAt,
    required String clinicName,
    required String doctorName,
    required String specialty,
  }) async {
    final user = requireUser;
    final ref = db.collection('appointments').doc();
    await db.runTransaction((transaction) async {
      final slotRef = db.collection('availability').doc(slotId);
      final slot = await transaction.get(slotRef);
      if (!slot.exists || slot.data()?['status'] != 'available') {
        throw StateError('That appointment time is no longer available.');
      }
      transaction.set(ref, {
        'patientUid': user.uid,
        'clinicId': clinicId,
        'doctorId': doctorId,
        'slotId': slotId,
        'clinicName': clinicName,
        'doctorName': doctorName,
        'specialty': specialty,
        'dateTime': Timestamp.fromDate(startAt),
        'status': 'requested',
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.update(slotRef, {
        'status': 'requested',
        'appointmentId': ref.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
    return ref.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> patientAppointments() =>
      db.collection('appointments')
          .where('patientUid', isEqualTo: requireUser.uid)
          .orderBy('dateTime')
          .snapshots();

  Stream<QuerySnapshot<Map<String, dynamic>>> clinicAppointments() =>
      db.collection('appointments')
          .where('clinicId', isEqualTo: requireUser.uid)
          .orderBy('dateTime')
          .snapshots();

  Future<String> getOrCreateConversation(String otherUid) async {
    final user = requireUser;
    final ids = [user.uid, otherUid]..sort();
    final conversationId = '${ids[0]}_${ids[1]}';
    final ref = db.collection('conversations').doc(conversationId);
    await db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) {
        tx.set(ref, {
          'participantUids': ids,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
      } else if (!(doc.data()?['participantUids'] as List).contains(user.uid)) {
        throw StateError('You do not have access to this conversation.');
      }
    });
    return conversationId;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> conversationMessages(String conversationId) =>
      db.collection('conversations').doc(conversationId)
          .collection('messages').orderBy('createdAt').snapshots();

  Future<void> sendMessage(String conversationId, String text) async {
    final user = requireUser;
    final value = text.trim();
    if (value.isEmpty) return;
    final conversation = db.collection('conversations').doc(conversationId);
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(conversation);
      final participants = List<String>.from(snapshot.data()?['participantUids'] ?? const []);
      if (!snapshot.exists || !participants.contains(user.uid)) {
        throw StateError('Conversation not found or access denied.');
      }
      final message = conversation.collection('messages').doc();
      tx.set(message, {
        'senderUid': user.uid,
        'text': value,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(conversation, {
        'lastMessage': value,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
