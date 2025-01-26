import 'package:medimeet/models/appointment.dart';

class AppointmentRequest {
  final String userId;
  final String doctorId;
  final DateTime appointmentTime;
  final AppointmentStatus status;

  AppointmentRequest({
    required this.userId,
    required this.doctorId,
    required this.appointmentTime,
    this.status = AppointmentStatus.scheduled,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'doctorId': doctorId,
      'appointmentTime': appointmentTime.toIso8601String(),
      'status': status.toString().split('.').last.toUpperCase(),
    };
  }
}
