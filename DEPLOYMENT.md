# MedGuard - Deployment Documentation

## Overview
This document provides comprehensive deployment instructions for the MedGuard application, including database configuration, mobile app build instructions, and deployment verification steps.

**Note:** MedGuard uses Supabase (cloud-hosted PostgreSQL) as its backend database. No local server deployment is required.

---

## 1. Database Configuration (Supabase)

### 1.1 Supabase Project Setup

#### Prerequisites
- Supabase account ([sign up at supabase.com](https://supabase.com))
- Flutter SDK installed

#### Step-by-Step Instructions

**Step 1: Create Supabase Project**
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Wait for the project to be fully provisioned (usually 1-2 minutes)

**Step 2: Get Supabase Credentials**
1. Navigate to **Settings** → **API**
2. Copy your **Project URL** (e.g., `https://xxxxx.supabase.co`)
3. Copy your **anon/public** key (starts with `eyJ...`)

**Step 3: Configure Environment Variables**
1. Navigate to `frontend/` directory
2. Create `.env` file:
```bash
cd frontend
touch .env
```

3. Add your Supabase credentials to `.env`:
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Step 4: Verify .env File Location**
- The `.env` file must be in the `frontend/` directory
- The file should be gitignored (already configured in `.gitignore`)
- See `frontend/README_ENV.md` for detailed instructions

**Step 5: Setup Database Tables**
1. Create `products` table in Supabase SQL Editor
2. Create `pharmacies` table in Supabase SQL Editor
3. Import data using SQL scripts or Supabase dashboard

### 1.2 Database Connection Testing

#### Test Connection from App
1. Run the app
2. Navigate to **Settings** → **Database Connection**
3. Verify connection status shows "Connected"

#### Test Connection via Flutter
```bash
cd frontend
flutter run
# Check app logs for Supabase initialization messages
```

---

## 2. Frontend Mobile App Deployment

### 2.1 Android APK Build

#### Prerequisites
- Flutter SDK installed
- Android Studio installed
- Android SDK configured

#### Step-by-Step Instructions

**Step 1: Navigate to Frontend Directory**
```bash
cd medguard/frontend
```

**Step 2: Install Flutter Dependencies**
```bash
flutter pub get
```

**Step 3: Configure Android Build**
```bash
# Verify Flutter setup
flutter doctor

# Check available devices
flutter devices
```

**Step 4: Configure Environment Variables (if needed)**
```bash
# Ensure .env file exists in frontend/ directory
# Contains: SUPABASE_URL and SUPABASE_ANON_KEY
# See frontend/README_ENV.md for detailed instructions
```

**Step 5: Build APK**
```bash
# Build debug APK
flutter build apk

# Or build release APK (recommended for distribution)
flutter build apk --release
```

**Step 6: Locate APK File**
The APK will be located at:
```
frontend/build/app/outputs/flutter-apk/app-release.apk
```

**Step 7: Install APK on Device**
```bash
# Via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Or transfer to device and install manually
```

#### APK Distribution
- **File Size:** ~20-30MB (release build)
- **Minimum Android Version:** Android 5.0 (API level 21)
- **Distribution:** Share APK file directly or upload to Google Play Store

---

### 2.2 iOS Build

#### Prerequisites
- macOS with Xcode installed
- Apple Developer Account (for App Store distribution)
- iOS device or simulator

#### Step-by-Step Instructions

**Step 1: Navigate to Frontend Directory**
```bash
cd medguard/frontend
```

**Step 2: Install Dependencies**
```bash
flutter pub get
```

**Step 3: Configure iOS Settings**
```bash
# Open iOS project
cd ios
pod install
cd ..
```

**Step 4: Update Bundle Identifier (if needed)**
```bash
# Edit ios/Runner.xcodeproj/project.pbxproj
# Update PRODUCT_BUNDLE_IDENTIFIER to your unique identifier
```

**Step 5: Build iOS App**
```bash
# Build for iOS simulator
flutter build ios --simulator

# Build for physical device (requires signing)
flutter build ios --release
```

**Step 6: Archive and Distribute**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Distribute App → Choose distribution method:
   - **Ad Hoc:** For testing on registered devices
   - **App Store:** For App Store submission
   - **Development:** For internal testing

---

### 2.3 Web Deployment (Optional)

#### Build Web Version
```bash
cd frontend
flutter build web
```

#### Deploy to Web Server
The build output is in `frontend/build/web/`. Upload contents to:
- GitHub Pages
- Netlify
- Firebase Hosting
- Any web server

---

## 3. Deployment Verification

### 3.1 Database Connection Verification

**Test 1: Supabase Connection**
1. Open the app
2. Navigate to **Settings** screen
3. Check **Database Connection** section
4. Verify status shows "Connected" with green indicator

**Test 2: Database Query Test**
1. Open the app
2. Navigate to **Home** screen
3. Try scanning a GTIN or entering manually
4. Verify medicine verification works
5. Check that results are returned from Supabase

**Test 3: Environment Variables Verification**
```bash
cd frontend
# Verify .env file exists
ls -la .env

# Check .env content (without exposing keys)
cat .env | grep -v "KEY\|URL" || echo "File exists"
```

### 3.2 Frontend Verification

**Test 1: App Launch**
- ✅ App opens without crashes
- ✅ Splash screen displays
- ✅ Navigation to home screen works

**Test 2: Database Connection**
- ✅ App connects to Supabase database
- ✅ Medicine verification works online
- ✅ Offline mode works with SQLite fallback
- ✅ Error handling works when offline

**Test 3: Core Features**
- ✅ Barcode scanning works
- ✅ Manual entry works
- ✅ History saves and displays
- ✅ Language switching works
- ✅ Settings persist

**Test 4: Offline Functionality**
- ✅ Enable airplane mode
- ✅ Verify medicine (should use offline database)
- ✅ View history (should work offline)

---

## 4. Production Deployment Checklist

### Database Checklist
- [x] Supabase project created
- [ ] Supabase credentials configured in `.env` file
- [ ] `products` table created in Supabase
- [ ] `pharmacies` table created in Supabase
- [ ] Database tables populated with data
- [ ] Connection tested from app settings
- [ ] Environment variables verified

### Frontend Checklist
- [ ] `.env` file created with Supabase credentials in `frontend/` directory
- [ ] App builds successfully
- [ ] Supabase connection verified in settings screen
- [ ] APK/iOS build created
- [ ] App tested on physical device
- [ ] All features tested (scanning, manual entry, history, pharmacies, settings)
- [ ] Online mode tested (Supabase connection)
- [ ] Offline mode tested (SQLite fallback)
- [ ] Error handling verified

### Distribution Checklist
- [ ] APK file created and tested
- [ ] iOS build archived (if iOS)
- [ ] Installation instructions prepared
- [ ] App Store/Play Store accounts set up (if applicable)
- [ ] App metadata and screenshots prepared
- [ ] Privacy policy and terms of service (if required)

---

## 5. Deployment Troubleshooting

### Common Issues

**Issue 1: Supabase Connection Errors**
- **Solution:** Verify `.env` file exists in `frontend/` directory
- **Solution:** Check that `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set correctly
- **Solution:** Verify Supabase project is active and accessible
- **Solution:** Check that required tables (`products`, `pharmacies`) exist in Supabase

**Issue 2: Environment Variables Not Loading**
- **Solution:** Ensure `.env` file is in the `frontend/` directory (not root)
- **Solution:** Verify `.env` file format is correct (no spaces around `=`)
- **Solution:** Restart the app after updating `.env` file
- **Solution:** Check app logs for Supabase initialization errors

**Issue 3: Build Failures**
- **Solution:** Run `flutter clean` and rebuild
- **Solution:** Verify all dependencies are installed
- **Solution:** Check Flutter and SDK versions

**Issue 4: APK Too Large**
- **Solution:** Build release APK (smaller than debug)
- **Solution:** Enable code splitting if needed
- **Solution:** Remove unused assets

**Issue 5: iOS Signing Errors**
- **Solution:** Configure signing certificates in Xcode
- **Solution:** Verify bundle identifier is unique
- **Solution:** Check Apple Developer account status

---

## 6. Deployment Environment Configuration

### Development
- **Database:** Supabase development project
- **Frontend:** Local device/simulator with `.env` configuration

### Staging (if applicable)
- **Database:** Supabase staging project
- **Frontend:** Staging build with staging `.env` credentials

### Production
- **Database:** Supabase production project
- **Frontend:** App Store / Play Store builds with production credentials

---

## 7. Next Steps After Deployment

1. **Monitor Database:**
   - Check Supabase dashboard for connection metrics
   - Monitor database usage and quotas
   - Verify data integrity in tables

2. **Test on Real Devices:**
   - Test on various Android devices
   - Test on various iOS devices
   - Verify Supabase connection on different networks
   - Gather user feedback

3. **Update Documentation:**
   - Document Supabase project URL (if needed for reference)
   - Document known issues
   - Maintain changelog

4. **Prepare for Distribution:**
   - Create app store listings
   - Prepare screenshots and descriptions
   - Set up analytics (if desired)
   - Ensure `.env` is not included in distribution

---

## 8. Quick Deployment Reference

### Database Setup (Supabase)
```bash
# 1. Create Supabase project at supabase.com
# 2. Get credentials from Settings → API
# 3. Create frontend/.env file:
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
# 4. Create tables in Supabase SQL Editor
# 5. Import data as needed
```

### Frontend (Android APK)
```bash
cd frontend
flutter pub get
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

### Frontend (iOS)
```bash
cd frontend
flutter pub get
flutter build ios --release
# Open ios/Runner.xcworkspace in Xcode for distribution
```

---

**Deployment Documentation Version:** 1.0
**Last Updated:** [Current Date]
**Maintained By:** [Your Name]

