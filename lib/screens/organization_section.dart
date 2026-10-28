import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/healthline_firestore_service.dart';

class OrganizationSectionScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const OrganizationSectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  @override
  State<OrganizationSectionScreen> createState() =>
      _OrganizationSectionScreenState();
}

class _OrganizationSectionScreenState extends State<OrganizationSectionScreen> {
  final api = HealthLineFirestoreService.instance;
  final name = TextEditingController(),
      address = TextEditingController(),
      contact = TextEditingController(),
      description = TextEditingController(),
      services = TextEditingController(),
      image = TextEditingController();
  final doctorName = TextEditingController(),
      specialty = TextEditingController(),
      bio = TextEditingController(),
      doctorImage = TextEditingController();
  String? selectedDoctor;
  bool busy = false;
  static const bg = Color(0xFF101010),
      surface = Color(0xFF1C1A1A),
      mauve = Color(0xFFB78A9B),
      muted = Color(0xFFAAAAAA);
  @override
  void dispose() {
    for (final c in [
      name,
      address,
      contact,
      description,
      services,
      image,
      doctorName,
      specialty,
      bio,
      doctorImage,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void notice(String text) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> saveProfile() async {
    if (name.text.trim().isEmpty || address.text.trim().isEmpty) {
      notice('Clinic name and address are required.');
      return;
    }
    setState(() => busy = true);
    try {
      await api.ensureUser(role: 'clinic', displayName: name.text.trim());
      await api.saveClinicProfile(
        name: name.text,
        address: address.text,
        contact: contact.text,
        description: description.text,
        services: services.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        imageUrl: image.text,
        publish: true,
      );
      notice('Clinic profile saved and published.');
    } catch (e) {
      notice('Could not save profile: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> saveDoctor() async {
    if (doctorName.text.trim().isEmpty || specialty.text.trim().isEmpty) {
      notice('Doctor name and specialty are required.');
      return;
    }
    try {
      await api.saveDoctor(
        name: doctorName.text,
        specialty: specialty.text,
        bio: bio.text,
        imageUrl: doctorImage.text,
      );
      doctorName.clear();
      specialty.clear();
      bio.clear();
      doctorImage.clear();
      notice('Doctor saved.');
    } catch (e) {
      notice('Could not save doctor: $e');
    }
  }

  Future<void> addSlot() async {
    if (selectedDoctor == null) {
      notice('Select a doctor first.');
      return;
    }
    final day = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    final start = DateTime(
      day.year,
      day.month,
      day.day,
      time.hour,
      time.minute,
    );
    try {
      await api.addAvailability(
        doctorId: selectedDoctor!,
        start: start,
        end: start.add(const Duration(minutes: 30)),
      );
      notice('30-minute availability added.');
    } catch (e) {
      notice('Could not add availability: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: bg,
    appBar: AppBar(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      title: Text(widget.title),
    ),
    body: switch (widget.title) {
      'Clinic Profile' => _profile(),
      'Doctors' => _doctors(),
      'Schedule' => _schedule(),
      'Appointment Requests' => _appointments(),
      _ => _placeholder(),
    },
  );
  Widget _field(String label, TextEditingController c, {int lines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          maxLines: lines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: muted),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
  Widget _button(String label, VoidCallback? action) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        backgroundColor: mauve,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    ),
  );
  Widget _profile() => FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    future: api.db.collection('clinics').doc(api.requireUser.uid).get(),
    builder: (context, s) {
      if (s.hasData && s.data!.exists) {
        final d = s.data!.data()!;
        if (name.text.isEmpty) {
          name.text = d['name'] ?? '';
          address.text = d['address'] ?? '';
          contact.text = d['contact'] ?? '';
          description.text = d['description'] ?? '';
          services.text = (d['services'] as List? ?? []).join(', ');
          image.text = d['imageUrl'] ?? '';
        }
      }
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Complete your clinic profile. Published profiles appear to patients.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 16),
          _field('Clinic / hospital name', name),
          _field('Address', address),
          _field('Contact number', contact),
          _field('Description', description, lines: 3),
          _field(
            'Services (comma-separated, e.g. Check-up, Vaccination)',
            services,
            lines: 2,
          ),
          _field('Image URL (optional; no Firebase Storage required)', image),
          _button(
            busy ? 'Saving...' : 'Save and publish profile',
            busy ? null : saveProfile,
          ),
        ],
      );
    },
  );
  Widget _doctors() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _field('Doctor full name', doctorName),
      _field('Specialty', specialty),
      _field('Doctor bio', bio, lines: 3),
      _field('Doctor image URL (optional)', doctorImage),
      _button('Save doctor', saveDoctor),
      const SizedBox(height: 20),
      const Text(
        'Your doctors',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: api.clinicDoctors(),
        builder: (context, s) {
          if (s.hasError)
            return Text(
              'Error: ${s.error}',
              style: const TextStyle(color: Colors.red),
            );
          if (!s.hasData)
            return const Center(child: CircularProgressIndicator());
          if (s.data!.docs.isEmpty)
            return const Text(
              'No doctors added yet.',
              style: TextStyle(color: muted),
            );
          return Column(
            children: s.data!.docs.map((d) {
              final x = d.data();
              return Card(
                color: surface,
                child: ListTile(
                  title: Text(
                    x['name'] ?? 'Doctor',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    x['specialty'] ?? '',
                    style: const TextStyle(color: muted),
                  ),
                  trailing: TextButton(
                    onPressed: () => setState(() => selectedDoctor = d.id),
                    child: const Text('Use for schedule'),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    ],
  );
  Widget _schedule() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'Choose a doctor, then add an available 30-minute slot.',
        style: TextStyle(color: muted),
      ),
      const SizedBox(height: 12),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: api.clinicDoctors(),
        builder: (context, s) {
          if (!s.hasData) return const CircularProgressIndicator();
          final docs = s.data!.docs;
          return DropdownButtonFormField<String>(
            initialValue: selectedDoctor,
            dropdownColor: surface,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Doctor',
              labelStyle: TextStyle(color: muted),
            ),
            items: docs
                .map(
                  (d) => DropdownMenuItem(
                    value: d.id,
                    child: Text(d.data()['name'] ?? 'Doctor'),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => selectedDoctor = v),
          );
        },
      ),
      const SizedBox(height: 14),
      _button('Add availability', addSlot),
      const SizedBox(height: 20),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: api.db
            .collection('availability')
            .where('clinicId', isEqualTo: api.requireUser.uid)
            .orderBy('startAt')
            .snapshots(),
        builder: (context, s) {
          if (s.hasError)
            return Text(
              'Error: ${s.error}',
              style: const TextStyle(color: Colors.red),
            );
          if (!s.hasData) return const CircularProgressIndicator();
          return Column(
            children: s.data!.docs.map((d) {
              final x = d.data();
              final dt = (x['startAt'] as Timestamp).toDate();
              return Card(
                color: surface,
                child: ListTile(
                  title: Text(
                    dt.toLocal().toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Status: ${x['status']}',
                    style: const TextStyle(color: muted),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    ],
  );
  Widget _appointments() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: api.clinicAppointments(),
    builder: (context, s) {
      if (s.hasError)
        return Center(
          child: Text('${s.error}', style: const TextStyle(color: Colors.red)),
        );
      if (!s.hasData) return const Center(child: CircularProgressIndicator());
      return ListView(
        padding: const EdgeInsets.all(16),
        children: s.data!.docs.map((d) {
          final x = d.data();
          return Card(
            color: surface,
            child: ListTile(
              title: Text(
                '${x['doctorName']} · ${x['patientUid']}',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${x['dateTime'] is Timestamp ? (x['dateTime'] as Timestamp).toDate() : ''}\n${x['status']}',
                style: const TextStyle(color: muted),
              ),
            ),
          );
        }).toList(),
      );
    },
  );
  Widget _placeholder() => const Center(
    child: Text(
      'This section is not connected yet.',
      style: TextStyle(color: muted),
    ),
  );
}
