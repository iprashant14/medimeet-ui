class Appointment {
  final String userId;
  final String doctorId;
  final DateTime appointmentTime;

  Appointment({
    required this.userId,
    required this.doctorId,
    required this.appointmentTime,
  });

  // From JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      userId: json['userId'],
      doctorId: json['doctorId'],
      appointmentTime: DateTime.parse(json['appointmentTime']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'doctorId': doctorId,
      'appointmentTime': appointmentTime.toIso8601String(),
    };
  }
}
