import '../models/appointment.dart';
import '../core/auth/auth_logger.dart';
import 'api_service.dart';

class AppointmentService {
  final ApiService _apiService;
  final _logger = AuthLogger('AppointmentService');

  AppointmentService() : _apiService = ApiService();

  Future<Appointment> bookAppointment(
      Appointment appointment, String token) async {
    try {
      _logger.info('Booking appointment for user: ${appointment.userId}');
      
      final response = await _apiService.post(
        '/appointments',
        data: appointment.toJson(),
        headers: {'Authorization': 'Bearer $token'}
      );

      _logger.info('Successfully booked appointment');
      return Appointment.fromJson(response);
    } catch (e) {
      _logger.error('Error booking appointment', e);
      rethrow;  // Let the error be handled by the UI layer
    }
  }

  Future<List<Appointment>> getAppointmentsByUserId(
      String userId, String token) async {
    try {
      _logger.info('Fetching appointments for user: $userId');
      
      final response = await _apiService.get(
        '/appointments/$userId',
        headers: {'Authorization': 'Bearer $token'}
      );

      final appointments = (response as List)
          .map((json) => Appointment.fromJson(json))
          .toList();
      
      _logger.info('Successfully fetched ${appointments.length} appointments');
      return appointments;
    } catch (e) {
      _logger.error('Error fetching appointments', e);
      rethrow;  // Let the error be handled by the UI layer
    }
  }

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
      rethrow;  // Let the error be handled by the UI layer
    }
  }
}
