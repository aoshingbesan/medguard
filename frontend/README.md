# MedGuard Frontend - Flutter Mobile Application

## Overview

The MedGuard frontend is a Flutter-based mobile application that provides a user-friendly interface for medicine verification. Built with Dart and Flutter, it offers cross-platform compatibility for iOS and Android devices, featuring a clean Material Design interface and robust state management.

## Features

- **Medicine Verification**: Barcode scanning and manual GTIN entry with real-time validation
- **Multi-language Support**: English, French, and Kinyarwanda localization
- **History Management**: Local storage of verification results with detailed information
- **Pharmacy Directory**: List of verified pharmacies with location data and Google Maps integration
- **RFDA Reporting**: Report unverified drugs to Rwanda FDA with location and photo
- **Offline Capability**: SQLite database for offline verification and history
- **Cloud Database Integration**: Supabase (PostgreSQL) for real-time data access
- **Responsive Design**: Optimized for various screen sizes and orientations
- **Error Handling**: Comprehensive error states and user feedback

## Architecture

### State Management
The app uses Flutter's built-in `StatefulWidget` for local state management, providing a simple yet effective approach for managing UI state and data flow.

### Navigation
- **Route-based Navigation**: Uses named routes for screen transitions
- **Argument Passing**: Dynamic route generation for result screens
- **Bottom Navigation**: Tab-based navigation for main app sections

### Data Flow
```
User Input → GTIN Verification → Supabase Database Query / SQLite Offline → Response → UI Update → Local Storage
```

## Project Structure

```
lib/
├── main.dart                 # App entry point, Supabase initialization, routing
├── theme.dart               # App theming and color constants
├── api.dart                 # Supabase integration and hybrid online/offline verification
├── home_screen.dart         # Main navigation and dashboard
├── manual_entry_screen.dart # GTIN input form with validation
├── result_screen.dart       # Verification results display
├── history_screen.dart      # Verification history with search
├── history_storage.dart     # Local data persistence
├── pharmacies_screen.dart   # Pharmacy directory with location data
├── rfda_report_screen.dart  # RFDA reporting for unverified drugs
├── settings_screen.dart      # Settings, language, offline mode
├── splash_screen.dart       # App launch screen
├── offline_database.dart    # SQLite offline database
├── simple_language_service.dart # Multi-language support
└── gtin_scanner/            # Barcode scanning module
    ├── gtin_scanner.dart    # Main scanner widget
    ├── models/
    ├── services/            # GTIN parser and validator
    └── widgets/             # Scanner UI components
```

## Key Components

