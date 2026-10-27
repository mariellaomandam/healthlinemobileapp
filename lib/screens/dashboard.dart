import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/patient_profile.dart';
import '../providers/patient_profile_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _background = Color(0xFF101010);
  static const _surface = Color(0xFF1C1A1A);
  static const _mauve = Color(0xFF806666);
  static const _accent = Color(0xFFFF454D);
  static const _muted = Color(0xFFAAAAAA);

  static const _services = <_ServiceItem>[
    _ServiceItem('Check-up', Icons.medical_services_outlined),
    _ServiceItem('Vaccination', Icons.vaccines_outlined),
    _ServiceItem('Laboratory', Icons.science_outlined),
    _ServiceItem('Dental Care', Icons.health_and_safety_outlined),
  ];

  static const _doctors = <_DoctorItem>[
    _DoctorItem('Dr. John Doe', 'Internal Medicine', '5.0', '123 reviews'),
    _DoctorItem('Dr. Maria Santos', 'Pediatrics', '4.9', '98 reviews'),
    _DoctorItem('Dr. Alex Reyes', 'Cardiology', '4.8', '87 reviews'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Navigation is handled as a side effect of a provider state transition,
    // not while the widget tree is being rendered.
    ref.listen<String?>(dashboardNavigationProvider, (previous, next) {
      if (next == null || next.isEmpty) return;

      ref.read(dashboardNavigationProvider.notifier).clearRoute();
      if (next == '/dashboard') {
        Navigator.pushNamedAndRemoveUntil(context, next, (_) => false);
      } else {
        Navigator.pushNamed(context, next);
      }
    });

    final profile = ref.watch(patientProfileProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    final filteredDoctors = _doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(searchQuery) ||
          doctor.specialty.toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    _DashboardHeader(
                      profile: profile,
                      onProfileTap: () => _requestRoute(ref, '/profile-settings'),
                      onNotificationsTap: () => _requestRoute(ref, '/messages'),
                    ),
                    const SizedBox(height: 28),
                    _GreetingCard(
                      profile: profile,
                      onAppointmentsTap: () => _requestRoute(ref, '/appointments'),
                    ),
                    const SizedBox(height: 22),
                    _DoctorSearch(
                      onChanged: (value) =>
                          ref.read(searchQueryProvider.notifier).updateQuery(value),
                    ),
                    const SizedBox(height: 30),
                    _SectionHeader(
                      title: 'Popular Services',
                      action: 'Explore',
                      onTap: () => _showServiceMessage(context, 'Popular Services'),
                    ),
                    const SizedBox(height: 16),
                    _ServicesList(
                      services: _services,
                      onServiceTap: (service) =>
                          _showServiceMessage(context, service),
                    ),
                    const SizedBox(height: 32),
                    _SectionHeader(
                      title: 'Our Doctors',
                      action: 'View all',
                      onTap: () => _showServiceMessage(context, 'Doctor directory'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Find the right specialist for you',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (filteredDoctors.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No doctors found.',
                            style: TextStyle(color: _muted),
                          ),
                        ),
                      )
                    else
                      _DoctorsList(
                        doctors: filteredDoctors,
                        onDoctorTap: () => _requestRoute(ref, '/messages'),
                      ),
                  ],
                ),
              ),
            ),
            _DashboardBottomNavigation(
              onHomeTap: () => _requestRoute(ref, '/dashboard'),
              onAppointmentsTap: () => _requestRoute(ref, '/appointments'),
              onMessagesTap: () => _requestRoute(ref, '/messages'),
              onSettingsTap: () => _requestRoute(ref, '/profile-settings'),
            ),
          ],
        ),
      ),
    );
  }

  static void _requestRoute(WidgetRef ref, String route) {
    ref.read(dashboardNavigationProvider.notifier).navigateTo(route);
  }

  static void _showServiceMessage(BuildContext context, String service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$service selected'),
        backgroundColor: _mauve,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.profile,
    required this.onProfileTap,
    required this.onNotificationsTap,
  });

  final PatientProfile profile;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: onProfileTap,
            child: _PatientAvatar(profile: profile, size: 48),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onProfileTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your health, our priority',
                    style: TextStyle(color: DashboardScreen._muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          _RoundIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: onNotificationsTap,
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({
    required this.profile,
    required this.onAppointmentsTap,
  });

  final PatientProfile profile;
  final VoidCallback onAppointmentsTap;

  @override
  Widget build(BuildContext context) {
    final firstName = profile.name.trim().split(RegExp(r'\s+')).first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
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
            const Row(
              children: [
                Icon(Icons.favorite_rounded, color: Color(0xFFFFB5B5), size: 17),
                SizedBox(width: 7),
                Text(
                  'HEALTHLINE PH',
                  style: TextStyle(
                    color: Color(0xFFE8D4D4),
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Hello, $firstName!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take care of yourself today.\nYour next step to better health starts here.',
              style: TextStyle(
                color: Color(0xFFE3D7D7),
                height: 1.5,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onAppointmentsTap,
              icon: const Icon(Icons.calendar_month_rounded, size: 16),
              label: const Text('My appointments'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFBCA6A6)),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorSearch extends StatelessWidget {
  const _DoctorSearch({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search doctors or specialties...',
          hintStyle: const TextStyle(color: DashboardScreen._muted, fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: DashboardScreen._muted),
          filled: true,
          fillColor: DashboardScreen._surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: DashboardScreen._mauve),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: const TextStyle(
                color: Color(0xFFD7AAAA),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesList extends StatelessWidget {
  const _ServicesList({required this.services, required this.onServiceTap});

  final List<_ServiceItem> services;
  final ValueChanged<String> onServiceTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 13),
        itemBuilder: (context, index) {
          final service = services[index];
          return GestureDetector(
            onTap: () => onServiceTap(service.name),
            child: Container(
              width: 112,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DashboardScreen._surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: DashboardScreen._mauve.withAlpha(65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      service.icon,
                      color: const Color(0xFFE6CACA),
                      size: 23,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DoctorsList extends StatelessWidget {
  const _DoctorsList({required this.doctors, required this.onDoctorTap});

  final List<_DoctorItem> doctors;
  final VoidCallback onDoctorTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 174,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return GestureDetector(
            onTap: onDoctorTap,
            child: Container(
              width: 245,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: DashboardScreen._surface,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: Colors.white.withAlpha(18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 66,
                    height: 86,
                    decoration: BoxDecoration(
                      color: const Color(0xFF423636),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFFE0CACA),
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          doctor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          doctor.specialty,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: DashboardScreen._muted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFFCA67), size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${doctor.rating} · ${doctor.reviews}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'VIDEO  ·  AUDIO  ·  CHAT',
                          style: TextStyle(
                            color: Color(0xFFE6BDBD),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PatientAvatar extends StatelessWidget {
  const _PatientAvatar({required this.profile, required this.size});

  final PatientProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Uint8List? bytes = profile.photoBytes;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF423636),
      ),
      child: bytes != null
          ? Image.memory(bytes, fit: BoxFit.cover)
          : profile.photoUrl != null && profile.photoUrl!.isNotEmpty
              ? Image.network(
                  profile.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.person_rounded,
                  color: Color(0xFFE6CACA),
                  size: 26,
                ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DashboardScreen._surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _DashboardBottomNavigation extends StatelessWidget {
  const _DashboardBottomNavigation({
    required this.onHomeTap,
    required this.onAppointmentsTap,
    required this.onMessagesTap,
    required this.onSettingsTap,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onAppointmentsTap;
  final VoidCallback onMessagesTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFF211D1D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(18)),
          ),
          child: Row(
            children: [
              _NavigationItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: true,
                onTap: onHomeTap,
              ),
              _NavigationItem(
                icon: Icons.calendar_month_rounded,
                label: 'Schedule',
                onTap: onAppointmentsTap,
              ),
              _NavigationItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                onTap: onMessagesTap,
              ),
              _NavigationItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: onSettingsTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected ? DashboardScreen._accent : DashboardScreen._muted,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : DashboardScreen._muted,
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceItem {
  const _ServiceItem(this.name, this.icon);

  final String name;
  final IconData icon;
}

class _DoctorItem {
  const _DoctorItem(this.name, this.specialty, this.rating, this.reviews);

  final String name;
  final String specialty;
  final String rating;
  final String reviews;
}
