import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart'; // Import login screen
import 'doctor_list_screen.dart'; // Import DoctorListScreen
import 'my_appointments_screen.dart'; // Import AppointmentListScreen (if it exists)

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Trigger logout in AuthProvider
              Provider.of<AuthProvider>(context, listen: false).logout();
              // Navigate to the LoginScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Home Screen'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to DoctorListScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorListScreen()),
                );
              },
              child: Text('View Doctors'),
            ),
            SizedBox(height: 20), // Add some space
            ElevatedButton(
              onPressed: () {
                // Navigate to AppointmentListScreen (view appointments)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyAppointmentsScreen()),
                );
              },
              child: Text('View Appointments'),
            ),
          ],
        ),
      ),
    );
  }
}