### 1. API Integration (`api.dart`) - Supabase

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class Api {
  static SupabaseClient get _supabase => Supabase.instance.client;
  
  static Future<Map<String, dynamic>> verifyOnline(String gtin) async {
    // Clean GTIN - only digits
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
        // ... additional fields
      };
    } else {
      return {
        'status': 'warning',
        'gtin': cleanGtin,
        'message': 'GTIN not found in RFDA register',
      };
    }
  }
  
  // Hybrid verification with offline fallback
  static Future<Map<String, dynamic>> verify(String gtin) async {
    final isOfflineMode = await OfflineDatabase.isOfflineModeEnabled();
    if (isOfflineMode) return await verifyOffline(gtin);
    
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

### 2. Local Storage (`history_storage.dart`)

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItemDTO {
  final String brand;
  final String gtin;
  final String? lot;
  final bool verified;
  final DateTime scannedAt;

  Map<String, dynamic> toMap() => {
    'brand': brand,
    'gtin': gtin,
    'lot': lot,
    'verified': verified,
    'scannedAt': scannedAt.toIso8601String(),
  };

  factory HistoryItemDTO.fromMap(Map<String, dynamic> m) => HistoryItemDTO(
    brand: m['brand'] ?? '',
    gtin: m['gtin'] ?? '',
    lot: m['lot'],
    verified: m['verified'] == true,
    scannedAt: DateTime.tryParse(m['scannedAt'] ?? '') ?? DateTime.now(),
  );
}

class HistoryStorage {
  static const _k = 'medguard_history_v1';

  static Future<void> add(HistoryItemDTO item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_k) ?? <String>[];
    list.insert(0, jsonEncode(item.toMap()));
    await prefs.setStringList(_k, list);
  }

  static Future<List<HistoryItemDTO>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_k) ?? <String>[];
    return list
        .map((s) => jsonDecode(s))
        .whereType<Map<String, dynamic>>()
        .map(HistoryItemDTO.fromMap)
        .toList();
  }
}
```

### 3. Form Validation (`manual_entry_screen.dart`)

```dart
class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() { _loading = true; _error = null; });

    final code = _controller.text.trim();
    try {
      final res = await MedGuardApi.verify(code);
      final verified = (res['status'] == 'valid');

      final data = verified
          ? <String, dynamic>{
              'product': res['product'] ?? '—',
              'genericName': res['genericName'] ?? '—',
              'dosageForm': res['dosageForm'] ?? '—',
              'strength': res['strength'] ?? '—',
              'pack_size': res['pack_size'] ?? '—',
              'registration_date': res['registration_date'] ?? '—',
              'license_expiry_date': res['license_expiry_date'] ?? '—',
              'gtin': res['gtin'] ?? code,
            }
          : <String, dynamic>{ 'gtin': res['gtin'] ?? code };

      if (!mounted) return;
      Navigator.pushNamed(context, '/result', arguments: {'verified': verified, 'data': data});
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter GTIN Manually'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g., 5407003240214'),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Please enter a code';
                  if (!RegExp(r'^\d{8,14}$').hasMatch(s)) return 'Enter 8–14 digits';
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(_loading ? 'Verifying…' : 'Verify Medicine'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Theming (`theme.dart`)

```dart
import 'package:flutter/material.dart';

const kBrandPrimary = Color(0xFF2563EB);
const kSuccess = Color(0xFF22C55E);
const kWarning = Color(0xFFD48806);
const kDanger = Color(0xFFEF4444);
const kTextPrimary = Color(0xFF1F2937);
const kTextSecondary = Color(0xFF6B7280);
const kAppBg = Color(0xFFF9FAFB);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kBrandPrimary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: kAppBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: kAppBg,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: kTextPrimary),
      titleLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kTextPrimary),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextPrimary),
      bodyLarge:   TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kTextPrimary),
      bodyMedium:  TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kTextSecondary),
      labelLarge:  TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    ),
  );
}
```

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  cupertino_icons: ^1.0.6
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   # iOS Simulator
   flutter run -d ios
   
   # Android Emulator
   flutter run -d android
   
   # Specific device
   flutter run -d [device-id]
   ```

3. **Build for Production**
   ```bash
   # iOS
   flutter build ios
   
   # Android
   flutter build apk
   ```

## UI/UX Design

### Design Principles
- **Material Design**: Follows Google's Material Design guidelines
- **Accessibility**: High contrast ratios and proper touch targets
- **Responsive**: Adapts to different screen sizes
- **Intuitive**: Clear navigation and user feedback

### Color Scheme
- **Primary**: Blue (#2563EB) - Trust and medical professionalism
- **Success**: Green (#22C55E) - Verified medicines
- **Warning**: Orange (#D48806) - Unverified medicines
- **Danger**: Red (#EF4444) - Counterfeit medicines

### Typography
- **Font Family**: System default fonts (San Francisco on iOS, Roboto on Android)
- **Headlines**: Bold, 24px
- **Body Text**: Regular, 16px
- **Captions**: Regular, 14px

## State Management

### Local State
Each screen manages its own state using `StatefulWidget`:

```dart
class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0; // Current tab index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.local_pharmacy_rounded), label: 'Pharmacies'),
        ],
      ),
    );
  }
}
```

### Data Persistence
Uses SharedPreferences for local storage:

```dart
// Save to history
await HistoryStorage.add(HistoryItemDTO(
  brand: 'Product Name',
  gtin: '1234567890123',
  verified: true,
  scannedAt: DateTime.now(),
));

// Load from history
final history = await HistoryStorage.loadAll();
```

## Error Handling

### Network Errors
```dart
try {
  final response = await MedGuardApi.verify(gtinCode);
  // Handle success
} catch (e) {
  setState(() { _error = e.toString(); });
}
```

### Form Validation
```dart
validator: (v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Please enter a code';
  if (!RegExp(r'^\d{8,14}$').hasMatch(s)) return 'Enter 8–14 digits';
  return null;
}
```

## Performance Optimizations

- **Lazy Loading**: History items loaded on demand
- **Image Optimization**: Efficient asset management
- **Memory Management**: Proper disposal of controllers
- **Build Optimization**: Release builds with obfuscation

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```dart
testWidgets('Manual entry form validation', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: ManualEntryScreen()));
  
  await tester.enterText(find.byType(TextFormField), '123');
  await tester.tap(find.byType(FilledButton));
  await tester.pump();
  
  expect(find.text('Enter 8–14 digits'), findsOneWidget);
});
```

## Future Enhancements

- **Barcode Scanning**: Camera integration for GTIN scanning
- **Offline Mode**: Complete offline verification capability
- **Push Notifications**: Medicine recall alerts
- **Multi-language**: Kinyarwanda and French support
- **Dark Mode**: Theme switching capability
- **Analytics**: User behavior tracking

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

- **Developer**: Ademola Oshingbesan
- **Email**: a.oshingbes@alustudent.com