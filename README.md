# MedGuard - Medicine Verification App

## Description
MedGuard is a Flutter-based mobile application designed to help users verify the authenticity of medicines in Rwanda. The app allows users to scan or manually enter GTIN (Global Trade Item Number) codes to check if medicines are registered with the Rwanda FDA Register, helping combat counterfeit drugs and ensure patient safety.

**📱 Distribution Information:** This application will **not** be published on **Google Play Store** or **Apple App Store** due to Rwanda FDA (RFDA) directives. Instead, the app will be distributed directly as an installation package (APK for Android, IPA for iOS) to comply with regulatory requirements. The app enables healthcare professionals and consumers to verify medicine authenticity directly from their mobile devices, ensuring compliance with regulatory requirements for medicine verification tools.

[APK HERE---->>](https://drive.google.com/file/d/183lva-N0j7wjr-23GvfZt3vYiHJKNmU-/view?usp=sharing)

## GitHub Repository
🔗 **Repository Link**: [https://github.com/aoshingbesan/medguard](https://github.com/aoshingbesan/medguard)

## 📺 Demo Video (5 Minutes)
🎥 **Watch MedGuard Demo Video**: [Click here to watch](https://drive.google.com/file/d/1yEMo3nQ2uCLGWuJtqI4bog-I3mNZqn8W/view?usp=sharing)


## Features
- **Barcode Scanning**: Advanced GTIN barcode scanning with camera integration
- **Manual GTIN Entry**: Direct GTIN code input for verification
- **Hybrid Online/Offline Verification**: Smart fallback system for network reliability
- **Multi-language Support**: English, French, and Kinyarwanda localization
- **Cloud API Integration**: Connects to cloud database (Supabase) for verification
- **Offline Database**: SQLite-based offline medicine storage and verification
- **History Tracking**: Save and view past verification results with detailed information
- **Verified Pharmacies**: Find and contact verified licensed wholesale pharmacies in Rwanda with Google Maps integration
- **RFDA Reporting**: Report unverified drugs to Rwanda FDA with location and photo
- **Settings & Preferences**: Language selection, offline mode management, and connection status
- **User-friendly Interface**: Clean, intuitive design with proper error handling

## Technology Stack

### Frontend
- **Framework**: Flutter (Dart)
- **Platform**: iOS, Android
- **State Management**: StatefulWidget + Provider
- **Local Storage**: SharedPreferences + SQLite (sqflite)
- **UI Components**: Material Design
- **HTTP Client**: Dart HTTP package
- **Barcode Scanning**: mobile_scanner package
- **Localization**: Custom SimpleLanguageService
- **Database**: SQLite for offline storage

### Key Dependencies
- **`mobile_scanner`**: Advanced barcode scanning with camera integration
- **`sqflite`**: SQLite database for offline medicine storage
- **`provider`**: State management for language switching
- **`shared_preferences`**: User preferences and settings storage
- **`supabase_flutter`**: Supabase integration for backend services
- **`flutter_dotenv`**: Environment variables for secure credential management
- **`url_launcher`**: Opening external URLs (Google Maps, etc.)
- **`intl`**: Internationalization support

### Backend
- **Database**: Supabase (PostgreSQL) - cloud-hosted
- **Authentication**: Supabase Auth (if needed)
- **Real-time**: Supabase Realtime subscriptions (if needed)

## Project Structure
```
medguard/
├── frontend/                 # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart                    # App entry point
│   │   ├── theme.dart                  # App theming
│   │   ├── api.dart                      # Hybrid API service (online/offline)
│   │   ├── home_screen.dart            # Main navigation
│   │   ├── manual_entry_screen.dart    # Manual GTIN input
│   │   ├── result_screen.dart          # Verification results
│   │   ├── history_screen.dart         # Verification history
│   │   ├── history_storage.dart        # History storage
│   │   ├── pharmacies_screen.dart      # Pharmacy listings
│   │   ├── rfda_report_screen.dart     # RFDA reporting for unverified drugs
│   │   ├── settings_screen.dart       # Settings & preferences
│   │   ├── splash_screen.dart         # App splash
│   │   ├── offline_database.dart      # SQLite offline database
│   │   ├── simple_language_service.dart # Multi-language support
│   │   └── gtin_scanner/              # Barcode scanning module
│   │       ├── gtin_scanner.dart       # Main scanner widget
│   │       ├── models/
│   │       │   └── gtin_scan_result.dart
│   │       ├── services/
│   │       │   ├── gtin_parser.dart    # GTIN parsing logic
│   │       │   └── gtin_validator.dart # GTIN validation
│   │       └── widgets/
│   │           ├── gtin_scanner_page.dart
│   │           └── manual_entry_sheet.dart
│   ├── assets/
│   │   └── images/          # App assets
│   ├── android/             # Android configuration
│   ├── ios/                 # iOS configuration
│   ├── macos/               # macOS configuration
│   ├── linux/               # Linux configuration
│   ├── windows/             # Windows configuration
│   ├── web/                 # Web configuration
│   ├── test/                # Unit tests
│   ├── pubspec.yaml         # Dependencies
│   └── pubspec.lock         # Dependency lock file
├── images/
│   └── App screenshots/     # App screenshots
├── build/                   # Build artifacts
├── DESIGN.md               # Design documentation
├── TECHNICAL.md            # Technical documentation
├── CLEANUP_SUMMARY.md      # Codebase cleanup documentation
├── README.md               # This file
├── pubspec.lock            # Root dependency lock
└── medguard.iml            # IntelliJ project file
```

## 🚀 How to Install and Run the App

### Prerequisites

**Required Software:**
- **Flutter SDK** (3.0 or higher) - [Download Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (comes with Flutter)
- **Git** - [Download Git](https://git-scm.com/downloads)

**For iOS Development:**
- macOS with **Xcode** installed
- **CocoaPods** (install via: `sudo gem install cocoapods`)

**For Android Development:**
- **Android Studio** - [Download Android Studio](https://developer.android.com/studio)
- **Android SDK** (installed via Android Studio)
- **Java Development Kit (JDK)**

### 📋 Step-by-Step Installation Instructions

#### Step 1: Clone the Repository

```bash
git clone https://github.com/aoshingbesan/medguard.git
cd medguard
```

#### Step 2: Install Flutter Dependencies

**For macOS/Linux:**
```bash
# Navigate to frontend directory
cd frontend

# Install Flutter dependencies
flutter pub get

# Verify Flutter setup
flutter doctor
```

**For Windows:**
```bash
# Navigate to frontend directory
cd frontend

# Install Flutter dependencies
flutter pub get

# Verify Flutter setup
flutter doctor
```

#### Step 3: Configure Environment Variables (Optional)

If you want to use your own Supabase database:
```bash
# Create .env file in frontend directory
cd frontend
touch .env

# Add your Supabase credentials to .env file
# SUPABASE_URL=https://your-project.supabase.co
# SUPABASE_ANON_KEY=your-anon-key-here
```

**Note:** The app works with the default Supabase configuration. See `frontend/README_ENV.md` for detailed instructions.

#### Step 4: Run the App

**Option 1: iOS Simulator (macOS only)**
```bash
# Navigate to frontend directory
cd frontend

# Install iOS dependencies
cd ios
pod install
cd ..

# Run on iOS Simulator
flutter run -d ios
```

**Option 2: Android Emulator**
```bash
# Navigate to frontend directory
cd frontend

# Check available devices
flutter devices

# Run on Android Emulator (start emulator first from Android Studio)
flutter run -d android
```

**Option 3: Physical Device**
```bash
# For iOS: Connect iPhone via USB, trust computer, then:
cd frontend
flutter run -d ios

# For Android: Enable USB debugging, connect device, then:
cd frontend
flutter run -d android
```

### ⚡ Quick Start Summary

```bash
# 1. Clone the repository
git clone https://github.com/aoshingbesan/medguard.git
cd medguard

# 2. Install dependencies and run
cd frontend
flutter pub get
flutter run
```

### Detailed Setup Instructions

#### Frontend Setup

1. **Navigate to Frontend Directory**
   ```bash
   cd frontend
   ```

2. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

3. **Check Available Devices**
   ```bash
   flutter devices
   ```

4. **Run the Application**
   ```bash
   # For iOS Simulator
   flutter run -d ios
   
   # For Android Emulator
   flutter run -d android
   
   # For specific device (use device ID from flutter devices)
   flutter run -d [device-id]
   
   # For web (development only)
   flutter run -d chrome
   ```

### Development Workflow

1. **Start Frontend**
   ```bash
   cd frontend && flutter run
   ```

2. **Hot Reload**
   - Press `r` in terminal to hot reload
   - Press `R` to hot restart
   - Press `q` to quit

### Build for Production

#### Android APK Build (For Distribution)

```bash
cd frontend

# Build release APK (recommended for distribution)
flutter build apk --release

# The APK will be located at:
# frontend/build/app/outputs/flutter-apk/app-release.apk

# To install on device:
# Option 1: Via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Option 2: Transfer to device manually and install
```

**APK File Details:**
- **Location:** `frontend/build/app/outputs/flutter-apk/app-release.apk`
- **Size:** ~20-30MB
- **Minimum Android:** Android 5.0 (API level 21)

#### iOS Build (For Distribution)

```bash
cd frontend

# Install iOS dependencies
cd ios
pod install
cd ..

# Build for iOS (requires macOS and Xcode)
flutter build ios --release

# Then open in Xcode for distribution:
open ios/Runner.xcworkspace
# In Xcode: Product → Archive → Distribute App
```

#### Database Configuration

**Database:**
- Cloud-hosted PostgreSQL database
- All data is stored and managed through the database dashboard

**See `DEPLOYMENT.md` for detailed deployment instructions.**

## API Integration

The app uses a hybrid API system that provides both online and offline verification:

```dart
// Smart hybrid verification (online/offline)
final response = await Api.verify(gtinCode);
final verified = response['status'] == 'valid';

// Offline mode with SQLite database
final offlineResponse = await Api.verifyOffline(gtinCode);

// Online mode with Supabase
final onlineResponse = await Api.verifyOnline(gtinCode);
```

## Database Schema

### Medicine Data Structure (API Response)
```json
{
  "status": "valid",
  "gtin": "8904159162031",
  "product_name": "ILET B2",
  "brand": "ILET B2",
  "generic_name": "Glimepiride, Metformin HCl",
  "manufacturer": {
    "name": "MSN LABORATORIES PRIVATE LIMITED",
    "country": "India"
  },
  "country": "India",
  "rfda_reg_no": "Rwanda FDA-HMP-MA-0033",
  "registration_date": "2020-09-07",
  "license_expiry_date": "2025-09-07",
  "dosage_form": "Tablets",
  "strength": "2mg, 500mg",
  "pack_size": "Box Of 10, Box Of 30",
  "batch": "N/A",
  "mfg_date": "N/A",
  "expiry": "2025-09-07",
  "shelf_life": "24 Months",
  "packaging_type": "ALU-PVC/PVDC BLISTER PACK",
  "marketing_authorization_holder": "MSN LABORATORIES PRIVATE LIMITED",
  "local_technical_representative": "ABACUS PHARMA (A) LTD"
}
```

### History Storage
```dart
class HistoryItemDTO {
  final String brand;
  final String gtin;
  final String? lot;
  final bool verified;
  final DateTime scannedAt;
}
```

### Verified & Licensed Pharmacies Directory

#### Overview

MedGuard includes a comprehensive directory of **licensed wholesale pharmacies in Rwanda** verified and approved by Rwanda FDA. All pharmacies in the database are:

- ✅ **Licensed** by Rwanda FDA
- ✅ **Verified** and active
- ✅ **Wholesale pharmacies** approved for medicine distribution
- 📍 **Geographically mapped** with location data (latitude, longitude)
- 📞 **Contact information** included (phone, email, address)
- 🗺️ **Google Maps integration** for directions

#### Pharmacy Database

**Data Source:**
The pharmacy database contains **licensed wholesale pharmacies registered with Rwanda FDA for 2024**. The complete list is dynamically loaded from the Supabase cloud database and includes:

- **100+ verified pharmacies** across Rwanda
- **Location data** (district, sector, cell, coordinates)
- **Contact information** (phone, email, physical address)
- **Google Maps links** for easy navigation
- **Search functionality** by name, district, sector, or location

#### Pharmacy Information Fields

Each pharmacy in the directory includes:

| Field | Description |
|-------|-------------|
| **Name** | Official pharmacy name |
| **Address** | Complete physical address |
| **District** | District location |
| **Sector** | Sector within district |
| **Cell** | Cell within sector |
| **Phone** | Contact phone number |
| **Email** | Contact email address |
| **Coordinates** | Latitude and longitude |
| **Google Maps Link** | Direct link to Google Maps for navigation |

#### How to Access Pharmacies in the App

1. **Open MedGuard app**
2. **Navigate to Pharmacies tab** (bottom navigation - pharmacy icon)
3. **Browse the complete list** of verified pharmacies
4. **Use the search bar** to find pharmacies by:
   - Pharmacy name
   - District name
   - Sector name
   - Address keywords
5. **Tap any pharmacy** to view detailed information
6. **Use "Get Directions" button** to open Google Maps navigation

#### Pharmacy Features

- **Pull-to-refresh**: Refresh the pharmacy list to get the latest data
- **Search functionality**: Real-time search across all pharmacy fields
- **Location services**: View pharmacies on Google Maps with one tap
- **Contact information**: Call, email, or get directions directly from the app
- **Multi-language support**: All pharmacy information displayed in English, French, or Kinyarwanda

#### Compliance & Verification

**RFDA Compliance:**
All pharmacies in the MedGuard directory are:
- Licensed by Rwanda FDA
- Verified as active wholesale pharmacies
- Regularly updated to reflect current licensing status
- Maintained in compliance with Rwanda FDA regulations

**Data Accuracy:**
- Pharmacy data is sourced from official Rwanda FDA records
- Database is regularly synchronized with updated licensing information
- Users can verify pharmacy status through the app

**Note:** The pharmacy database is maintained in compliance with Rwanda FDA regulations and is regularly updated to reflect the current list of licensed wholesale pharmacies. This ensures users can confidently identify and contact verified pharmacies for authentic medicines.

## Deployment Plan

### Phase 1: Development Environment
- ✅ Local development setup
- ✅ iOS Simulator testing
- ✅ Android Emulator testing

### Phase 2: Testing & QA
- [x] Unit testing implementation (GTIN parser, validator tests) ✅ COMPLETED
- [x] Integration testing ✅ COMPLETED
- [x] Performance optimization ✅ COMPLETED

### Phase 2.5: Supabase Integration
- [x] **Supabase Integration** ✅ COMPLETED
  - [x] Cloud-hosted PostgreSQL database setup
  - [x] Medicine database with detailed product information
  - [x] Comprehensive drug validation system
  - [x] Pharmacy database with location data and Google Maps integration
  - [x] Secure API integration with environment variables
  - [x] Database connection testing and status monitoring

### Phase 2.6: Barcode Scanning Implementation
- [x] **Barcode Scanning Feature Development** ✅ COMPLETED
  - [x] Integrate camera functionality using `mobile_scanner` package
  - [x] Implement barcode scanning with GTIN detection
  - [x] Add GTIN code detection and validation
  - [x] Create scanning UI with camera preview
  - [x] Handle scanning errors and edge cases
  - [x] Add manual fallback option when scanning fails
  - [x] Implement scanning history and analytics
  - [x] Test on multiple device types and camera qualities
  - [x] Optimize scanning performance and battery usage
  - [x] Add scanning permissions handling (iOS/Android)

### Phase 3: Production Deployment
- [x] Cloud database (Supabase) ✅ COMPLETED
- [x] Android APK build and distribution ✅ COMPLETED
- [x] iOS build configuration ✅ COMPLETED
- Production deployment ready (Direct distribution via APK/IPA due to RFDA directives)

### Phase 4: Maintenance & Future Enhancements
- Continuous improvement and feature updates
- Bug fixes and performance optimizations

## App Architecture

### **Hybrid API System**
The app uses a sophisticated hybrid API system that automatically switches between online and offline modes:

```dart
// Smart verification flow
static Future<Map<String, dynamic>> verify(String gtin) async {
  final isOfflineMode = await OfflineDatabase.isOfflineModeEnabled();
  
  if (isOfflineMode) {
    return await verifyOffline(gtin);  // Offline-first
  }

  final isOnline = await Api.isOnline();
  if (isOnline) {
    final result = await verifyOnline(gtin);
    if (result['status'] == 'valid' || result['status'] == 'warning') {
      return result;  // Online success
    }
  }

  return await verifyOffline(gtin);  // Fallback to offline
}
```

### **Multi-language Support**
Custom language service supporting 3 languages with easy expansion:

```dart
// Simple language switching
String get home {
  switch (_currentLanguage) {
    case AppLanguage.english: return 'Home';
    case AppLanguage.french: return 'Accueil';
    case AppLanguage.kinyarwanda: return 'Urugo';
  }
}
```

### **Offline Database**
SQLite-based offline storage with automatic synchronization:

- **Automatic sync** when online
- **Offline verification** when network unavailable
- **Data persistence** across app sessions
- **Smart fallback** system

## Current Status & Completed Features

### ✅ **Implemented Features**
- **Barcode Scanning**: Advanced GTIN scanning with camera integration using mobile_scanner package
- **Manual GTIN Entry**: Direct GTIN code input with validation (13 or 14 digits)
- **Hybrid Online/Offline Verification**: Smart fallback system that automatically switches between online (Supabase) and offline (SQLite) modes
- **Multi-language Support**: Full localization in English, French, and Kinyarwanda across all screens
- **Cloud API Integration**: Supabase integration for real-time database queries
- **Offline Database**: SQLite-based offline medicine storage with automatic synchronization
- **History Tracking**: Save and view past verification results with detailed information and search capability
- **Verified Pharmacies**: Browse verified pharmacies with location data, contact information, and Google Maps directions
- **RFDA Reporting**: Report unverified drugs to Rwanda FDA with location, photo, and detailed information via email
- **Settings & Preferences**: Language selection, offline mode toggle, database statistics, connection status, and data management
- **Splash Screen**: Branded splash screen with 5-second display duration
- **Result Screen**: Detailed verification results showing product information, manufacturer details, and safety recommendations

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📚 Related Files and Project Documentation

This section contains all related files and documentation for the MedGuard project.

### Core Project Files
- **`README.md`** - This file: Main project documentation with installation and usage instructions
- **`pubspec.yaml`** - Flutter project dependencies and configuration
- **`frontend/`** - Flutter mobile application source code
- **`images/App screenshots/`** - Application screenshots and visual documentation

### Submission & Analysis Documents
- 📊 **[TESTING_RESULTS.md](TESTING_RESULTS.md)** - Comprehensive testing results, screenshots, and performance metrics
  - Unit tests (35+ test cases)
  - Integration tests (24 scenarios)
  - Performance testing on multiple devices
  - Screenshots and test evidence
  
- 📈 **[ANALYSIS.md](ANALYSIS.md)** - Detailed analysis of results and objectives achievement
  - Objectives achievement analysis (99% completion rate)
  - Comparison with project proposal
  - Technical implementation review
  
- 💬 **[DISCUSSION.md](DISCUSSION.md)** - Discussion on milestones importance and results impact
  - Supervisor discussions
  - Milestone importance analysis
  - Community impact discussion
  
- 💡 **[RECOMMENDATIONS.md](RECOMMENDATIONS.md)** - Recommendations for community application and future work
  - Recommendations to healthcare professionals
  - Future enhancement suggestions
  - Community application guidelines

### Deployment & Technical Documentation
- 🚀 **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete deployment documentation and build instructions
  - Database configuration (Supabase)
  - Android APK build instructions
  - iOS build instructions
  - Deployment verification steps
  
- 🔧 **[TECHNICAL.md](TECHNICAL.md)** - Technical architecture and implementation details
  - Frontend architecture
  - Database schema (Supabase)
  - API integration examples
  - Code structure and organization
  
- 🎨 **[DESIGN.md](DESIGN.md)** - Design documentation and UI/UX guidelines
  - Color scheme and typography
  - Component design patterns
  - User interface guidelines

### Additional Documentation
- 🎥 **[VIDEO_DEMO_SCRIPT.md](VIDEO_DEMO_SCRIPT.md)** - 5-minute video demo script guide
  - Step-by-step demo script
  - Core functionalities focus
  - Production tips and guidelines

- 📋 **[SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md)** - Complete submission checklist
  - Repository requirements
  - Documentation checklist
  - Testing verification

- 📝 **[frontend/README.md](frontend/README.md)** - Frontend-specific documentation
  - Flutter app architecture
  - Frontend features and components
  - Frontend development guide

- 🔐 **[frontend/README_ENV.md](frontend/README_ENV.md)** - Environment variables setup guide
  - Supabase credentials configuration
  - .env file setup instructions
  - Security best practices

## 📦 Installation Package / Deployed Version

### Android APK - Download & Install

**Pre-built APK Available:**
📦 **Download Android APK** (Release Build):
- **APK File Location**: `frontend/build/app/outputs/flutter-apk/app-release.apk`
- **File Size**: ~67MB
- **Minimum Android Version**: Android 5.0 (API level 21)
- **Build Type**: Release (optimized for production)

**To Build APK Yourself:**
```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --release
# APK will be created at: build/app/outputs/flutter-apk/app-release.apk
```

**Installation Instructions:**
1. **Via ADB (Android Debug Bridge):**
   ```bash
   adb install frontend/build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Manual Installation:**
   - Transfer the APK file to your Android device
   - Enable "Install from Unknown Sources" in device settings
   - Open the APK file and follow installation prompts

### iOS Build

🍎 **iOS Build:** Requires macOS and Xcode:
```bash
cd frontend
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode for distribution
```

### 📱 Distribution Information

**Important Note:** MedGuard will **NOT** be published on **Google Play Store** or **Apple App Store** due to Rwanda FDA (RFDA) directives. The app will be distributed directly via installation packages to comply with regulatory requirements for medicine verification systems.

**Distribution Method:**
- ✅ **Android APK**: Production-ready release build available for direct distribution
- ✅ **iOS Build**: Production-ready build configuration completed (IPA for direct distribution)
- ❌ **Google Play Store**: Not published (per RFDA directives)
- ❌ **Apple App Store**: Not published (per RFDA directives)

**RFDA Compliance:**
This application has been developed in accordance with Rwanda FDA directives for medicine verification systems. Due to regulatory requirements:

- **Direct Distribution**: The app is distributed directly as an APK (Android) or IPA (iOS) installation package
- **RFDA Compliance**: Distribution method complies with Rwanda FDA directives for medicine verification applications
- **Accessibility**: Direct distribution ensures healthcare professionals and consumers in Rwanda can access the app while maintaining compliance with regulatory requirements
- **Official Distribution**: APK/IPA packages serve as the official distribution channel for verified medicine authenticity checking

**Installation:**
- **Android**: Install APK file directly on Android devices
- **iOS**: Install IPA file through enterprise distribution or TestFlight (for authorized users)

**Note:** This distribution method is intentional and complies with Rwanda FDA directives for medicine verification systems. The app is fully functional and ready for distribution via direct installation packages.

### Backend/Database
🌐 **Database:** Cloud-hosted PostgreSQL database (Supabase)
- See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions
- No local server needed - all data accessed via cloud API

## Testing

### Running Tests
```bash
cd frontend

# Run all tests
flutter test

# Run specific test file
flutter test test/gtin_parser_test.dart
flutter test test/gtin_validator_test.dart
```

### Test Coverage
- **Unit Tests:** 35+ test cases (GTIN parser, validator)
- **Integration Tests:** 24 test scenarios (API, database, UI)
- **See [TESTING_RESULTS.md](TESTING_RESULTS.md) for complete test results**

## Troubleshooting

### Common Issues

**Issue: Database connection errors**
- **Solution:** Verify your database is active and accessible
- **Solution:** Check that required tables (`products`, `pharmacies`) exist and have data

**Issue: Flutter dependencies fail to install**
- **Solution:** Run `flutter clean` then `flutter pub get`
- **Solution:** Verify Flutter installation: `flutter doctor`

**Issue: iOS build fails**
- **Solution:** Run `cd ios && pod install` before building
- **Solution:** Verify Xcode and CocoaPods installation

**Issue: Android build fails**
- **Solution:** Verify Android SDK installation
- **Solution:** Check `ANDROID_HOME` environment variable
- **Solution:** Run `flutter doctor` to check Android setup

**For more troubleshooting:** See [DEPLOYMENT.md](DEPLOYMENT.md)

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contact
- **Developer**: Ademola Oshingbesan
- **Email**: a.oshingbes@alustudent.com

## Acknowledgments
- Rwanda FDA for providing medicine verification data
- Open source community for various packages used