import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'core/auth/auth_guard.dart';
import 'screens/appointment_booking_screen.dart';
import 'screens/doctor_list_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Configure web platform
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
    try {
      await GoogleSignIn().signInSilently();
    } catch (e) {
      print('Error initializing Google Sign In: $e');
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'MediMeet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: FutureBuilder(
                future: Future.delayed(Duration(milliseconds: 100)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return LoginScreen();
                },
              ),
            );
          },
        ),
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => AuthGuard(child: HomeScreen()),
          '/book-appointment': (context) =>
              AuthGuard(child: AppointmentBookingScreen()),
          '/doctors': (context) => AuthGuard(child: DoctorListScreen()),
        },
      ),
    );
  }
}
