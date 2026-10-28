class Appointment {
  final String id;
  final String clinicName;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String status;

  const Appointment({
    required this.id,
    required this.clinicName,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    this.status = 'upcoming',
  });

  Appointment copyWith({String? status}) {
    return Appointment(
      id: id,
      clinicName: clinicName,
      doctorName: doctorName,
      specialty: specialty,
      dateTime: dateTime,
      status: status ?? this.status,
    );
  }

  bool get isUpcoming =>
      status == 'upcoming' && dateTime.isAfter(DateTime.now());

  bool get isHistory =>
      status == 'completed' ||
      status == 'cancelled' ||
      (status == 'upcoming' && !dateTime.isAfter(DateTime.now()));
}
