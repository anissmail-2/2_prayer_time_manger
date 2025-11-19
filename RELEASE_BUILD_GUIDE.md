# Release Build Guide - TaskFlow Pro

**Complete step-by-step guide for creating production-ready release builds.**

## Table of Contents
1. [Pre-Build Checklist](#pre-build-checklist)
2. [Android Release Build](#android-release-build)
3. [iOS Release Build](#ios-release-build)
4. [Build Verification](#build-verification)
5. [Size Optimization](#size-optimization)
6. [Troubleshooting](#troubleshooting)

---

## Pre-Build Checklist

### 1. Environment Configuration

**Verify API Keys:**
```bash
# Check .env file exists (NOT committed to git)
ls -la .env

# Should see .env file with your actual API keys
# If not, copy from template:
cp .env.example .env

# Edit with your real API keys
nano .env  # or vim, code, etc.
```

**Required in `.env`**:
```bash
GEMINI_API_KEY=your_actual_gemini_api_key_here
DEEPGRAM_API_KEY=your_actual_deepgram_api_key_here
FIREBASE_ENABLED=false  # or true if using Firebase
ANALYTICS_ENABLED=true
CRASHLYTICS_ENABLED=true
DEBUG_MODE=false  # IMPORTANT: false for production
LOG_LEVEL=info  # or error for production
```

---

### 2. Code Cleanup Checklist

**Remove Debug Code:**
```bash
# Search for print() statements (should use Logger instead)
grep -r "print(" lib/ --exclude-dir={.dart_tool,build}

# Search for debug-only code
grep -r "kDebugMode" lib/

# Search for TODO comments
grep -r "TODO" lib/
```

**Verify Logger Usage:**
- ✅ All logging uses `Logger` class (not `print()`)
- ✅ `Logger.debug()` calls are automatically disabled in production
- ✅ No sensitive data in logs (API keys, user data, etc.)

**Update Version:**
```yaml
# pubspec.yaml
version: 1.0.0+1
# Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
# 1.0.0 = version name (shown to users)
# 1 = build number (internal, increments with each build)
```

---

### 3. Dependency Check

**Update Dependencies** (optional but recommended):
```bash
# Check for outdated packages
flutter pub outdated

# Update to latest compatible versions
flutter pub upgrade

# Get dependencies
flutter pub get
```

**Verify pubspec.yaml:**
```yaml
dependencies:
  # All production dependencies listed
  # No test-only dependencies here

dev_dependencies:
  # Test and development dependencies only
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

### 4. Static Analysis

**Run flutter analyze:**
```bash
# Check for code issues
flutter analyze

# Expected output:
# Analyzing taskflow_pro...
# No issues found!
```

**Fix all issues before building:**
- Errors: MUST fix (build will fail)
- Warnings: SHOULD fix (indicates potential bugs)
- Info: Nice to fix (code quality)

---

### 5. Run Tests

**Verify all tests pass:**
```bash
# Run all tests
flutter test

# Expected: All tests passed!
```

If tests fail:
1. Fix failing tests first
2. Don't proceed with release build until all tests pass

---

## Android Release Build

### Step 1: Generate Keystore (One-Time Setup)

**If you don't have a keystore yet:**

```bash
# Generate upload keystore
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload

# You'll be prompted for:
# - Keystore password (remember this!)
# - Key password (remember this!)
# - Name, Organization, etc.

# Move keystore to project
mv ~/upload-keystore.jks android/app/

# ⚠️ CRITICAL: Backup this file securely!
# Without it, you can't update your app on Google Play
```

**Backup Keystore:**
```bash
# Copy to secure location (NOT in git repo!)
cp android/app/upload-keystore.jks ~/Dropbox/TaskFlowPro/keystore/
# Or upload to password manager, encrypted cloud storage, etc.
```

---

### Step 2: Configure Signing

**Create `android/key.properties`:**

```properties
# android/key.properties
storePassword=your_keystore_password_here
keyPassword=your_key_password_here
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ CRITICAL**: This file contains passwords!
- Verify `.gitignore` excludes `key.properties`
- Never commit to git
- Backup securely

**Verify gitignore:**
```bash
# Check key.properties is ignored
git status

# Should NOT show key.properties as untracked
# If it does, add to .gitignore:
echo "key.properties" >> android/.gitignore
```

---

### Step 3: Verify build.gradle Configuration

**Check `android/app/build.gradle`:**

```gradle
// Should already be configured from ANDROID_RELEASE_SETUP.md

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**Verify ProGuard rules** (`android/app/proguard-rules.pro`):
```proguard
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase (if using)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Gemini AI
-keep class com.google.ai.** { *; }

# Your app classes
-keep class com.awkati.taskflow.** { *; }
```

---

### Step 4: Clean Build Environment

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Verify everything compiles in debug mode first
flutter build apk --debug

# If debug build succeeds, proceed to release
```

---

### Step 5: Build Release APK

```bash
# Build release APK
flutter build apk --release

# This will:
# 1. Compile Dart code to native ARM code
# 2. Apply ProGuard/R8 code shrinking
# 3. Remove debug symbols
# 4. Sign APK with your keystore
# 5. Optimize for release

# Build time: 3-10 minutes depending on machine

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

**Expected Output:**
```
Running Gradle task 'assembleRelease'...
✓ Built build/app/outputs/flutter-apk/app-release.apk (XX.XMB)
```

---

### Step 6: Build App Bundle (AAB) for Google Play

```bash
# Build app bundle (recommended for Play Store)
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab

# App bundles allow Google Play to optimize APK for each device
# Result: Smaller downloads for users
```

**Expected Output:**
```
Running Gradle task 'bundleRelease'...
✓ Built build/app/outputs/bundle/release/app-release.aab (XX.XMB)
```

---

### Step 7: Verify Build

```bash
# Check APK size
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Target: < 30 MB
# Acceptable: < 50 MB

# Check AAB size
ls -lh build/app/outputs/bundle/release/app-release.aab

# Target: < 50 MB
# Acceptable: < 100 MB
```

**Analyze APK size:**
```bash
# See what's taking space
flutter build apk --release --analyze-size

# Opens browser with size breakdown
# Shows:
# - Dart code size
# - Assets size
# - Native libraries size
# - Resources size
```

---

## iOS Release Build

### Prerequisites

**Requirements:**
- macOS computer
- Xcode 14+ installed
- Apple Developer account ($99/year)
- iOS device or simulator

**Not on macOS?**
- Use cloud Mac service (MacStadium, MacinCloud)
- Or build using CI/CD (GitHub Actions, Codemagic)

---

### Step 1: Verify iOS Configuration

**Check Bundle ID:**
```bash
# Open ios/Runner.xcworkspace
open ios/Runner.xcworkspace

# In Xcode:
# Runner (project) → Runner (target) → General
# Bundle Identifier: com.awkati.taskflow
# Version: 1.0.0
# Build: 1
```

**Verify Signing:**
```
# In Xcode:
# Runner → Signing & Capabilities
# Team: Select your Apple Developer team
# Signing Certificate: Apple Distribution
# Provisioning Profile: Automatically manage signing (recommended)
```

---

### Step 2: Build iOS Release

**Option A: Command Line**

```bash
# Build iOS release
flutter build ios --release

# Output location:
# build/ios/iphoneos/Runner.app
```

**Option B: Xcode Archive (Recommended for App Store)**

```bash
# Open in Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select "Any iOS Device (arm64)" as target
#    (or your connected iPhone)
# 2. Product → Archive
# 3. Wait for build (5-15 minutes)
# 4. Archive Organizer opens automatically
```

---

### Step 3: Export Archive

**In Xcode Organizer:**

```
1. Select your archive
2. Click "Distribute App"
3. Select "App Store Connect"
4. Click "Next"
5. Select "Upload"
6. Select signing options (automatic)
7. Review app information
8. Click "Upload"
9. Wait for upload (2-10 minutes depending on size)
```

**Alternative: Transporter App**

```
1. In Xcode Organizer:
   - Select archive
   - Distribute App → Export
   - Save .ipa file

2. Open Transporter app
3. Drag .ipa to Transporter
4. Click "Deliver"
5. Wait for upload
```

---

### Step 4: Verify Upload in App Store Connect

```
1. Go to https://appstoreconnect.apple.com
2. My Apps → TaskFlow Pro
3. TestFlight tab
4. Wait for processing (10-30 minutes)
5. Build appears under "iOS builds"
6. Status: "Ready to Submit" (green checkmark)
```

---

## Build Verification

### 1. Install and Test APK

**Install on physical Android device:**

```bash
# Connect device via USB
# Enable USB debugging on device

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk

# Or:
adb install -r build/app/outputs/flutter-apk/app-release.apk
# -r flag: replace existing installation
```

**Test checklist:**
- [ ] App launches successfully
- [ ] All features work (prayer times, tasks, AI, etc.)
- [ ] No debug UI elements visible
- [ ] Logs don't show debug information
- [ ] Performance is smooth
- [ ] No crashes in common flows

---

### 2. Verify Release Configuration

**Check debug mode is disabled:**

```bash
# Open app
# If you see any debug overlays, banners, or logs:
# DEBUG_MODE is still true in .env

# Verify in .env:
DEBUG_MODE=false
LOG_LEVEL=info  # or error
```

**Check signing:**

```bash
# Verify APK is signed
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Should show:
# jar verified.
# signer certificate: CN=...
```

---

### 3. Performance Check

**App Launch Time:**
```bash
# Time the app launch
# From tap icon → app fully loaded
# Target: < 3 seconds
# Acceptable: < 5 seconds
```

**Memory Usage:**
```bash
# While app is running:
adb shell dumpsys meminfo com.awkati.taskflow

# Look for "TOTAL" under "App Summary"
# Target: < 150 MB
# Acceptable: < 200 MB
```

**APK Size:**
```bash
# Check download size
du -h build/app/outputs/flutter-apk/app-release.apk

# Target: < 30 MB
# Acceptable: < 50 MB
# Limit: Google Play maximum is 100 MB for APK
```

---

## Size Optimization

### If APK/AAB is Too Large (> 50 MB)

**1. Analyze what's taking space:**

```bash
flutter build apk --release --analyze-size

# Opens browser showing:
# - Code size (Dart + native)
# - Assets size (images, fonts)
# - Resources (layouts, strings)
```

**2. Optimize assets:**

```bash
# Compress images (if you have any large images)
# Use tools like:
# - ImageOptim (macOS)
# - TinyPNG (online)
# - pngquant (command line)

# Remove unused assets
# Check pubspec.yaml assets section
# Remove any files not used
```

**3. Remove unused code:**

```bash
# Tree shaking removes unused code automatically
# But you can help by:

# Remove unused dependencies from pubspec.yaml
flutter pub get

# Use only needed parts of packages
# Example: Don't import entire package if only using one function
```

**4. Split APK by architecture:**

```gradle
// android/app/build.gradle

android {
    ...
    splits {
        abi {
            enable true
            reset()
            include 'arm64-v8a', 'armeabi-v7a'
            universalApk false
        }
    }
}
```

```bash
flutter build apk --release --split-per-abi

# Generates separate APKs:
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM)
# - app-x86_64-release.apk (64-bit Intel, for emulators)

# Each APK is ~40-60% smaller
# Upload all APKs to Google Play (it serves the right one per device)
```

---

## Troubleshooting

### Build Failures

**Error: "Keystore file not found"**

```bash
# Solution: Check key.properties path
cat android/key.properties

# storeFile should be relative to android/app/
storeFile=upload-keystore.jks

# OR absolute path:
storeFile=/Users/yourname/project/android/app/upload-keystore.jks
```

---

**Error: "Keystore was tampered with, or password was incorrect"**

```bash
# Solution: Verify password in key.properties
# Make sure no extra spaces or special characters

# Test keystore manually:
keytool -list -v -keystore android/app/upload-keystore.jks
# Enter password when prompted
# Should list keystore details
```

---

**Error: "Execution failed for task ':app:minifyReleaseWithR8'"**

```bash
# Solution: ProGuard/R8 issue
# Add keep rules in android/app/proguard-rules.pro

# Add for problematic package:
-keep class com.package.name.** { *; }

# Or disable minification temporarily:
# android/app/build.gradle
minifyEnabled false

# Build to identify issue, then fix ProGuard rules
```

---

**Error: "Unsupported class file major version 61"**

```bash
# Solution: Java version mismatch
# Flutter requires Java 11

# Check Java version:
java -version

# Should show version 11.x.x

# Install Java 11 if needed:
# macOS: brew install openjdk@11
# Linux: sudo apt install openjdk-11-jdk

# Set JAVA_HOME:
export JAVA_HOME=/path/to/java11
```

---

**Error: "BUILD FAILED: Gradle build daemon disappeared unexpectedly"**

```bash
# Solution: Increase Gradle memory

# Create/edit gradle.properties:
echo "org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m" >> android/gradle.properties

# Or edit manually:
# android/gradle.properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
org.gradle.daemon=true
org.gradle.parallel=true
```

---

**Error: APK size > 100 MB**

```bash
# Solution: Use App Bundle instead
flutter build appbundle --release

# Or split APK by ABI
flutter build apk --release --split-per-abi
```

---

### iOS Build Failures

**Error: "No valid signing certificate found"**

```
Solution (in Xcode):
1. Runner → Signing & Capabilities
2. Uncheck "Automatically manage signing"
3. Re-check "Automatically manage signing"
4. Select team from dropdown
5. Xcode will generate certificates
```

---

**Error: "The application's Info.plist does not contain a valid CFBundleVersion"**

```bash
# Solution: Check version in pubspec.yaml
# Must be format: X.Y.Z+BUILD

# Correct:
version: 1.0.0+1

# Incorrect:
version: 1.0.0
version: 1.0
```

---

### Performance Issues

**App launches slowly (> 5 seconds)**

```dart
// Optimize main.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize what's absolutely necessary on startup
  await Firebase.initializeApp();

  // Defer heavy initialization
  runApp(const MyApp());

  // Initialize after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Initialize heavy services here
  });
}
```

---

**High memory usage (> 200 MB)**

```dart
// Check for memory leaks
// 1. Dispose controllers
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// 2. Cancel streams
final subscription = stream.listen(...);
subscription.cancel();

// 3. Clear caches
ImageCache().clear();
```

---

## Build Checklist

### Before Building:
- [ ] `.env` configured with real API keys
- [ ] `DEBUG_MODE=false` in .env
- [ ] Version updated in pubspec.yaml
- [ ] All tests pass: `flutter test`
- [ ] `flutter analyze` shows no errors
- [ ] Debug code removed
- [ ] Keystore created and backed up (Android)
- [ ] key.properties configured (Android)
- [ ] Signing configured in Xcode (iOS)

### After Building:
- [ ] APK size < 50 MB
- [ ] AAB size < 100 MB (if applicable)
- [ ] Install APK on physical device
- [ ] Test all core features
- [ ] No crashes in common flows
- [ ] Performance acceptable (< 3s launch)
- [ ] No debug UI visible
- [ ] Backup builds to secure location

### Files to Backup:
- [ ] upload-keystore.jks (Android)
- [ ] key.properties (passwords)
- [ ] app-release.apk
- [ ] app-release.aab
- [ ] ios/Runner.app (iOS)
- [ ] .ipa file (iOS)

---

## Next Steps

After successful release build:

1. ✅ **Upload to Google Play Console**
   - Testing → Internal testing
   - Create release
   - Upload AAB
   - Add release notes
   - Start rollout

2. ✅ **Upload to App Store Connect**
   - TestFlight → Upload build
   - Wait for processing
   - Add to internal testing
   - Submit for review (if external testing)

3. ✅ **Begin Beta Testing**
   - See BETA_TESTING_GUIDE.md
   - Invite 5-10 internal testers
   - Collect feedback
   - Fix critical bugs

---

## Summary

**Android Build Commands:**
```bash
flutter clean
flutter pub get
flutter build apk --release             # APK for testing
flutter build appbundle --release       # AAB for Play Store
```

**iOS Build:**
```bash
open ios/Runner.xcworkspace
# Xcode → Product → Archive
# Distribute to App Store Connect
```

**Verification:**
```bash
# Install and test
adb install build/app/outputs/flutter-apk/app-release.apk

# Check size
ls -lh build/app/outputs/flutter-apk/app-release.apk
ls -lh build/app/outputs/bundle/release/app-release.aab
```

---

**You're ready to build! Follow this guide step-by-step for production-ready releases.** 🚀📦
