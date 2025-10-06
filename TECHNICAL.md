# MedGuard - Technical Documentation

## Frontend Development

### Architecture Overview
MedGuard is built using Flutter's widget-based architecture with a focus on:
- **Modular Design**: Each screen is a separate widget
- **State Management**: StatefulWidget for local state
- **Separation of Concerns**: API logic separated from UI logic
- **Reusable Components**: Custom widgets for consistent UI

### Current Implementation Status
- **✅ Manual GTIN Entry**: Fully functional with real-time verification
- **🚧 Barcode Scanning**: Currently in development phase
  - Camera integration planned using `mobile_scanner` package
  - GTIN detection and validation in progress
  - Scanning UI and error handling to be implemented

### Key Frontend Code Examples

#### 1. API Integration
```dart
// lib/api.dart
class MedGuardApi {
  static const String baseUrl = 'https://api.medguard.rw';
  
  static Future<Map<String, dynamic>> verify(String gtin) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verify/$gtin'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify medicine');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
```

#### 2. Local Storage Implementation
```dart
// lib/history_storage.dart
class HistoryStorage {
  static const String _key = 'medguard_history_v1';
  
  static Future<void> add(HistoryItemDTO item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    list.insert(0, jsonEncode(item.toMap()));
    await prefs.setStringList(_key, list);
  }
  
  static Future<List<HistoryItemDTO>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    return list
        .map((s) => jsonDecode(s))
        .whereType<Map<String, dynamic>>()
        .map(HistoryItemDTO.fromMap)
        .toList();
  }
}
```

#### 3. Responsive Design Implementation
```dart
// lib/result_screen.dart
class ResultScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Status icon with proper sizing
              Icon(
                widget.verified ? Icons.verified_rounded : Icons.error_outline_rounded,
                color: iconColor,
                size: 64,
              ),
              // Responsive text with proper scaling
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              // Scrollable content area
              if (!widget.verified) ...[
                _InfoCard(
                  title: 'Important Notice',
                  child: Column(/* content */),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 4. DOM Manipulation (Flutter Equivalent)
```dart
// Dynamic UI updates based on state
class _ManualEntryScreenState extends State<ManualEntryScreen> {
  bool _loading = false;
  String? _error;
  
