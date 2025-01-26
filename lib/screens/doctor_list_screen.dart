import 'package:flutter/material.dart';
import '../models/doctor.dart';
import 'appointment_booking_screen.dart';

class DoctorListScreen extends StatelessWidget {
  // Hardcoded doctor data
  final List<Doctor> doctors = [
    Doctor(id: '1', name: 'Dr. Alice Smith', specialty: 'Cardiology'),
    Doctor(id: '2', name: 'Dr. John Doe', specialty: 'Neurology'),
    Doctor(id: '3', name: 'Dr. Jane Miller', specialty: 'Dermatology'),
    Doctor(id: '4', name: 'Dr. Michael Brown', specialty: 'Pediatrics'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors')),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return ListTile(
            title: Text(doctor.name),
            subtitle: Text(doctor.specialty),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AppointmentBookingScreen(doctorId: doctor.id),
                  ),
                );
              },
              child: const Text('Book'),
            ),
          );
        },
      ),
    );
  }
}
