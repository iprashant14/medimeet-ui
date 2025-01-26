class Appointment {
  final String? id;
  final String userId;
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialty;
  final DateTime appointmentTime;
  final String status;

  Appointment({
    this.id,
    required this.userId,
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialty,
    required this.appointmentTime,
    required this.status,
  });

  // From JSON
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String?,
      doctorSpecialty: json['doctorSpecialty'] as String?,
      appointmentTime: DateTime.parse(json['appointmentTime'] as String),
      status: json['status'] as String? ?? 'SCHEDULED',
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    final json = {
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'appointmentTime': appointmentTime.toIso8601String(),
      'status': status,
    };
    
    if (id != null) {
      json['id'] = id;
    }
    
    return json;
  }

  // Copy with
  Appointment copyWith({
    String? id,
    String? userId,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    DateTime? appointmentTime,
    String? status,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      status: status ?? this.status,
    );
  }
}
