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
