# MediMeet UI Documentation

## Current Implementation

### Technology Stack
- **Framework**: Flutter
- **State Management**: Provider Pattern
- **HTTP Client**: Dio
- **Local Storage**: flutter_secure_storage
- **UI Components**: Material Design
- **Authentication**: Google Sign-In
- **Error Handling**: Custom Exception Handling

### Environment Configuration
```dart
// Required environment variables in .env
GOOGLE_WEB_CLIENT_ID=your_web_client_id
GOOGLE_ANDROID_CLIENT_ID=your_android_client_id
BACKEND_AUTH_ENDPOINT=http://localhost:8080/api/auth
```

### Core Services

1. **API Service** (`api_service.dart`)
   - Base HTTP client configuration
   - API request handling
   - Error handling with custom exceptions
   - Request/Response interceptors

2. **Authentication Service** (`auth_service.dart`)
   - Email/Password login
   - Google Sign-In integration
   - User registration
   - Token management
   - Secure credential storage

3. **Token Service** (`token_service.dart`)
   - JWT token storage
   - Token refresh handling
   - Secure token management
   - Token expiration handling

4. **Doctor Service** (`doctor_service.dart`)
   - Doctor listing with pagination
   - Doctor details with availability
   - Advanced search functionality
   - Specialty filtering

5. **Appointment Service** (`appointment_service.dart`)
   - Smart appointment booking
   - Real-time status updates
   - Appointment history
   - Cancellation handling

### Features

1. **Authentication**
   - Modern login UI with email/password
   - Google Sign-In integration
   - Secure token management
   - Session handling
   - Logout functionality

2. **Doctor Management**
   - Grid/List view toggle
   - Advanced filtering options
   - Availability calendar
   - Rating and reviews

3. **Appointment Handling**
   - Interactive calendar selection
   - Time slot visualization
   - Status tracking
   - Notification integration

### Error Handling

1. **User-Friendly Error Messages**
```dart
try {
  // API call
} on AuthException catch (e) {
  showErrorDialog(context, e.userFriendlyMessage);
} on NetworkException catch (e) {
  showRetryDialog(context, e.message);
}
```

2. **Error Types**
   - Authentication errors
   - Network errors
   - Validation errors
   - Business logic errors

### State Management

1. **Auth Provider**
```dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  AuthStatus _status = AuthStatus.unknown;

  Future<void> signInWithGoogle() async {
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      // Google Sign-In logic
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }
}
```

2. **Appointment Provider**
```dart
class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  
  Future<void> bookAppointment(Appointment appointment) async {
    try {
      // Booking logic
      notifyListeners();
    } catch (e) {
      // Error handling
      rethrow;
    }
  }
}
```

### UI Components

1. **Custom Widgets**
   - `AuthButton`: Reusable authentication button
   - `AppointmentCard`: Appointment display card
   - `DoctorTile`: Doctor information tile
   - `LoadingOverlay`: Loading indicator overlay

2. **Theme Configuration**
```dart
ThemeData(
  primarySwatch: Colors.blue,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    secondary: Colors.teal,
  ),
  textTheme: TextTheme(
    // Custom text styles
  ),
)
```

### Navigation

1. **Route Management**
```dart
final routes = {
  '/': (context) => AuthGuard(child: HomeScreen()),
  '/login': (context) => LoginScreen(),
  '/doctors': (context) => AuthGuard(child: DoctorListScreen()),
  '/appointments': (context) => AuthGuard(child: AppointmentScreen()),
};
```

2. **Navigation Guards**
   - `AuthGuard`: Protects authenticated routes
   - `RoleGuard`: Role-based access control

### Testing

1. **Widget Tests**
```dart
testWidgets('Login screen shows Google Sign-In button',
    (WidgetTester tester) async {
  await tester.pumpWidget(LoginScreen());
  expect(find.byType(GoogleSignInButton), findsOneWidget);
});
```

2. **Integration Tests**
   - Authentication flow
   - Appointment booking flow
   - Error scenarios

### Responsive Design

1. **Screen Adaptations**
   - Mobile-first approach
   - Tablet optimization
   - Web responsive layout

2. **Layout Guidelines**
   - Use `LayoutBuilder` for adaptive layouts
   - Implement different layouts for different screen sizes
   - Follow Material Design guidelines

### Performance Optimization

1. **Image Optimization**
   - Lazy loading
   - Caching
   - Proper image formats

2. **State Management**
   - Minimize rebuilds
   - Use `const` widgets
   - Implement pagination

### Security Guidelines

1. **Secure Storage**
   - Use `flutter_secure_storage` for sensitive data
   - Clear credentials on logout
   - Implement session timeout

2. **API Security**
   - Token-based authentication
   - HTTPS enforcement
   - Input validation

### Accessibility

1. **Features**
   - Screen reader support
   - High contrast mode
   - Adjustable text size

2. **Implementation**
   - Semantic labels
   - WCAG compliance
   - Keyboard navigation

### Project Structure
```
lib/
├── core/
│   ├── auth/           # Authentication logic
│   └── network/        # Network handling
├── models/            # Data models
├── providers/         # State management
├── screens/          # UI screens
├── services/         # API services
└── widgets/          # Reusable widgets
```

## Future Implementations

### Caching Strategy
1. **Local Storage**
   - Hive for local database
   - SQLite for complex queries
   - Cached network images

2. **State Persistence**
   - Hydrated BLoC
   - Persistent provider state
   - Offline data sync

### Testing Strategy

1. **Widget Tests**
   - Screen widget tests
   - Component tests
   - Navigation tests

2. **Integration Tests**
   - User flow tests
   - API integration tests
   - State management tests

3. **Unit Tests**
   - Service layer tests
   - Utility function tests
   - Model tests

### CI/CD Pipeline

1. **Build Automation**
   - GitHub Actions
   - Codemagic
   - Fastlane

2. **Testing Automation**
   - Automated testing
   - Code coverage reports
   - Static analysis

3. **Deployment**
   - App store deployment
   - Play store deployment
   - Beta testing distribution

### Performance Optimization

1. **Image Optimization**
   - Lazy loading
   - Caching
   - Compression

2. **State Management**
   - Efficient provider usage
   - Memory optimization
   - State disposal

3. **Network Optimization**
   - Request caching
   - Batch requests
   - Connection pooling

### Security Enhancements

1. **Data Security**
   - Secure storage
   - Data encryption
   - Certificate pinning

2. **Authentication**
   - 2FA implementation
   - Session management

3. **Code Security**
   - Code obfuscation
   - Root detection
   - SSL pinning

### Accessibility

1. **Screen Readers**
   - TalkBack support
   - VoiceOver support
   - Semantic labels

2. **UI Adaptations**
   - Dynamic text sizing
   - Color contrast
   - Screen rotation support

### Error Handling

1. **Network Errors**
   - Offline mode
   - Retry mechanisms
   - Error messages

2. **User Input Validation**
   - Form validation
   - Input formatting
   - Error feedback

3. **State Error Handling**
   - Error boundaries
   - State recovery
   - Error logging
