# MediMeet UI Documentation

## High-Level Design (HLD)

### System Overview
MediMeet is a medical appointment booking application built using Flutter, providing a cross-platform solution for patients to schedule and manage appointments with doctors.

### Architecture
- **Framework**: Flutter (Cross-platform)
- **State Management**: Provider Pattern
- **Architecture Pattern**: MVVM (Model-View-ViewModel)
- **Network Layer**: Dio for HTTP requests
- **Local Storage**: Flutter Secure Storage, Shared Preferences

### Key Components
1. **Authentication Module**
   - Login/Registration
   - Token Management
   - Session Handling

2. **Appointment Management**
   - Appointment Booking
   - Appointment Viewing
   - Appointment Cancellation

3. **Doctor Management**
   - Doctor Listing
   - Doctor Details
   - Doctor Search

4. **User Profile**
   - User Information
   - Preferences Management

### Security Features
- JWT Token Authentication
- Secure Storage for Sensitive Data
- HTTPS Communication
- Input Validation

## Low-Level Design (LLD)

### Directory Structure
```
lib/
├── core/
│   ├── auth/
│   │   ├── auth_exceptions.dart
│   │   └── auth_logger.dart
├── models/
│   ├── appointment.dart
│   ├── doctor.dart
│   └── user.dart
├── providers/
│   └── auth_provider.dart
├── screens/
│   ├── appointment_booking_screen.dart
│   ├── doctor_list_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   └── my_appointments_screen.dart
├── services/
│   ├── api_service.dart
│   ├── appointment_service.dart
│   ├── doctor_service.dart
│   └── token_service.dart
└── widgets/
    └── custom_app_bar.dart
```

### Component Details

#### 1. Models
- **Appointment**: Represents appointment data with status management
- **Doctor**: Contains doctor information and specialties
- **User**: Manages user profile data

#### 2. Services
- **ApiService**: Central service for HTTP communications
- **AppointmentService**: Handles appointment-related operations
- **DoctorService**: Manages doctor-related operations
- **TokenService**: Handles JWT token management

#### 3. Screens
- **AppointmentBookingScreen**: 
  - Calendar-based appointment scheduling
  - Time slot selection
  - Doctor selection
- **DoctorListScreen**: 
  - Displays available doctors
  - Search and filter functionality
- **MyAppointmentsScreen**:
  - Lists user appointments
  - Cancellation functionality
  - Status tracking

#### 4. Providers
- **AuthProvider**: 
  - Manages authentication state
  - Handles token refresh
  - User session management

### Data Flow
1. **Appointment Booking Flow**:
   ```
   User → DoctorListScreen → AppointmentBookingScreen → AppointmentService → Backend
   ```

2. **Authentication Flow**:
   ```
   User → LoginScreen → AuthProvider → TokenService → Backend
   ```

3. **Appointment Management Flow**:
   ```
   User → MyAppointmentsScreen → AppointmentService → Backend
   ```

## Code Documentation

### Key Classes and Methods

#### ApiService
```dart
class ApiService {
  // Handles HTTP requests with authentication
  Future<dynamic> get(String endpoint);
  Future<dynamic> post(String endpoint, {dynamic data});
  Future<dynamic> put(String endpoint, {dynamic data});
  Future<dynamic> delete(String endpoint);
}
```

#### AppointmentService
```dart
class AppointmentService {
  // Books a new appointment
  Future<Appointment> bookAppointment(Appointment appointment, String token);
  
  // Retrieves user appointments
  Future<List<Appointment>> getAppointmentsByUserId(String userId, String token);
  
  // Cancels an existing appointment
  Future<void> cancelAppointment(String appointmentId, String token);
}
```

#### TokenService
```dart
class TokenService {
  // Manages access tokens
  Future<String?> getAccessToken();
  Future<void> setAccessToken(String token);
  Future<bool> isAccessTokenValid();
}
```

### State Management
The application uses Provider pattern for state management:
```dart
class AuthProvider extends ChangeNotifier {
  String? _userId;
  String? _token;
  
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<void> refreshAuthToken();
}
```

### UI Components
- Custom widgets for reusability
- Material Design components
- Responsive layouts
- Error handling and loading states

### Security Implementation
```dart
// Secure storage implementation
final _storage = const FlutterSecureStorage();
await _storage.write(key: 'token', value: token);

// API request with authentication
_dio.options.headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};
```

### Error Handling
The UI handles errors at multiple levels:

1. **Service Layer**
```dart
class AppointmentService {
  Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      final response = await _apiService.get('/appointments/$userId');
      return List<Appointment>.from(
          response.map((json) => Appointment.fromJson(json)));
    } catch (e) {
      throw Exception('Failed to load appointments');
    }
  }
}
```

2. **Screen Level**
```dart
try {
  await _appointmentService.cancelAppointment(appointment.id);
  setState(() {
    appointments[index] = appointment.copyWith(status: 'CANCELLED');
  });
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to cancel appointment'),
      backgroundColor: Colors.red,
    ),
  );
}
```

3. **Widget Level**
- Loading indicators during async operations
- Error messages in SnackBars
- Retry options for failed operations

## Testing Strategy

### Unit Tests
- Service layer tests
- Model tests
- Provider tests

### Widget Tests
- Screen widget tests
- Custom widget tests
- Navigation tests

### Integration Tests
- End-to-end flow tests
- API integration tests
- State management tests

## Performance Considerations

1. **Image Optimization**
   - Lazy loading
   - Caching
   - Compression

2. **State Management**
   - Efficient provider usage
   - Minimal rebuilds
   - Memory management

3. **Network Optimization**
   - Request caching
   - Pagination
   - Debouncing

## Security Considerations

1. **Data Storage**
   - Secure storage for sensitive data
   - Encryption for local storage
   - Token management

2. **Network Security**
   - HTTPS only
   - Certificate pinning
   - Token refresh mechanism

3. **Input Validation**
   - Form validation
   - Data sanitization
   - Error handling

## Deployment Guidelines

1. **Release Preparation**
   - Version management
   - Asset optimization
   - Environment configuration

2. **Build Process**
   - Flutter build commands
   - Platform-specific settings
   - Release signing

3. **Distribution**
   - App store guidelines
   - Release notes
   - Update mechanism
