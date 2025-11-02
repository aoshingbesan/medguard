# MedGuard - Technical Documentation

## Frontend Development

### Architecture Overview
MedGuard is built using Flutter's widget-based architecture with a focus on:
- **Modular Design**: Each screen is a separate widget
- **State Management**: StatefulWidget for local state
- **Separation of Concerns**: API logic separated from UI logic
- **Reusable Components**: Custom widgets for consistent UI

### Current Implementation Status
- **✅ Manual GTIN Entry**: Fully functional with real-time verification (13 or 14 digits validation)
- **✅ Barcode Scanning**: Fully implemented and functional
  - Camera integration using `mobile_scanner` package
  - GTIN detection and validation for multiple formats (EAN-13, EAN-8, UPC-A, UPC-E, Code128, GS1 DataMatrix, QR codes)
  - Scanning UI with camera preview and error handling
  - Manual entry fallback option

### Key Frontend Code Examples

#### 1. API Integration (Supabase)
```dart
// lib/api.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class Api {
  static SupabaseClient get _supabase => Supabase.instance.client;
  
  static Future<Map<String, dynamic>> verifyOnline(String gtin) async {
    try {
      // Clean and validate GTIN
      String cleanGtin = gtin.replaceAll(RegExp(r'[^\d]'), '').trim();
      
      // Query Supabase products table
      final response = await _supabase
          .from('products')
          .select('*')
          .eq('gtin', cleanGtin)
          .maybeSingle();
      
      if (response != null) {
        return {
          'status': 'valid',
          'gtin': response['gtin'],
          'product_name': response['product_name'],
          'brand': response['brand'] ?? response['product_name'],
          // ... additional fields
        };
      } else {
        return {
          'status': 'warning',
          'gtin': cleanGtin,
          'message': 'GTIN not found in RFDA register',
        };
      }
    } catch (e) {
      throw Exception('Database error: $e');
    }
  }
  
  // Hybrid verification with offline fallback
  static Future<Map<String, dynamic>> verify(String gtin) async {
    final isOfflineMode = await OfflineDatabase.isOfflineModeEnabled();
    
    if (isOfflineMode) {
      return await verifyOffline(gtin);
    }
    
    final isOnline = await isOnline();
    if (isOnline) {
      final result = await verifyOnline(gtin);
      if (result['status'] == 'valid' || result['status'] == 'warning') {
        return result;
      }
    }
    
    return await verifyOffline(gtin);
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

## Database Architecture (Supabase)

### Database System
MedGuard uses Supabase (cloud-hosted PostgreSQL) as its backend database system. No separate backend server is required.

#### 1. Database Schema
```sql
-- products table in Supabase
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  gtin TEXT NOT NULL UNIQUE,
  product_name TEXT NOT NULL,
  brand TEXT,
  generic_name TEXT,
  manufacturer TEXT,
  country TEXT,
  rfda_reg_no TEXT,
  registration_date DATE,
  license_expiry_date DATE,
  dosage_form TEXT,
  strength TEXT,
  pack_size TEXT,
  expiry_date DATE,
  shelf_life TEXT,
  packaging_type TEXT,
  marketing_auth_holder TEXT,
  local_tech_rep TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- pharmacies table in Supabase
CREATE TABLE pharmacies (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  email TEXT,
  district TEXT,
  sector TEXT,
  cell TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  google_maps_link TEXT,
  is_verified BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_products_gtin ON products(gtin);
CREATE INDEX idx_pharmacies_location ON pharmacies(latitude, longitude);
```

#### 2. Supabase Integration
```dart
// lib/main.dart - Supabase initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(MedGuardApp());
}
```

#### 3. Database Query Examples
```dart
// Query products by GTIN
final response = await _supabase
    .from('products')
    .select('*')
    .eq('gtin', cleanGtin)
    .maybeSingle();

// Query pharmacies with location
final pharmacies = await _supabase
    .from('pharmacies')
    .select('*')
    .eq('is_verified', true)
    .order('name');

// Test connection
final testResult = await _supabase
    .from('products')
    .select('id')
    .limit(1)
    .timeout(const Duration(seconds: 5));
```

### Database Development Skills Demonstrated
- **Cloud Database**: Supabase PostgreSQL integration
- **Database Operations**: SQL queries via Supabase SDK
- **Error Handling**: Proper error handling for database queries
- **Data Validation**: GTIN normalization and validation
- **Connection Management**: Database connection testing and status monitoring
- **Environment Variables**: Secure credential management with `.env` files

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

#### Database Configuration (Supabase)
```bash
# No backend server deployment needed
# 1. Create Supabase project at supabase.com
# 2. Create tables in Supabase SQL Editor
# 3. Import data using SQL scripts
# 4. Configure .env file in frontend/ directory:
#    SUPABASE_URL=https://your-project.supabase.co
#    SUPABASE_ANON_KEY=your-anon-key-here
# 5. App connects directly to Supabase
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
