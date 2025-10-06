# MedGuard - Medicine Verification App

## Description
MedGuard is a Flutter-based mobile application designed to help users verify the authenticity of medicines in Rwanda. The app allows users to scan or manually enter GTIN (Global Trade Item Number) codes to check if medicines are registered with the Rwanda FDA Register, helping combat counterfeit drugs and ensure patient safety.

## GitHub Repository
🔗 **Repository Link**: [https://github.com/aoshingbesan/medguard](https://github.com/aoshingbesan/medguard)

## Demo Video
🎥 **Video Demo**: [Watch MedGuard Demo](https://drive.google.com/file/d/1yEMo3nQ2uCLGWuJtqI4bog-I3mNZqn8W/view?usp=sharing)

*5-10 minute demonstration of MedGuard's features, technical implementation, and user interface.*

## Features
- **Medicine Verification**: Scan or manually enter GTIN codes to verify medicine authenticity
- **Real-time API Integration**: Connects to Rwanda FDA database for verification
- **History Tracking**: Save and view past verification results
- **Verified Pharmacies**: Find and contact verified pharmacies
- **User-friendly Interface**: Clean, intuitive design with proper error handling
- **Offline History**: Local storage of verification history using SharedPreferences

## Technology Stack

### Frontend
- **Framework**: Flutter (Dart)
- **Platform**: iOS, Android
- **State Management**: StatefulWidget
- **Local Storage**: SharedPreferences
- **UI Components**: Material Design
- **HTTP Client**: Dart HTTP package

### Backend
- **API**: FastAPI (Python) with RESTful endpoints
- **Data Format**: JSON
- **Database**: JSON-based product database (expanding to 80+ medicines)
- **Server**: FastAPI server with async support
- **Validation**: Pydantic models for data validation

## Project Structure
```
medguard/
├── frontend/                 # Flutter mobile app
│   ├── lib/
│   │   ├── main.dart        # App entry point
│   │   ├── theme.dart       # App theming
│   │   ├── api.dart         # API integration
│   │   ├── home_screen.dart # Main navigation
│   │   ├── manual_entry_screen.dart # GTIN input
│   │   ├── result_screen.dart # Verification results
│   │   ├── history_screen.dart # Verification history
│   │   ├── history_storage.dart # Local storage
│   │   ├── pharmacies_screen.dart # Pharmacy listings
│   │   ├── scan_screen.dart # Barcode scanning (placeholder)
│   │   └── splash_screen.dart # App splash
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
├── backend/                 # FastAPI server
│   ├── data/
│   │   └── products.json    # Medicine database (80+ medicines)
│   ├── main.py             # FastAPI application
│   ├── requirements.txt    # Python dependencies
│   └── __pycache__/        # Python cache
├── images/
│   └── screenshots/         # App screenshots
├── build/                   # Build artifacts
├── DESIGN.md               # Design documentation
├── TECHNICAL.md            # Technical documentation
├── README.md               # This file
├── pubspec.lock            # Root dependency lock
└── medguard.iml            # IntelliJ project file
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Python 3.8+ (for backend)
- Xcode (for iOS development)
- Android Studio (for Android development)
- Git

### Quick Start

1. **Clone the Repository**
   ```bash
   git clone https://github.com/aoshingbesan/medguard.git
   cd medguard
   ```

2. **Start the Backend Server**
   ```bash
   cd backend
   pip install -r requirements.txt
   python main.py
   ```
   The API will be available at `http://127.0.0.1:8000`

3. **Start the Frontend App**
   ```bash
   # Open a new terminal window
   cd frontend
   flutter pub get
   
   # Run on iOS Simulator
   flutter run -d ios
   
   # Or run on Android Emulator
   flutter run -d android
   ```

### Detailed Setup Instructions

#### Backend Setup

1. **Navigate to Backend Directory**
   ```bash
   cd backend
   ```

2. **Install Python Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Start the FastAPI Server**
   ```bash
   python main.py
   ```

4. **Verify Backend is Running**
   - Open browser and go to `http://127.0.0.1:8000`
   - You should see: `{"message": "Welcome to MedGuard API", "total_products": 15+}`

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

1. **Start Backend First**
   ```bash
   cd backend && python main.py
   ```

2. **Start Frontend in New Terminal**
   ```bash
   cd frontend && flutter run
   ```

3. **Hot Reload**
   - Press `r` in terminal to hot reload
   - Press `R` to hot restart
   - Press `q` to quit

### Build for Production

#### Frontend Build
```bash
cd frontend

# iOS
flutter build ios

# Android
flutter build apk

# Web
flutter build web
```

#### Backend Deployment
```bash
cd backend

# Install production dependencies
pip install -r requirements.txt

# Run with production server (e.g., Gunicorn)
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker
```

## API Integration

The app integrates with a medicine verification API that checks GTIN codes against the Rwanda FDA database:

```dart
// Example API call
final response = await MedGuardApi.verify(gtinCode);
final verified = response['status'] == 'valid';
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

## Deployment Plan

### Phase 1: Development Environment
- ✅ Local development setup
- ✅ iOS Simulator testing
- ✅ Android Emulator testing

### Phase 2: Testing & QA
- [ ] Unit testing implementation
- [ ] Integration testing
- [ ] User acceptance testing
- [ ] Performance optimization

### Phase 2.5: Backend API Expansion
- [ ] **FastAPI Backend Enhancement**
  - [ ] Expand medicine database in line with RFDA database from current ~20 drugs to 80+ validated medicines
  - [ ] Implement comprehensive drug validation system
  - [ ] Add more detailed medicine information (dosage, side effects, interactions)
  - [ ] Add medicine categorization (prescription, OTC, controlled substances)
  - [ ] Implement batch verification for multiple GTINs
  - [ ] Add medicine recall and safety alert system
  - [ ] Create admin panel for database management
  - [ ] Implement API rate limiting and security measures
  - [ ] Add comprehensive logging and monitoring

### Phase 2.6: Barcode Scanning Implementation
- [ ] **Barcode Scanning Feature Development**
  - [ ] Integrate camera functionality using `camera` package
  - [ ] Implement barcode scanning using `mobile_scanner` or `qr_code_scanner`
  - [ ] Add GTIN code detection and validation
  - [ ] Create scanning UI with camera preview
  - [ ] Handle scanning errors and edge cases
  - [ ] Add manual fallback option when scanning fails
  - [ ] Implement scanning history and analytics
  - [ ] Test on multiple device types and camera qualities
  - [ ] Optimize scanning performance and battery usage
  - [ ] Add scanning permissions handling (iOS/Android)

### Phase 3: Production Deployment
- [ ] App Store submission (iOS)
- [ ] Google Play Store submission (Android)
- [ ] Backend API deployment (AWS/Heroku)
- [ ] Database migration to production
- [ ] Monitoring and analytics setup

### Phase 4: Maintenance
- [ ] Regular updates
- [ ] Bug fixes
- [ ] Feature enhancements
- [ ] User feedback integration

## Future Enhancements
- **Expanded Medicine Database** - Currently expanding from ~20 to 80+ validated medicines
  - Comprehensive drug validation system
  - Integration with Rwanda FDA official database
  - Medicine categorization and safety alerts
- **Barcode Scanning Integration** - Currently in development phase
  - Camera-based GTIN scanning functionality
  - Support for multiple barcode formats
  - Real-time scanning with instant verification
- Push notifications for medicine recalls
- Offline verification capabilities
- Multi-language support (Kinyarwanda, French)
- Advanced analytics dashboard
- Enhanced user profiles and preferences
- Integration with pharmacy inventory systems

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contact
- **Developer**: Ademola Oshingbesan
- **Email**: a.oshingbes@alustudent.com

## Acknowledgments
- Rwanda FDA for providing medicine verification data
- Open source community for various packages used