import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/clinic.dart';
import '../models/doctor.dart';
import '../providers/healthline_repository_providers.dart';
import '../services/healthline_firestore_service.dart';
import 'chat_detail.dart';

const _bg = Color(0xFF101010);
const _surface = Color(0xFF1C1A1A);
const _mauve = Color(0xFFB78A9B);
const _muted = Color(0xFFAAAAAA);

class ClinicDirectoryScreen extends ConsumerWidget {
  final String service;

  const ClinicDirectoryScreen({super.key, this.service = 'Check-up'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinicsAsync = service == 'All clinics'
        ? ref.watch(publishedClinicsProvider)
        : ref.watch(clinicsForServiceProvider(service));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: Text(service == 'All clinics' ? 'Clinics' : service),
      ),
      body: clinicsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load clinics: $error',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
        data: (clinics) {
          if (clinics.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No clinics have published ${service == 'All clinics' ? 'their profiles' : 'this service'} yet.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _muted),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: clinics.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              return _ClinicTile(clinic: clinic);
            },
          );
        },
      ),
    );
  }
}

class _ClinicTile extends StatelessWidget {
  const _ClinicTile({required this.clinic});
  final Clinic clinic;

  @override
  Widget build(BuildContext context) => Card(
    color: _surface,
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: CircleAvatar(
        backgroundColor: _mauve.withAlpha(50),
        backgroundImage: clinic.imageUrl.isNotEmpty
            ? NetworkImage(clinic.imageUrl)
            : null,
        child: clinic.imageUrl.isEmpty
            ? const Icon(Icons.local_hospital_outlined, color: _mauve)
            : null,
      ),
      title: Text(
        clinic.name.isEmpty ? 'Clinic' : clinic.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          '${clinic.address.isEmpty ? 'Address not provided' : clinic.address}\n${clinic.services.join(' • ')}',
          style: const TextStyle(color: _muted, height: 1.4),
        ),
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right, color: _mauve),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClinicDoctorsScreen(
            clinicId: clinic.id,
            clinicName: clinic.name.isEmpty ? 'Clinic' : clinic.name,
          ),
        ),
      ),
    ),
  );
}

class ClinicDoctorsScreen extends ConsumerWidget {
  final String clinicId;
  final String clinicName;

  const ClinicDoctorsScreen({
    super.key,
    required this.clinicId,
    required this.clinicName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(clinicDoctorsProvider(clinicId));
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: Text(clinicName),
      ),
      body: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Could not load doctors: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (doctors) {
          final activeDoctors = doctors
              .where((doctor) => doctor.active)
              .toList(growable: false);
          if (activeDoctors.isEmpty) {
            return const Center(
              child: Text(
                'This clinic has not listed any doctors yet.',
                style: TextStyle(color: _muted),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: activeDoctors
                .map(
                  (doctor) => _DoctorTile(
                    doctor: doctor,
                    clinicId: clinicId,
                    clinicName: clinicName,
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  const _DoctorTile({
    required this.doctor,
    required this.clinicId,
    required this.clinicName,
  });
  final Doctor doctor;
  final String clinicId;
  final String clinicName;

  @override
  Widget build(BuildContext context) => Card(
    color: _surface,
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: _mauve.withAlpha(40),
        backgroundImage: doctor.imageUrl.isNotEmpty
            ? NetworkImage(doctor.imageUrl)
            : null,
        child: doctor.imageUrl.isEmpty
            ? const Icon(Icons.person_outline, color: _mauve)
            : null,
      ),
      title: Text(
        doctor.name.isEmpty ? 'Doctor' : doctor.name,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        '${doctor.specialty}\n${doctor.bio}',
        style: const TextStyle(color: _muted),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right, color: _mauve),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorAvailabilityScreen(
            doctorId: doctor.id,
            doctor: doctor.toMap(),
            clinicId: clinicId,
            clinicName: clinicName,
          ),
        ),
      ),
    ),
  );
}

class DoctorAvailabilityScreen extends StatelessWidget {
  final String doctorId;
  final String clinicId;
  final String clinicName;
  final Map<String, dynamic> doctor;

  const DoctorAvailabilityScreen({
    super.key,
    required this.doctorId,
    required this.doctor,
    required this.clinicId,
    required this.clinicName,
  });

  @override
  Widget build(BuildContext context) {
    final api = HealthLineFirestoreService.instance;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: Text((doctor['name'] ?? 'Doctor').toString()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            (doctor['specialty'] ?? '').toString(),
            style: const TextStyle(color: _mauve, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            (doctor['bio'] ?? 'No biography provided.').toString(),
            style: const TextStyle(color: _muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                try {
                  final conversationId = await api.getOrCreateConversation(
                    clinicId,
                  );
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        hospital: clinicName,
                        otherUid: clinicId,
                        conversationId: conversationId,
                      ),
                    ),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not start message: $error')),
                  );
                }
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Message clinic'),
              style: OutlinedButton.styleFrom(foregroundColor: _mauve),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Available appointment times',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: api.availableSlots(doctorId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Could not load availability: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final slots = snapshot.data!.docs;
              if (slots.isEmpty) {
                return const Text(
                  'No available times have been added yet.',
                  style: TextStyle(color: _muted),
                );
              }

              return Column(
                children: slots.map((slot) {
                  final data = slot.data();
                  final start = (data['startAt'] as Timestamp)
                      .toDate()
                      .toLocal();
                  final dateLabel =
                      '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
                  final timeLabel = TimeOfDay.fromDateTime(
                    start,
                  ).format(context);

                  return Card(
                    color: _surface,
                    child: ListTile(
                      title: Text(
                        '$dateLabel · $timeLabel',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mauve,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          try {
                            await api.requestAppointment(
                              clinicId: clinicId,
                              doctorId: doctorId,
                              slotId: slot.id,
                              startAt: start,
                              clinicName: clinicName,
                              doctorName: (doctor['name'] ?? 'Doctor')
                                  .toString(),
                              specialty: (doctor['specialty'] ?? '').toString(),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Appointment requested.'),
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not book: $error')),
                            );
                          }
                        },
                        child: const Text('Request'),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
