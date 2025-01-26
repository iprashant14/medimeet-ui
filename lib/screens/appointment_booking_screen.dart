import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../providers/auth_provider.dart';
import '../core/auth/auth_exceptions.dart';
import '../core/auth/auth_logger.dart';
import '../services/token_service.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String doctorId;

  const AppointmentBookingScreen({Key? key, required this.doctorId})
      : super(key: key);

  @override
  _AppointmentBookingScreenState createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final _logger = AuthLogger('AppointmentBookingScreen');
  final _tokenService = TokenService();
  final AppointmentService _appointmentService = AppointmentService();
  
  bool _isLoading = false;
  bool _isAppointmentLoading = true;
  List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _fetchAppointments() async {
    if (!mounted) return;  // Early return if widget is not mounted
    
    setState(() {
      _isAppointmentLoading = true;
    });

    try {
      final token = await _getValidToken();
      if (token == null || !mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      if (userId == null) {
        throw AuthException(
          message: 'Unable to identify user. Please log in again',
          code: 'missing_user_id'
        );
      }

      final fetchedAppointments =
          await _appointmentService.getAppointmentsByUserId(userId, token);

      if (!mounted) return;

      setState(() {
        appointments = fetchedAppointments;
        _isAppointmentLoading = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      _showError('Unable to load appointments. Please try again later.');
    }
  }

  Future<void> _bookAppointment() async {
    if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
      _showError('Please fill in both date and time');
      return;
    }

    final date = _dateController.text.trim();
    final time = _timeController.text.trim();
    
    DateTime? appointmentDateTime;
    try {
      appointmentDateTime = DateTime.parse('${date}T$time:00');
    } catch (e) {
      _showError('Invalid date or time format. Please use YYYY-MM-DD for date and HH:MM for time');
      return;
    }

    if (appointmentDateTime.isBefore(DateTime.now())) {
      _showError('Cannot book appointments in the past');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _logger.info('Attempting to book appointment for date: $date, time: $time');
      final token = await _getValidToken();
      
      if (token == null) {
        throw AuthException(
          message: 'Please log in to book appointments',
          code: 'unauthenticated'
        );
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      if (userId == null) {
        throw AuthException(
          message: 'Unable to identify user. Please log in again',
          code: 'missing_user_id'
        );
      }

      final appointment = Appointment(
        doctorId: widget.doctorId,
        userId: userId,
        appointmentTime: appointmentDateTime,
      );

      await _appointmentService.bookAppointment(appointment, token);
      
      if (!mounted) return;

      // Clear the input fields after successful booking
      _dateController.clear();
      _timeController.clear();
      
      await _fetchAppointments();  // Refresh the appointments list
      _showSuccess('Appointment booked successfully');
      _logger.info('Successfully booked appointment for $date $time');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
      _logger.error('Authentication error while booking appointment', e);
      Navigator.of(context).pushReplacementNamed('/login');  // Redirect to login
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Failed to book appointment';
      if (e.toString().contains('already booked')) {
        errorMessage = 'This time slot is already booked. Please choose another time.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      }
      _showError(errorMessage);
      _logger.error('Error booking appointment', e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _getValidToken() async {
    try {
      _logger.info('Checking token validity');
      if (!await _tokenService.isAccessTokenValid()) {
        _logger.info('Token invalid or expired, attempting refresh');
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.refreshAuthToken();
      }
      
      return await _tokenService.getAccessToken();
    } on TokenRefreshException catch (e) {
      _logger.error('Token refresh failed', e);
      return null;
    } catch (e) {
      _logger.error('Error getting valid token', e);
      return null;
    }
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
      appBar: AppBar(title: const Text('Book Appointment')),
      body: _isAppointmentLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book an Appointment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time (HH:MM)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _bookAppointment,
                          child: const Text('Book Appointment'),
                        ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Appointments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  appointments.isEmpty
                      ? const Text('No appointments scheduled')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = appointments[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                title: Text('Doctor ID: ${appointment.doctorId}'),
                                subtitle: Text(
                                  'Date: ${appointment.appointmentTime.toString()}',
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}