  Future<void> _submit() async {
    setState(() { 
      _loading = true; 
      _error = null; 
    });
    
    try {
      final result = await MedGuardApi.verify(_controller.text);
      // Update UI based on result
      setState(() {
        _loading = false;
        // Navigate to result screen
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }
}
```

### Frontend Development Skills Demonstrated
- **Widget Composition**: Building complex UIs from simple widgets
- **State Management**: Managing local state with StatefulWidget
- **API Integration**: HTTP requests and JSON parsing
- **Local Storage**: Persistent data storage with SharedPreferences
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Error Handling**: Graceful error handling and user feedback
- **Navigation**: Screen transitions and data passing

## Backend Development

### API Architecture
The backend provides RESTful API endpoints for medicine verification:

#### 1. Server-side Code Structure
```javascript
// server.js (Node.js/Express example)
const express = require('express');
const fs = require('fs');
const app = express();

// Load medicine database
const products = JSON.parse(fs.readFileSync('./data/products.json', 'utf8'));

// Medicine verification endpoint
app.get('/api/verify/:gtin', (req, res) => {
  const { gtin } = req.params;
  
  try {
    // Search for medicine in database
    const medicine = products.find(p => p.gtin === gtin);
    
    if (medicine) {
      res.json({
        status: 'valid',
        gtin: medicine.gtin,
        product_name: medicine.product_name,
        manufacturer: medicine.manufacturer,
        rfda_reg_no: medicine.rfda_reg_no,
        reg_date: medicine.reg_date,
        reg_status: medicine.reg_status,
        dosage_form: medicine.dosage_form,
        strength: medicine.strength,
        pack_size: medicine.pack_size,
        batch: medicine.batch,
        mfg_date: medicine.mfg_date,
        reg_expiry: medicine.reg_expiry
      });
    } else {
      res.json({
        status: 'invalid',
        gtin: gtin,
        message: 'Medicine not found in Rwanda FDA database'
      });
    }
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Internal server error'
    });
  }
});

app.listen(3000, () => {
  console.log('MedGuard API server running on port 3000');
});
```

#### 2. Database Schema
```json
// data/products.json structure (Raw Database)
[
  {
    "gtin": "8904159162031",
    "registrationNo": "Rwanda FDA-HMP-MA-0033",
    "productBrandName": "ILET B2",
    "genericName": "Glimepiride, Metformin HCl",
    "dosageStrength": "2mg, 500mg",
    "dosageForm": "Tablets",
    "packSize": "Box Of 10, Box Of 30",
    "packagingType": "ALU-PVC/PVDC BLISTER PACK",
    "shelfLife": "24 Months",
    "manufacturerName": "MSN LABORATORIES PRIVATE LIMITED",
    "manufacturerCountry": "India",
    "marketingAuthorizationHolder": "MSN LABORATORIES PRIVATE LIMITED",
    "localTechnicalRepresentative": "ABACUS PHARMA (A) LTD",
    "registrationDate": "2020-09-07",
    "expiryDate": "2025-09-07"
  }
]

// API Response Structure (Transformed for Frontend)
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
  "rfda_reg_no": "Rwanda FDA-HMP-MA-0033",
  "registration_date": "2020-09-07",
  "license_expiry_date": "2025-09-07",
  "dosage_form": "Tablets",
  "strength": "2mg, 500mg",
  "pack_size": "Box Of 10, Box Of 30",
  "expiry": "2025-09-07"
}
```

#### 3. API Endpoints
```
GET /api/verify/:gtin
- Description: Verify medicine by GTIN
- Parameters: gtin (string) - Global Trade Item Number
- Response: JSON object with verification result

GET /api/pharmacies
- Description: Get list of verified pharmacies
- Response: JSON array of pharmacy objects

GET /api/health
- Description: Health check endpoint
- Response: JSON object with server status
```

### Backend Development Skills Demonstrated
- **RESTful API Design**: Clean, intuitive endpoint structure
- **Database Operations**: JSON-based data storage and retrieval
- **Error Handling**: Proper HTTP status codes and error messages
- **Data Validation**: Input validation and sanitization
- **Server-side Logic**: Business logic implementation
- **API Documentation**: Clear endpoint specifications

## Deployment Process

### Development Environment
1. **Local Development**: Flutter development server
2. **iOS Simulator**: Xcode simulator for iOS testing
3. **Android Emulator**: Android Studio emulator for Android testing
4. **Hot Reload**: Real-time code changes during development

### Production Deployment Plan

#### Frontend Deployment
```bash
# Build for iOS
flutter build ios --release

# Build for Android
flutter build apk --release

# Deploy to App Stores
# - iOS: App Store Connect
# - Android: Google Play Console
```

#### Backend Deployment
```bash
# Deploy to cloud platform (AWS/Heroku)
# 1. Set up server instance
# 2. Install Node.js and dependencies
# 3. Configure environment variables
# 4. Deploy application
# 5. Set up monitoring and logging
```

### Infrastructure Considerations
- **Scalability**: Horizontal scaling for high traffic
- **Security**: HTTPS, input validation, rate limiting
- **Monitoring**: Application performance monitoring
- **Backup**: Regular database backups
- **CDN**: Content delivery network for static assets

## Performance Optimizations
- **Lazy Loading**: Load data only when needed
- **Caching**: Local storage for frequently accessed data
- **Image Optimization**: Compressed images and proper sizing
- **Code Splitting**: Modular code structure
- **Memory Management**: Proper disposal of resources

## Security Considerations
- **Input Validation**: Sanitize all user inputs
- **HTTPS**: Secure communication
- **Authentication**: User authentication (future enhancement)
- **Data Privacy**: GDPR compliance for user data
- **API Security**: Rate limiting and request validation
