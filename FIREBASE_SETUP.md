# Firebase Setup Guide

## Current Status
- ✅ Firebase feature flag: **ENABLED** (`enableFirebaseSync = true`)
- ❌ Firebase config file: **MISSING** (needs `google-services.json`)
- ⚠️ Authentication: **Will show "Skip Sign In" until config file added**

---

## Why Firebase?

Firebase provides:
- ✅ Google Sign-In authentication
- ✅ Cloud sync across devices
- ✅ Firestore database backup
- ✅ Analytics and crash reporting

**Without Firebase, the app works perfectly in offline mode with local storage!**

---

## Setup Steps

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `TaskFlow Pro` (or your choice)
4. (Optional) Enable Google Analytics
5. Click **"Create project"**

### 2. Add Android App

1. In Firebase Console, click **"Add app"** → Select **Android**
2. Enter these details:
   - **Package name**: `com.awkati.taskflow` (MUST match exactly!)
   - **App nickname**: TaskFlow Pro (optional)
   - **SHA-1**: (optional for now, needed later for Google Sign-In)
3. Click **"Register app"**

### 3. Download Config File

1. Download `google-services.json`
2. Place it in your project:
   ```
   android/app/google-services.json
   ```
3. ⚠️ **DO NOT commit this file to git!** (already in .gitignore)

### 4. Get SHA-1 Certificate (For Google Sign-In)

#### Debug Certificate (Development):
```bash
cd android
./gradlew signingReport
```

Look for `SHA1:` under `Variant: debug` - copy this value.

#### Release Certificate (Production):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### Add SHA-1 to Firebase:
1. Go to Firebase Console → Project Settings → Your Apps
2. Scroll to **SHA certificate fingerprints**
3. Click **"Add fingerprint"**
4. Paste your SHA-1
5. Click **"Save"**

### 5. Enable Google Sign-In

1. In Firebase Console, go to **Authentication**
2. Click **"Get started"** (if first time)
3. Go to **"Sign-in method"** tab
4. Click on **Google**
5. Toggle **"Enable"**
6. Select a support email
7. Click **"Save"**

### 6. Enable Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select your region (closest to your users)
5. Click **"Enable"**

### 7. (Optional) Enable Analytics & Crashlytics

1. In Firebase Console, go to **Analytics** → Enable
2. Go to **Crashlytics** → Enable
3. Follow any additional setup prompts

---

## Testing

### After Adding google-services.json:

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean && cd ..
   flutter run
   ```

2. **Test authentication:**
   - Open app → Auth screen
   - Click **"Continue with Google"**
   - Should show Google account picker
   - Select account → Sign in

3. **Verify in Firebase Console:**
   - Go to **Authentication** → **Users**
   - Your account should appear!

---

## Troubleshooting

### "Skip Sign In" button still appears
**Cause:** `google-services.json` is missing or invalid
**Fix:**
1. Verify file exists: `android/app/google-services.json`
2. Check package name matches: `com.awkati.taskflow`
3. Rebuild app: `flutter clean && flutter run`

### "Google Sign-In failed"
**Cause:** SHA-1 certificate not added to Firebase
**Fix:**
1. Get SHA-1 (see step 4 above)
2. Add to Firebase Console
3. Wait 5 minutes for changes to propagate
4. Rebuild app

### "Firebase initialization failed"
**Cause:** Invalid `google-services.json` file
**Fix:**
1. Re-download from Firebase Console
2. Ensure it's in correct location
3. Check file is valid JSON
4. Rebuild app

### Email/Password sign-in doesn't work
**Cause:** Email/Password provider not enabled
**Fix:**
1. Firebase Console → Authentication → Sign-in method
2. Click **"Email/Password"**
3. Enable **both toggles**
4. Save

---

## Security Notes

### For Production:

1. **Update Firestore Rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

2. **Protect API Keys:**
   - Never commit `google-services.json` to public repos
   - Use Firebase App Check for production
   - Restrict API key usage in Google Cloud Console

3. **Enable App Check:**
   - Firebase Console → App Check
   - Register your app
   - Enforces only your app can access Firebase

---

## Alternative: Use App in Offline Mode

If you don't want to set up Firebase, **the app works perfectly without it!**

Just click **"Skip Sign In (Offline Mode)"** on the auth screen.

**Offline mode features:**
- ✅ All task management
- ✅ Prayer times
- ✅ Spaces organization
- ✅ AI assistant (if Gemini API key configured)
- ✅ Local data storage
- ❌ No cloud sync
- ❌ No Google Sign-In

---

## Current Configuration

```dart
// lib/core/config/app_config.dart
static const bool enableFirebaseSync = true; // ✅ ENABLED
```

To disable Firebase again, change to `false`.

---

## Need Help?

- Firebase Docs: https://firebase.google.com/docs/flutter/setup
- Google Sign-In: https://firebase.google.com/docs/auth/flutter/federated-auth
- Firestore: https://firebase.google.com/docs/firestore/quickstart

---

**Last Updated:** 2025-11-19
**Firebase Status:** Enabled in config, awaiting google-services.json
