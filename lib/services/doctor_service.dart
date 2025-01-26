import '../models/doctor.dart';
import '../services/token_service.dart';
import 'api_service.dart';

class DoctorService {
  final _tokenService = TokenService();
  final _apiService = ApiService();

  Future<List<Doctor>> getAllDoctors() async {
    final token = await _tokenService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated. Please login first.');
    }
    
    _apiService.setHeaders({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    try {
      final response = await _apiService.get('/doctors');

      if (response is List) {
        return response
            .map((json) => Doctor(
                  id: json['id'],
                  name: json['name'],
                  specialty: json['specialty'],
                ))
            .toList();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load doctors: $e');
    }
  }

  Future<Doctor> getDoctorById(String id) async {
    final token = await _tokenService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated. Please login first.');
    }
    
    _apiService.setHeaders({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    try {
      final response = await _apiService.get('/doctors/$id');

      return Doctor(
        id: response['id'],
        name: response['name'],
        specialty: response['specialty'],
      );
    } catch (e) {
      throw Exception('Failed to load doctor: $e');
    }
  }
}
