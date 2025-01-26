import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/api_service.dart' as api;
import '../core/auth/auth_exceptions.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<Appointment> appointments = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final response = await api.ApiService().get('/appointments');
      if (mounted) {
        setState(() {
          appointments = (response as List)
              .map((json) => Appointment.fromJson(json))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          String errorMessage = 'Unable to load appointments. Please try again later.';
          
          if (e is AuthException) {
            switch (e.code) {
              case 'unauthorized':
                errorMessage = 'Please log in to view your appointments.';
                break;
              case 'token_expired':
                errorMessage = 'Your session has expired. Please log in again.';
                break;
              case 'network_error':
                errorMessage = 'Network error. Please check your internet connection.';
                break;
            }
          }
          
          error = errorMessage;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : appointments.isEmpty
                  ? const Center(child: Text('No appointments booked yet.'))
                  : RefreshIndicator(
                      onRefresh: _fetchAppointments,
                      child: ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return ListTile(
                            title: Text('Appointment ID: ${appointment.userId}'),
                            subtitle: Text(
                              'Doctor ID: ${appointment.doctorId}\n'
                              'Date: ${appointment.appointmentTime.toLocal()}',
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
