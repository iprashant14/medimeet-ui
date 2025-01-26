import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../services/appointment_service.dart';
import '../services/doctor_service.dart';
import '../core/auth/auth_exceptions.dart';
import '../core/auth/auth_logger.dart';
import '../providers/auth_provider.dart';
import '../services/token_service.dart';
import '../widgets/custom_app_bar.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final _logger = AuthLogger('MyAppointmentsScreen');
  final _tokenService = TokenService();
  final _appointmentService = AppointmentService();
  final _doctorService = DoctorService();
  
  List<Appointment> appointments = [];
  bool isLoading = true;
  String? error;
  Map<String, Doctor> _doctorCache = {};

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<Doctor?> _getDoctorDetails(String doctorId) async {
    if (_doctorCache.containsKey(doctorId)) {
      return _doctorCache[doctorId];
    }
    try {
      final doctor = await _doctorService.getDoctorById(doctorId);
      _doctorCache[doctorId] = doctor;
      return doctor;
    } catch (e) {
      _logger.error('Error fetching doctor details', e);
      return null;
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    
    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        throw AuthException(
          message: 'Please log in to view appointments',
          code: 'unauthenticated'
        );
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      
      if (userId == null) {
        throw AuthException(
          message: 'User not authenticated',
          code: 'unauthorized'
        );
      }
      
      final fetchedAppointments = await _appointmentService.getAppointmentsByUserId(userId, token);
      
      if (mounted) {
        setState(() {
          appointments = fetchedAppointments;
          isLoading = false;
        });
      }
    } on AuthException catch (e) {
      _handleError(e);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    if (appointment.id == null) {
      _showError('Cannot cancel appointment: Invalid appointment ID');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = await _tokenService.getAccessToken();
      if (token == null) {
        throw AuthException(
          message: 'Please log in to cancel appointments',
          code: 'unauthenticated'
        );
      }

      await _appointmentService.cancelAppointment(appointment.id, token);
      
      if (!mounted) return;
      
      // Update the appointment status locally
      setState(() {
        final index = appointments.indexWhere((a) => a.id == appointment.id);
        if (index != -1) {
          appointments[index] = appointments[index].copyWith(status: AppointmentStatus.canceled);
        }
      });
      
      await _fetchAppointments();  // Refresh the appointments list
      _showSuccess('Appointment cancelled successfully');
      
    } on AuthException catch (e) {
      _handleError(e);
    } catch (e) {
      _handleError(e);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _handleError(dynamic e) {
    if (!mounted) return;
    
    setState(() {
      String errorMessage;
      if (e is AuthException) {
        switch (e.code) {
          case 'unauthorized':
          case 'unauthenticated':
            errorMessage = 'Please log in to view your appointments.';
            Navigator.of(context).pushReplacementNamed('/login');
            break;
          case 'forbidden':
            errorMessage = 'You do not have permission to view these appointments.';
            break;
          case 'token_expired':
            errorMessage = 'Your session has expired. Please log in again.';
            Navigator.of(context).pushReplacementNamed('/login');
            break;
          default:
            errorMessage = e.message;
        }
      } else {
        errorMessage = 'An unexpected error occurred. Please try again later.';
        _logger.error('Unexpected error', e);
      }
      
      error = errorMessage;
      isLoading = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'My Appointments'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchAppointments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed('/doctors');
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Schedule Appointment',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: appointments.isEmpty
                          ? const Center(
                              child: Text(
                                'No appointments found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchAppointments,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: appointments.length,
                                itemBuilder: (context, index) {
                                  final appointment = appointments[index];
                                  return FutureBuilder<Doctor?>(
                                    future: _getDoctorDetails(appointment.doctorId),
                                    builder: (context, snapshot) {
                                      final doctorName = snapshot.data?.name ?? 'Loading...';
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          title: Text(
                                            'Dr. $doctorName',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              Text(
                                                'Date: ${appointment.appointmentTime.toString().split('.')[0]}',
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Status: ${appointment.status.toString().split('.').last}',
                                                style: TextStyle(
                                                  color: appointment.status == AppointmentStatus.canceled
                                                      ? Colors.red
                                                      : appointment.status == AppointmentStatus.scheduled
                                                          ? Colors.green
                                                          : Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: appointment.status == AppointmentStatus.scheduled
                                              ? TextButton(
                                                  onPressed: () => _cancelAppointment(appointment),
                                                  child: const Text('Cancel'),
                                                )
                                              : null,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}
