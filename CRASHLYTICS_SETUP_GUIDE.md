# Firebase Crashlytics Setup Guide

**Complete guide for integrating Firebase Crashlytics into TaskFlow Pro for production crash reporting.**

## Table of Contents
1. [Why Crashlytics](#why-crashlytics)
2. [Setup Overview](#setup-overview)
3. [Firebase Project Configuration](#firebase-project-configuration)
4. [Android Setup](#android-setup)
5. [iOS Setup](#ios-setup)
6. [Code Integration](#code-integration)
7. [Testing Crashlytics](#testing-crashlytics)
8. [Monitoring & Alerts](#monitoring--alerts)
9. [Troubleshooting](#troubleshooting)

---

## Why Crashlytics

### Benefits

**Real-Time Crash Reporting:**
- Know when your app crashes for users
- Get detailed stack traces
- See which devices/OS versions are affected
- Track crash-free users percentage

**Better Than Manual Reports:**
- Users rarely report crashes
- Crashlytics captures automatically
- Includes device info, OS version, memory state
- Shows exact line of code that crashed

**Production Readiness:**
- Google Play and Apple App Store expect crash monitoring
- < 0.5% crash rate for good ratings
- Proactive bug fixing before users complain

---

## Setup Overview

### What We'll Do

1. ✅ Create/configure Firebase project
2. ✅ Add Firebase to Android app
3. ✅ Add Firebase to iOS app
4. ✅ Integrate Crashlytics SDK
5. ✅ Update main.dart to catch crashes
6. ✅ Test crash reporting works
7. ✅ Configure alerts

### Time Required

- **First-time setup**: 30-60 minutes
- **Already have Firebase**: 15-30 minutes
- **Just enabling Crashlytics**: 10-15 minutes

---

## Firebase Project Configuration

### Step 1: Create Firebase Project

**If you already have a Firebase project for TaskFlow Pro, skip to Step 2.**

```
1. Go to https://console.firebase.google.com
2. Click "Add project" (or "Create a project")
3. Project name: TaskFlow Pro
4. Click "Continue"
5. Enable Google Analytics: Yes (recommended)
6. Select or create Analytics account
7. Click "Create project"
8. Wait for project creation (1-2 minutes)
9. Click "Continue" when ready
```

---

### Step 2: Enable Crashlytics

```
1. In Firebase Console, select TaskFlow Pro project
2. Left sidebar → Build → Crashlytics
3. Click "Get started"
4. Click "Enable Crashlytics"
5. Crashlytics is now enabled
```

---

### Step 3: Register Apps (if not already done)

**Android App:**
```
1. Firebase Console → Project Overview → Add app
2. Select Android icon
3. Android package name: com.awkati.taskflow
4. App nickname: TaskFlow Pro (Android)
5. Debug signing certificate: Leave blank for now
6. Click "Register app"
7. Download google-services.json
8. Move to android/app/google-services.json
9. Click "Next" → "Next" → "Continue to console"
```

**iOS App:**
```
1. Firebase Console → Project Overview → Add app
2. Select iOS icon
3. iOS bundle ID: com.awkati.taskflow
4. App nickname: TaskFlow Pro (iOS)
5. App Store ID: Leave blank for now
6. Click "Register app"
7. Download GoogleService-Info.plist
8. Move to ios/Runner/GoogleService-Info.plist
9. Click "Next" → "Next" → "Continue to console"
```

---

## Android Setup

### Step 1: Add google-services.json

```bash
# Download from Firebase Console
# Place in android/app/

# Verify location:
ls -la android/app/google-services.json

# Should show:
# android/app/google-services.json

# ⚠️ IMPORTANT: This file is in .gitignore
# Do NOT commit to git (contains API keys)
```

---

### Step 2: Update android/build.gradle

**File: `android/build.gradle` (project-level)**

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10'

        // Add these lines:
        classpath 'com.google.gms:google-services:4.4.0'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

---

### Step 3: Update android/app/build.gradle

**File: `android/app/build.gradle` (app-level)**

```gradle
// At the top, after other plugins:
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

// Add these lines AFTER plugins:
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'

android {
    namespace "com.awkati.taskflow"
    compileSdkVersion 36
    // ... rest of android config
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-crashlytics'
    implementation 'com.google.firebase:firebase-analytics'
}
```

---

### Step 4: Verify Android Setup

```bash
# Rebuild project to verify configuration
cd android
./gradlew clean

# Should complete without errors

# Build app to test
cd ..
flutter build apk --debug

# Should build successfully
```

---

## iOS Setup

### Step 1: Add GoogleService-Info.plist

```bash
# Download from Firebase Console
# Add to Xcode project:

open ios/Runner.xcworkspace

# In Xcode:
# 1. Right-click "Runner" folder
# 2. Add Files to "Runner"...
# 3. Select GoogleService-Info.plist
# 4. ☑️ Copy items if needed
# 5. ☑️ Add to targets: Runner
# 6. Click "Add"
```

**Verify in Xcode:**
```
Navigator (left sidebar) → Runner
Should see GoogleService-Info.plist

If not visible:
- Check it's in ios/Runner/ directory
- Make sure "Add to targets: Runner" was checked
```

---

### Step 2: Update Podfile

**File: `ios/Podfile`**

```ruby
platform :ios, '13.0'

# Add at the top after platform:
use_frameworks!

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # Add Firebase dependencies
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    # Add this:
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

---

### Step 3: Install iOS Dependencies

```bash
cd ios
pod install
cd ..

# This will:
# - Download Firebase Crashlytics SDK
# - Download Firebase Analytics SDK
# - Configure Xcode project

# Expected output:
# Analyzing dependencies
# Downloading dependencies
# Installing Firebase...
# Installing Crashlytics...
# Pod installation complete!
```

---

### Step 4: Configure Upload Symbols Script (Xcode)

**Important for getting readable stack traces:**

```
1. Open ios/Runner.xcworkspace in Xcode
2. Select Runner project in Navigator
3. Select Runner target
4. Build Phases tab
5. Click + → New Run Script Phase
6. Drag script to be AFTER "Compile Sources"
7. Paste this script:

"${PODS_ROOT}/FirebaseCrashlytics/run"

8. Input Files: Add these lines:
   ${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
   $(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
```

---

## Code Integration

### Step 1: Update pubspec.yaml

**Verify these dependencies exist:**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase (should already be there)
  firebase_core: ^3.8.1
  firebase_crashlytics: ^4.2.0
  firebase_analytics: ^11.3.6

dev_dependencies:
  flutter_test:
    sdk: flutter
```

**Install dependencies:**
```bash
flutter pub get
```

---

### Step 2: Update main.dart

**File: `lib/main.dart`**

**Current structure** (simplified):
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
```

**Updated with Crashlytics:**
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async';
import 'dart:ui';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Pass all uncaught Flutter framework errors to Crashlytics
  FlutterError.onError = (FlutterErrorDetails details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Pass all uncaught asynchronous errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Run app in error zone to catch all errors
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow Pro',
      // ... rest of your app
    );
  }
}
```

---

### Step 3: Add Custom Crash Reporting

**Log custom events:**

```dart
// In your services or screens
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Log non-fatal errors
try {
  // Risky operation
  await someAsyncOperation();
} catch (e, stackTrace) {
  // Log to Crashlytics
  FirebaseCrashlytics.instance.recordError(
    e,
    stackTrace,
    reason: 'Failed to perform operation',
    fatal: false,
  );

  // Also log to Logger
  Logger.error('Operation failed', error: e, stackTrace: stackTrace);
}
```

**Add custom keys** (helps debug):

```dart
// Before a crash might happen
FirebaseCrashlytics.instance.setCustomKey('user_id', userId);
FirebaseCrashlytics.instance.setCustomKey('current_screen', 'DashboardScreen');
FirebaseCrashlytics.instance.setCustomKey('tasks_count', tasksCount);

// These will appear in crash reports
```

**Log breadcrumbs:**

```dart
// Track user actions leading to crash
FirebaseCrashlytics.instance.log('User tapped Create Task button');
FirebaseCrashlytics.instance.log('Navigated to AddEditItemScreen');
FirebaseCrashlytics.instance.log('Submitted task form');

// All logs appear in crash report timeline
```

---

## Testing Crashlytics

### Test Crash (Development Only)

**Add test crash button** (remove before production):

```dart
// In DashboardScreen or SettingsScreen
ElevatedButton(
  onPressed: () {
    FirebaseCrashlytics.instance.crash();
  },
  child: Text('Test Crash (Dev Only)'),
),
```

---

### Verification Steps

**Step 1: Build and run app**

```bash
# Android
flutter run --release

# iOS (in Xcode)
# Product → Run (Release scheme)
```

**Step 2: Trigger test crash**

```
1. Open app
2. Tap "Test Crash" button
3. App crashes immediately
4. Re-open app (to send crash report)
```

**Step 3: Check Firebase Console**

```
1. Firebase Console → Crashlytics
2. Wait 5-10 minutes for report to appear
3. Should see "Test crash" or similar in crash list
4. Click on crash → see stack trace

If crash doesn't appear:
- Wait longer (can take up to 1 hour)
- Check internet connection on device
- Verify google-services.json / GoogleService-Info.plist configured
- Check logs for Crashlytics initialization errors
```

---

### Verify in Production Build

**Android:**
```bash
# Build release APK with Crashlytics
flutter build apk --release

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Use app normally
# If a crash occurs, it will be reported automatically
```

**iOS:**
```
1. Archive in Xcode (Product → Archive)
2. Distribute to TestFlight
3. Install on device
4. Use app normally
5. Crashes reported automatically
```

---

## Monitoring & Alerts

### Firebase Console Dashboard

**Access Crashlytics:**
```
Firebase Console → Build → Crashlytics
```

**Key Metrics:**
- **Crash-free users**: Percentage of users with no crashes
  - Target: > 99%
  - Good: > 98%
  - Poor: < 95%
- **Crashes per session**: How often app crashes
  - Target: < 0.1%
  - Acceptable: < 0.5%
- **Affected users**: Number of users experiencing crashes

---

### Set Up Alerts

**Email Alerts:**
```
1. Crashlytics Dashboard
2. Settings (gear icon) → Crash velocity alerts
3. Enable alerts
4. Set threshold: Alert when crash-free users drops below 99%
5. Add email addresses
6. Save
```

**Slack Integration** (optional):
```
1. Crashlytics → Settings → Integrations
2. Select Slack
3. Connect to your Slack workspace
4. Select channel for crash alerts
5. Configure alert thresholds
6. Save
```

---

### Crash Prioritization

**Crashlytics groups crashes by:**
- Issue ID (same crash = same issue)
- Number of users affected
- Number of occurrences
- First seen / Last seen dates

**Priority Levels:**

| Severity | Criteria | Response Time |
|----------|----------|---------------|
| **Critical** | > 10% users affected | Fix immediately |
| **High** | 1-10% users affected | Fix within 24 hours |
| **Medium** | < 1% users affected | Fix in next update |
| **Low** | Rare (< 0.1% users) | Fix when possible |

---

## Troubleshooting

### Crashes Not Appearing in Console

**Check 1: Initialization**
```dart
// Verify Firebase initialized
await Firebase.initializeApp();

// Check Crashlytics is enabled
FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled
```

**Check 2: Configuration Files**
```bash
# Android: Verify file exists
ls -la android/app/google-services.json

# iOS: Verify in Xcode
# Should see GoogleService-Info.plist in Runner folder
```

**Check 3: Internet Connection**
```
Crash reports require internet to upload
Test on device with active internet connection
```

**Check 4: Wait Longer**
```
First crash reports can take up to 1 hour to appear
Subsequent crashes appear within 5-10 minutes
```

---

### Crashes Only Show in Debug Mode

**Problem**: Crashes appear in debug but not release builds

**Solution**: Verify Crashlytics enabled in release

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Make sure this runs in RELEASE mode too
  // (Don't wrap in kDebugMode check!)
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const MyApp());
}
```

---

### Obfuscated Stack Traces (Can't Read)

**Problem**: Stack traces show obfuscated names after ProGuard/R8

**Android Solution**:
```gradle
// android/app/build.gradle
android {
    buildTypes {
        release {
            // Keep Crashlytics mappings
            firebaseCrashlytics {
                mappingFileUploadEnabled true
            }
        }
    }
}
```

**iOS Solution**:
```
Upload symbols script must run (see iOS Setup Step 4)
Verify script added to Build Phases
```

---

### Too Many False Positives

**Problem**: Crashlytics reporting non-critical errors

**Solution**: Filter errors

```dart
// Don't report expected errors
try {
  await fetchData();
} catch (e) {
  if (e is NetworkException) {
    // Network errors are expected, don't report
    Logger.warning('Network error: $e');
  } else {
    // Unexpected error, report it
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}
```

---

## Best Practices

### 1. Add Context to Crashes

```dart
// Before user actions
FirebaseCrashlytics.instance.log('User opened DashboardScreen');

// Set user identifier (don't use PII!)
FirebaseCrashlytics.instance.setUserIdentifier('user_${hashedId}');

// Add custom keys
FirebaseCrashlytics.instance.setCustomKey('prayer_times_loaded', true);
FirebaseCrashlytics.instance.setCustomKey('tasks_count', 42);
```

---

### 2. Don't Report Everything

**Report**:
- ✅ Unexpected crashes
- ✅ Critical errors (data loss, corruption)
- ✅ Errors user can't recover from

**Don't Report**:
- ❌ Expected network errors (user offline)
- ❌ Validation errors (user input invalid)
- ❌ Permissions denied (user choice)

---

### 3. Test Regularly

```dart
// In development, test crash reporting weekly
#if DEBUG
void testCrashlytics() {
  FirebaseCrashlytics.instance.log('Testing Crashlytics');
  throw Exception('Test exception');
}
#endif
```

---

### 4. Monitor Crash-Free Users

**Target**: > 99% crash-free users

**If below target**:
1. Check recent crashes in Crashlytics
2. Identify top issues (affecting most users)
3. Fix and release hotfix
4. Monitor improvement

---

### 5. Set Up Alerts

**Configure alerts for**:
- Crash-free users drops below 99%
- New crash types appear
- Crash velocity increases

**Where to send**:
- Email (personal + team)
- Slack (development channel)
- PagerDuty (if 24/7 support)

---

## Crashlytics Checklist

### Setup:
- [ ] Firebase project created
- [ ] Crashlytics enabled in Firebase Console
- [ ] google-services.json added (Android)
- [ ] GoogleService-Info.plist added (iOS)
- [ ] Dependencies added to pubspec.yaml
- [ ] main.dart updated with error handlers
- [ ] Upload symbols script added (iOS)

### Testing:
- [ ] Test crash in debug mode → appears in Console
- [ ] Test crash in release mode → appears in Console
- [ ] Stack traces are readable (not obfuscated)
- [ ] Custom keys appear in crash reports
- [ ] Logs appear in crash timeline

### Monitoring:
- [ ] Email alerts configured
- [ ] Slack integration set up (optional)
- [ ] Crash-free users target set (99%)
- [ ] Team knows how to check Crashlytics

### Production:
- [ ] Crashlytics working in production builds
- [ ] Monitoring dashboard daily
- [ ] Responding to crashes within 24 hours
- [ ] Crash rate < 0.5%

---

## Summary

### Integration Complete When:

1. ✅ Firebase project configured
2. ✅ Crashlytics SDK integrated (Android & iOS)
3. ✅ main.dart catches all crashes
4. ✅ Test crash appears in Firebase Console
5. ✅ Production crashes being reported
6. ✅ Alerts configured
7. ✅ Team monitoring dashboard

### Commands to Remember:

```bash
# Test Crashlytics in development
flutter run --release
# Trigger test crash in app
# Check Firebase Console after 5-10 minutes

# Build production with Crashlytics
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

### Firebase Console:
```
https://console.firebase.google.com
→ Build → Crashlytics
→ Monitor crash-free users, top crashes
```

---

**Crashlytics is now ready to catch and report crashes in production!** 🐛📊
