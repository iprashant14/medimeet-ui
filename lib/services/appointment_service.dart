import '../models/appointment.dart';
import '../core/auth/auth_logger.dart';
import '../models/appointment_request.dart';
import 'api_service.dart';

// Handles all appointment-related operations with the backend
class AppointmentService {
  final ApiService _apiService;
  final _logger = AuthLogger('AppointmentService');

  // Initialize API service
  AppointmentService() : _apiService = ApiService();

  // Book a new appointment with a doctor
  Future<Appointment> bookAppointment(
      Appointment appointment, String token) async {
    try {
      _logger.info('Booking appointment for user: ${appointment.userId}');
      
      final request = AppointmentRequest(
        userId: appointment.userId,
        doctorId: appointment.doctorId,
        appointmentTime: appointment.appointmentTime,
        status: AppointmentStatus.scheduled,
      );

      final response = await _apiService.post(
        '/appointments',
        data: request.toJson(),
        headers: {'Authorization': 'Bearer $token'}
      );

      _logger.info('Successfully booked appointment');
      return Appointment.fromJson(response);
    } catch (e) {
      _logger.error('Error booking appointment', e);
      rethrow;
    }
  }

  // Get list of appointments for a user
  Future<List<Appointment>> getAppointmentsByUserId(
      String userId, String token) async {
    try {
      _logger.info('Fetching appointments for user: $userId');
      
      final response = await _apiService.get(
        '/appointments/user/$userId',
        headers: {'Authorization': 'Bearer $token'}
      );

      final appointments = (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
      
      _logger.info('Successfully fetched ${appointments.length} appointments');
      return appointments;
    } catch (e) {
      _logger.error('Error fetching appointments', e);
      rethrow;
    }
  }

  // Cancel an existing appointment
  Future<void> cancelAppointment(String? appointmentId, String token) async {
    if (appointmentId == null) {
      throw ArgumentError('Appointment ID cannot be null for cancellation');
    }
    
    try {
      _logger.info('Cancelling appointment: $appointmentId');
      
      await _apiService.put(
        '/appointments/$appointmentId/cancel',
        headers: {'Authorization': 'Bearer $token'}
      );

      _logger.info('Successfully cancelled appointment');
    } catch (e) {
      _logger.error('Error cancelling appointment', e);
      rethrow;
    }
  }
}
