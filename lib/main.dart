import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'core/auth/auth_guard.dart';
import 'screens/appointment_booking_screen.dart'; // Added import statement

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'MediMeet',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => AuthGuard(child: HomeScreen()),
          '/book-appointment': (context) => AuthGuard(child: AppointmentBookingScreen()),
          // Add other protected routes here with AuthGuard
        },
      ),
    );
  }
}
