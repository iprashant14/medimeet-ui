# MediMeet - Medical Appointment Booking App

A Flutter-based mobile application for booking and managing medical appointments.

## Technology Stack

- **Framework**: Flutter
- **State Management**: Provider Pattern
- **HTTP Client**: Dio
- **Local Storage**: flutter_secure_storage
- **UI Components**: Material Design

## Features

- **Authentication**
  - Secure login and registration
  - JWT token management
  - Token refresh handling
  
- **Doctor Management**
  - Browse available doctors
  - Search and filter functionality
  - Doctor profile viewing
  
- **Appointment System**
  - Interactive appointment booking
  - View and manage appointments
  - Appointment status tracking
  
- **User Profile**
  - Profile management
  - Appointment history

## Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Android Studio / Xcode for emulators
- Git

## Project Structure

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

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/iprashant14/medimeet-ui.git
   cd medimeet
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment**
   Create `.env` files for different environments:
   ```
   # .env.development
   API_BASE_URL=http://localhost:8080/api
   ENV=development
   
   # .env.production
   API_BASE_URL=https://api.medimeet.com
   ENV=production
   ```

4. **Run the app**
   ```bash
   # Development
   flutter run --flavor development --target lib/main_development.dart
   
   # Production
   flutter run --flavor production --target lib/main_production.dart
   ```

## Error Handling

The app currently implements error handling for:

### Authentication Errors
- Invalid credentials
- Token expiration
- Token refresh failures
- Unauthenticated access
- Unauthorized access

### Screen-Level Error Handling
- Error state management in screens
- User-friendly error messages
- Navigation handling for auth errors

TODO: Additional error handling to implement:
- [ ] Offline mode handling
- [ ] Comprehensive API response error handling
- [ ] Form validation error handling
- [ ] Network connectivity monitoring
- [ ] Retry mechanisms for failed requests

## Testing Status

The application currently has no implemented test cases. Platform-specific test directories exist for:
- iOS test directory (`ios/RunnerTests/`)
- macOS test directory (`macos/RunnerTests/`)

TODO: Implement comprehensive testing:
- [ ] Widget tests for screens and components
- [ ] Integration tests for user flows
- [ ] Unit tests for services and utilities
- [ ] State management tests

## Future Enhancements

### Caching Strategy
- [ ] Local database implementation (Hive/SQLite)
- [ ] Offline data synchronization
- [ ] Image caching

### Performance Optimization
- [ ] Lazy loading for images
- [ ] Efficient state management
- [ ] Network request optimization

### Security Enhancements
- [ ] Biometric authentication
- [ ] Certificate pinning
- [ ] Secure storage encryption

### CI/CD Pipeline
- [ ] Automated testing
- [ ] Build automation
- [ ] Deployment automation

## Building for Production

### Android
```bash
# Generate keystore
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS \
-keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build APK
flutter build apk --flavor production --target lib/main_production.dart

# Build App Bundle
flutter build appbundle --flavor production --target lib/main_production.dart
```

### iOS
```bash
# Build iOS release
flutter build ios --flavor production --target lib/main_production.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Frontend README

### MediMeet Frontend

A Flutter web application for doctor appointment booking with Google Sign-In authentication.

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Google Cloud Console project with OAuth 2.0 configured

### Local Development Setup

1. **Clone the Repository**
```bash
git clone <repository-url>
cd medimeet
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Configure Environment Variables**

Create `.env` file in the root directory:
```properties
# Backend API
BACKEND_URL=http://localhost:8080/api

# Google OAuth
GOOGLE_WEB_CLIENT_ID=your-google-web-client-id
GOOGLE_ANDROID_CLIENT_ID=your-android-client-id  # If using Android
```

4. **Configure Google Sign-In**
- Go to [Google Cloud Console](https://console.cloud.google.com)
- Create a new project or select existing
- Enable Google Sign-In API
- Create OAuth 2.0 credentials
- Add authorized JavaScript origins:
  - `http://localhost:3000` (development)
  - Your production URL

5. **Run the Application**

For web:
```bash
# Development
flutter run -d chrome --web-port=3000

# Production build
flutter build web
```

For Android:
```bash
flutter run -d android
```

The application will start on `http://localhost:3000` for web development.

### Project Structure
```
lib/
├── main.dart           # Application entry point
├── models/            # Data models
├── providers/         # State management
├── screens/           # UI screens
├── services/          # API services
├── utils/            # Utility functions
└── widgets/          # Reusable widgets
```

### Features

1. **Authentication**
   - Google Sign-In integration
   - Session management
   - Secure token storage

2. **Doctor Management**
   - View doctor listings
   - Search and filter doctors
   - View doctor details

3. **Appointments**
   - Book appointments
   - View upcoming appointments
   - Cancel appointments
   - View appointment history

### State Management

The application uses the Provider pattern for state management:
- `AuthProvider`: Manages authentication state
- `AppointmentProvider`: Manages appointment data
- `DoctorProvider`: Manages doctor listings

### API Integration

All API calls are handled through service classes:
- `AuthService`: Authentication operations
- `DoctorService`: Doctor-related operations
- `AppointmentService`: Appointment operations

### Error Handling

The application implements comprehensive error handling:
- Network errors
- Authentication errors
- Input validation
- User-friendly error messages

### Development Guidelines

1. **Code Style**
   - Follow Flutter/Dart style guide
   - Use meaningful variable and widget names
   - Add comments for complex widgets

2. **Git Workflow**
   - Create feature branches from `develop`
   - Use meaningful commit messages
   - Submit pull requests for review

3. **Testing**
   - Write widget tests
   - Test API integration
   - Verify error handling

### Troubleshooting

1. **Google Sign-In Issues**
   - Verify client IDs in `.env`
   - Check authorized origins in Google Console
   - Clear browser cache if testing web

2. **API Connection Issues**
   - Verify backend URL in `.env`
   - Check if backend server is running
   - Verify network connectivity

3. **Build Issues**
   - Run `flutter clean`
   - Delete build cache
   - Update dependencies
