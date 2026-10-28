class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.description,
    required this.services,
    required this.published,
    this.imageUrl = '',
  });

  final String id;
  final String name;
  final String address;
  final String contact;
  final String description;
  final List<String> services;
  final bool published;
  final String imageUrl;

  factory Clinic.fromMap(String id, Map<String, dynamic> map) => Clinic(
    id: id,
    name: (map['name'] ?? '').toString(),
    address: (map['address'] ?? '').toString(),
    contact: (map['contact'] ?? '').toString(),
    description: (map['description'] ?? '').toString(),
    services: (map['services'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toList(growable: false),
    published: map['published'] == true,
    imageUrl: (map['imageUrl'] ?? '').toString(),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'contact': contact,
    'description': description,
    'services': services,
    'published': published,
    'imageUrl': imageUrl,
  };
}
