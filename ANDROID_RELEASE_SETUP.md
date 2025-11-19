# Android Release Build Setup

This guide walks you through setting up Android release signing for TaskFlow Pro.

## Prerequisites

- Android Studio installed
- Java JDK 11 or later
- Flutter SDK configured
- Command line tools (keytool)

## Step 1: Generate Upload Keystore

A keystore file contains your app's signing keys. **Keep this file secure and backed up!**

```bash
# Navigate to your project's android/app directory
cd android/app

# Generate a new keystore (run this ONCE)
keytool -genkey -v -keystore upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload

# You will be prompted for:
# 1. Keystore password (SAVE THIS SECURELY!)
# 2. Key password (SAVE THIS SECURELY!)
# 3. Your name/organization details
# 4. City, State, Country
```

### Important Notes:
- ⚠️ **NEVER commit the keystore file to git** (already excluded in .gitignore)
- 💾 **Back up the keystore file** to a secure location (USB drive, password manager)
- 🔐 **Save all passwords** securely (use a password manager)
- 📝 **If you lose the keystore**, you cannot update your app on Google Play!

## Step 2: Create key.properties File

Create a file at `android/key.properties` with your keystore information:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

⚠️ **Security**: This file is git-ignored. Never commit it!

## Step 3: Configure build.gradle

The `android/app/build.gradle` file needs to be configured to use your keystore for release builds.

### Add before `android {` block:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

### Add inside `android {` block:

```gradle
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
        
        // Enable code shrinking and obfuscation
        minifyEnabled true
        shrinkResources true
        
        // ProGuard rules
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

## Step 4: Create ProGuard Rules

Create `android/app/proguard-rules.pro`:

```proguard
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Models (adjust package name)
-keep class com.awkati.taskflow.models.** { *; }
```

## Step 5: Build Release APK/Bundle

### Build APK (for direct distribution):
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (for Google Play):
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build with obfuscation (recommended):
```bash
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

## Step 6: Verify Your Build

```bash
# Check APK signature
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# You should see "jar verified" if successful
```

## Step 7: Test Release Build

Always test your release build before publishing:

```bash
# Install release APK on device
flutter install --release

# Or use adb directly
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Security Checklist

Before building for production:

- [ ] Remove all `print()` statements (use Logger instead)
- [ ] Remove all debug logging
- [ ] Verify API keys are in .env (not hardcoded)
- [ ] Test all features in release mode
- [ ] Check app size is reasonable
- [ ] Verify ProGuard rules don't break functionality
- [ ] Test on multiple devices/Android versions
- [ ] Backup keystore file securely
- [ ] Document keystore passwords in secure location

## Version Management

Update version in `pubspec.yaml`:

```yaml
version: 1.0.0+1
#        ^     ^
#        |     |
#     name  build number
```

- **Version name**: User-facing (1.0.0, 1.1.0, 2.0.0)
- **Build number**: Internal incrementing number (1, 2, 3...)

**Important**: Increment build number for every release to Google Play!

## Troubleshooting

### "Keystore file not found"
- Check `key.properties` path is correct
- Ensure `storeFile=upload-keystore.jks` (not full path)
- Keystore must be in `android/app/` directory

### "Wrong password"
- Verify passwords in `key.properties`
- Check for extra spaces in the file

### "Build failed with ProGuard"
- Check `proguard-rules.pro` for missing keep rules
- Test without obfuscation first
- Add keep rules for classes causing issues

### "App crashes in release mode"
- ProGuard may be removing needed code
- Add keep rules for affected classes
- Test incrementally with ProGuard enabled

## Google Play Console Setup

1. **Create App**: https://play.google.com/console
2. **App Integrity**: Use Play App Signing (recommended)
3. **Upload AAB**: Use the app bundle, not APK
4. **Testing**: Use internal/closed testing first
5. **Production**: Promote to production after testing

## iOS Release Setup

See `IOS_RELEASE_SETUP.md` for iOS-specific instructions (separate guide).

---

## Need Help?

- Flutter release docs: https://flutter.dev/docs/deployment/android
- Play Console help: https://support.google.com/googleplay/android-developer
- Keystore management: https://developer.android.com/studio/publish/app-signing
