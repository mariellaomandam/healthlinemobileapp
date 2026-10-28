class Doctor {
  const Doctor({
    required this.id,
    required this.clinicId,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.active,
    this.imageUrl = '',
  });

  final String id;
  final String clinicId;
  final String name;
  final String specialty;
  final String bio;
  final bool active;
  final String imageUrl;

  factory Doctor.fromMap(String id, Map<String, dynamic> map) => Doctor(
    id: id,
    clinicId: (map['clinicId'] ?? '').toString(),
    name: (map['name'] ?? '').toString(),
    specialty: (map['specialty'] ?? '').toString(),
    bio: (map['bio'] ?? '').toString(),
    active: map['active'] == true,
    imageUrl: (map['imageUrl'] ?? '').toString(),
  );

  Map<String, dynamic> toMap() => {
    'clinicId': clinicId,
    'name': name,
    'specialty': specialty,
    'bio': bio,
    'active': active,
    'imageUrl': imageUrl,
  };
}
