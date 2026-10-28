import 'package:flutter/material.dart';
import 'organization_section.dart';

class OrganizationDashboardScreen extends StatelessWidget {
  const OrganizationDashboardScreen({super.key});

  static const background = Color(0xFF101010);
  static const surface = Color(0xFF1C1A1A);
  static const mauve = Color(0xFFB78A9B);
  static const accent = Color(0xFFFF454D);
  static const muted = Color(0xFFAAAAAA);
  static const lightMauve = Color(0xFFE6CACA);

  static const _items = <_AdminItem>[
    _AdminItem('Appointment Requests', Icons.event_note_rounded),
    _AdminItem('Schedule', Icons.calendar_month_rounded),
    _AdminItem('Patients', Icons.people_alt_outlined),
    _AdminItem('Messages', Icons.chat_bubble_outline),
    _AdminItem('Clinic Profile', Icons.local_hospital_outlined),
  ];

  void _open(BuildContext context, _AdminItem item) {
    Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => OrganizationSectionScreen(
        title: item.title,
        subtitle: '',
        icon: item.icon,
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: mauve.withAlpha(45), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.local_hospital_rounded, color: lightMauve, size: 26),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('HealthLine PH', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                SizedBox(height: 3),
                Text('ORGANIZATION PORTAL', style: TextStyle(color: muted, fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w600)),
              ])),
              IconButton(
                tooltip: 'Log out',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                icon: const Icon(Icons.logout_rounded, color: muted),
              ),
            ]),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF624747), Color(0xFF302527)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Welcome back', style: TextStyle(color: lightMauve, fontSize: 12)),
                SizedBox(height: 7),
                Text('Clinic Dashboard', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                SizedBox(height: 7),
                Text('Manage bookings, clinic availability, and patient communication.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
              ]),
            ),
            const SizedBox(height: 18),
            const SizedBox(height: 28),
            const Text('Manage your clinic', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Choose an area to get started.', style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 15),
            ..._items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: _MenuCard(item: item, onTap: () => _open(context, item)),
            )),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _AdminItem {
  final String title;
  final IconData icon;

  const _AdminItem(this.title, this.icon);
}

class _Summary extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color tint;
  const _Summary({required this.label, required this.icon, required this.tint});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(11, 13, 8, 12),
    decoration: BoxDecoration(color: OrganizationDashboardScreen.surface, borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.white.withAlpha(13))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: tint, size: 20),
      const SizedBox(height: 13),
      const Text('—', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: OrganizationDashboardScreen.muted, fontSize: 10)),
    ]),
  );
}

class _MenuCard extends StatelessWidget {
  final _AdminItem item;
  final VoidCallback onTap;
  const _MenuCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: OrganizationDashboardScreen.surface,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(children: [
          Container(
            width: 45, height: 45,
            decoration: BoxDecoration(color: OrganizationDashboardScreen.mauve.withAlpha(42), borderRadius: BorderRadius.circular(14)),
            child: Icon(item.icon, color: OrganizationDashboardScreen.lightMauve, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: OrganizationDashboardScreen.muted),
        ]),
      ),
    ),
  );
}