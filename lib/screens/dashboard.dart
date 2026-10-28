import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/healthline_firestore_service.dart';
import 'clinic_directory_screen.dart';

const _bg = Color(0xFF101010);
const _surface = Color(0xFF1C1A1A);
const _lightMauve = Color(0xFFE6CACA);
const _muted = Color(0xFFAAAAAA);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static void _openDoctor(
    BuildContext context,
    String doctorId,
    Map<String, dynamic> doctor,
  ) async {
    final clinicId = (doctor['clinicId'] ?? '').toString();
    if (clinicId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This doctor has no clinic linked yet.')),
      );
      return;
    }

    try {
      final clinic = await FirebaseFirestore.instance
          .collection('clinics')
          .doc(clinicId)
          .get();
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorAvailabilityScreen(
            doctorId: doctorId,
            doctor: doctor,
            clinicId: clinicId,
            clinicName: (clinic.data()?['name'] ?? 'Clinic').toString(),
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open doctor: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFF423636),
                  child: Icon(Icons.favorite, color: _lightMauve),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: uid == null
                        ? null
                        : FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data();
                      final name =
                          (data?['displayName'] ??
                                  FirebaseAuth
                                      .instance
                                      .currentUser
                                      ?.displayName ??
                                  'Patient')
                              .toString();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $name!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Take care of yourself today.',
                            style: TextStyle(color: _muted, fontSize: 11),
                          ),
                          const Text(
                            'Your next step to better health starts here.',
                            style: TextStyle(color: _muted, fontSize: 11),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Messages',
                  onPressed: () => Navigator.pushNamed(context, '/messages'),
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF624747), Color(0xFF342828)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find care that fits your needs.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Browse published clinics, specialists, and available appointment times.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/appointments'),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('My appointments'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _search = value.trim().toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search doctors or specialties...',
                hintStyle: const TextStyle(color: _muted, fontSize: 12),
                prefixIcon: const Icon(Icons.search, color: _lightMauve),
                filled: true,
                fillColor: _surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 28),
            _SectionHeading(
              title: 'Popular Services',
              action: 'Explore',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const ClinicDirectoryScreen(service: 'All clinics'),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 116,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _ServiceTile(
                    name: 'Check-up',
                    icon: Icons.medical_services_outlined,
                  ),
                  _ServiceTile(
                    name: 'Vaccination',
                    icon: Icons.vaccines_outlined,
                  ),
                  _ServiceTile(
                    name: 'Laboratory',
                    icon: Icons.science_outlined,
                  ),
                  _ServiceTile(
                    name: 'Dental Care',
                    icon: Icons.health_and_safety_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _SectionHeading(
              title: 'Our Doctors',
              action: 'View all',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AllDoctorsScreen()),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Find the right specialist for you',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: HealthLineFirestoreService.instance.activeDoctors(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Could not load doctors: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final searchable =
                      '${data['name'] ?? ''} ${data['specialty'] ?? ''} ${data['bio'] ?? ''}'
                          .toLowerCase();
                  return searchable.contains(_search);
                }).toList();

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No clinic-listed doctors found yet.',
                      style: TextStyle(color: _muted),
                    ),
                  );
                }

                return SizedBox(
                  height: 158,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: docs.length,
                    separatorBuilder: (_, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final imageUrl = (data['imageUrl'] ?? '').toString();
                      return SizedBox(
                        width: 250,
                        child: Card(
                          color: _surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(color: Colors.white.withAlpha(18)),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _openDoctor(context, doc.id, data),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 31,
                                    backgroundColor: const Color(0xFF423636),
                                    backgroundImage: imageUrl.isEmpty
                                        ? null
                                        : NetworkImage(imageUrl),
                                    child: imageUrl.isEmpty
                                        ? const Icon(
                                            Icons.person_outline,
                                            color: _lightMauve,
                                            size: 30,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (data['name'] ?? 'Doctor').toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          (data['specialty'] ?? '').toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: _muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'View profile and availability',
                                          style: TextStyle(
                                            color: _lightMauve,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;

  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(color: _lightMauve, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String name;
  final IconData icon;

  const _ServiceTile({required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicDirectoryScreen(service: name),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF423636),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _lightMauve, size: 22),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AllDoctorsScreen extends StatelessWidget {
  const AllDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text('Our Doctors'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: HealthLineFirestoreService.instance.activeDoctors(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load doctors: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No clinic-listed doctors found yet.',
                style: TextStyle(color: _muted),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final imageUrl = (data['imageUrl'] ?? '').toString();
              return Card(
                color: _surface,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF423636),
                    backgroundImage: imageUrl.isEmpty
                        ? null
                        : NetworkImage(imageUrl),
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.person_outline, color: _lightMauve)
                        : null,
                  ),
                  title: Text(
                    (data['name'] ?? 'Doctor').toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${data['specialty'] ?? ''}\n${data['bio'] ?? ''}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted),
                  ),
                  onTap: () =>
                      _DashboardScreenState._openDoctor(context, doc.id, data),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
