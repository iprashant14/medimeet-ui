import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../services/appointment_service.dart';
import '../services/doctor_service.dart';
import '../providers/auth_provider.dart';
import '../core/auth/auth_exceptions.dart';
import '../core/auth/auth_logger.dart';
import '../services/token_service.dart';
import '../widgets/custom_app_bar.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final String? doctorId;

  const AppointmentBookingScreen({Key? key, this.doctorId}) : super(key: key);

  @override
  _AppointmentBookingScreenState createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _logger = AuthLogger('AppointmentBookingScreen');
  final _tokenService = TokenService();
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorService _doctorService = DoctorService();
  
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay? _selectedTime;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  // Define available time slots
  final List<TimeOfDay> _availableTimeSlots = [
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 9, minute: 30),
    const TimeOfDay(hour: 10, minute: 0),
    const TimeOfDay(hour: 10, minute: 30),
    const TimeOfDay(hour: 11, minute: 0),
    const TimeOfDay(hour: 11, minute: 30),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 14, minute: 30),
    const TimeOfDay(hour: 15, minute: 0),
    const TimeOfDay(hour: 15, minute: 30),
    const TimeOfDay(hour: 16, minute: 0),
    const TimeOfDay(hour: 16, minute: 30),
  ];
  
  bool _isLoading = false;
  bool _isAppointmentLoading = true;
  List<Appointment> appointments = [];
  Map<String, Doctor> _doctorCache = {};

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
    if (_selectedTime == null) {
      _showError('Please select a time slot');
      return;
    }

    final date = _selectedDay.toString().split(' ')[0];
    final time = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    
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
        doctorId: widget.doctorId ?? '',
        userId: userId,
        appointmentTime: appointmentDateTime,
        status: AppointmentStatus.scheduled,
      );

      await _appointmentService.bookAppointment(appointment.copyWith(id: null), token);
      
      if (!mounted) return;

      // Clear the input fields after successful booking
      setState(() {
        _selectedTime = null;
      });
      
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

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Select Time Slot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availableTimeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = _availableTimeSlots[index];
              final isSelected = _selectedTime != null &&
                  _selectedTime!.hour == timeSlot.hour &&
                  _selectedTime!.minute == timeSlot.minute;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.green : null,
                    foregroundColor: isSelected ? Colors.white : null,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedTime = timeSlot;
                    });
                  },
                  child: Text(_formatTimeOfDay(timeSlot)),
                ),
              );
            },
          ),
        ),
      ],
    );
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

  Future<void> _cancelAppointment(Appointment appointment) async {
    if (appointment.id == null) {
      _showError('Cannot cancel appointment: Invalid appointment ID');
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _getValidToken();
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
          appointments[index] = appointment.copyWith(status: AppointmentStatus.canceled);
        }
      });
      
      await _fetchAppointments();  // Refresh the appointments list
      _showSuccess('Appointment cancelled successfully');
      
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(e.message);
      _logger.error('Authentication error while cancelling appointment', e);
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to cancel appointment');
      _logger.error('Error cancelling appointment', e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Book Appointment',
      ),
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
                  Card(
                    elevation: 2,
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 90)),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeSlots(),
                  const SizedBox(height: 16),
                  if (_selectedTime != null)
                    Text(
                      'Selected Time: ${_formatTimeOfDay(_selectedTime!)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                            return FutureBuilder<Doctor?>(
                              future: _getDoctorDetails(appointment.doctorId),
                              builder: (context, snapshot) {
                                final doctorName = snapshot.data?.name ?? 'Loading...';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  child: ListTile(
                                    title: Text('Dr. $doctorName'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Date: ${appointment.appointmentTime.toString().split('.')[0]}',
                                        ),
                                        Text(
                                          'Status: ${appointment.status.toString().split('.').last}',
                                          style: TextStyle(
                                            color: appointment.status == AppointmentStatus.canceled 
                                              ? Colors.red 
                                              : appointment.status == AppointmentStatus.scheduled 
                                                ? Colors.green 
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: appointment.status == AppointmentStatus.scheduled
                                      ? TextButton(
                                          onPressed: () => _cancelAppointment(appointment),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )
                                      : null,
                                  ),
                                );
                              },
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
    super.dispose();
  }
}
