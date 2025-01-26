# MediMeet - Medical Appointment Booking App

A Flutter-based mobile application for booking and managing medical appointments.

## Features

- **User Authentication**: Secure login and registration system
- **Doctor Directory**: Browse through list of available doctors with their specialties
- **Appointment Booking**: Book appointments with preferred doctors
- **Appointment Management**: View and cancel scheduled appointments
- **Real-time Updates**: Get instant updates on appointment status
- **Doctor Information**: View detailed information about doctors

## Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Android Studio / Xcode for emulators
- Git

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

3. **Set up environment variables**
   Create a `.env` file in the root directory with:
   ```
   API_BASE_URL=http://localhost:8080/api
   ```

4. **Run the app**
   ```bash
   # Run in debug mode
   flutter run

   # Run in release mode
   flutter run --release
   ```

## Project Structure

```
lib/
├── core/          # Core functionality (auth, logging)
├── models/        # Data models
├── providers/     # State management
├── screens/       # UI screens
├── services/      # API services
└── widgets/       # Reusable widgets
```

## Key Dependencies

- **provider**: State management
- **dio**: HTTP client
- **flutter_secure_storage**: Secure storage for tokens
- **table_calendar**: Calendar widget for appointment booking

## Development

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Building for Production
```bash
# Build APK
flutter build apk

# Build iOS
flutter build ios
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Troubleshooting

Common issues and their solutions:

1. **Build Errors**
   - Clean the project: `flutter clean`
   - Get dependencies again: `flutter pub get`

2. **API Connection Issues**
   - Verify API URL in .env file
   - Check if backend server is running
   - Verify network connectivity

## License

This project is licensed under the MIT License - see the LICENSE file for details
