import 'package:flutter/material.dart';

class OrganizationSectionScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const OrganizationSectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  static const background = Color(0xFF101010);
  static const surface = Color(0xFF1C1A1A);
  static const mauve = Color(0xFFB78A9B);
  static const muted = Color(0xFFAAAAAA);
  static const lightMauve = Color(0xFFE6CACA);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: background,
    appBar: AppBar(backgroundColor: background, foregroundColor: Colors.white, elevation: 0, title: Text(title)),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withAlpha(15))),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: mauve.withAlpha(45), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: lightMauve, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(color: muted, fontSize: 12, height: 1.4)),
          ])),
        ]),
      ),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.construction_rounded, color: mauve, size: 25),
          SizedBox(height: 12),
          Text('Section UI placeholder', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          SizedBox(height: 7),
          Text('This screen is a visual starter. Add the controls and connect it to shared appointment, patient, schedule, or message data before using it with real accounts.',
            style: TextStyle(color: muted, fontSize: 12, height: 1.5)),
        ]),
      ),
    ]),
  );
}
