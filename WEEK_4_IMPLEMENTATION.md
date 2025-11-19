# Week 4: Implementation & Testing Execution

**Goal**: Execute testing procedures, build release candidates, and prepare for beta launch.

## Table of Contents
1. [Week Overview](#week-overview)
2. [Day-by-Day Plan](#day-by-day-plan)
3. [Testing Execution](#testing-execution)
4. [Release Build Creation](#release-build-creation)
5. [Performance Optimization](#performance-optimization)
6. [Production Monitoring Setup](#production-monitoring-setup)
7. [Beta Launch Preparation](#beta-launch-preparation)
8. [Week 4 Deliverables](#week-4-deliverables)

---

## Week Overview

### Objectives

**Primary Goals:**
- ✅ Run all automated tests and achieve 70%+ coverage
- ✅ Fix all critical and high-priority bugs
- ✅ Build and verify release APK and AAB
- ✅ Optimize app performance (launch time, memory, size)
- ✅ Set up Firebase Crashlytics for production
- ✅ Begin internal beta testing

**Secondary Goals:**
- ✅ Implement missing unit tests for core services
- ✅ Run manual testing checklist
- ✅ Profile app performance with DevTools
- ✅ Prepare beta tester communication

### Success Criteria

By end of Week 4:
- [ ] 70%+ test coverage achieved
- [ ] Zero critical bugs remaining
- [ ] Release builds < 30 MB (APK), < 50 MB (AAB)
- [ ] App launch time < 3 seconds
- [ ] Crashlytics integrated and tested
- [ ] 5-10 internal beta testers active

---

## Day-by-Day Plan

### Day 1: Static Analysis & Automated Testing

**Morning (4 hours):**
- [ ] Run `flutter analyze` and document all issues
- [ ] Fix analyzer warnings and errors
- [ ] Run `flutter test` and check current coverage
- [ ] Identify gaps in test coverage

**Afternoon (4 hours):**
- [ ] Write missing unit tests for:
  - TodoService (CRUD operations)
  - PrayerTimeService (prayer calculations)
  - SpaceService (space management)
  - AIConversationService (chat persistence)
- [ ] Run tests again and verify coverage improves
- [ ] Fix failing tests

**Evening:**
- [ ] Generate coverage report: `flutter test --coverage`
- [ ] Review coverage HTML report
- [ ] Document remaining test gaps

**Deliverables:**
- Clean `flutter analyze` output
- Test coverage report (target: 70%+)
- List of remaining test gaps

---

### Day 2: Widget & Integration Testing

**Morning (4 hours):**
- [ ] Review existing widget tests (if any)
- [ ] Write widget tests for:
  - DashboardScreen (renders correctly, shows tasks)
  - AgendaScreen (filter and search functionality)
  - AIAssistantScreen (message sending)
- [ ] Verify all tests pass

**Afternoon (4 hours):**
- [ ] Write integration tests for:
  - Complete task lifecycle (create → edit → complete → delete)
  - Prayer-relative scheduling flow
  - Data persistence (create → close app → verify exists)
- [ ] Run integration tests: `flutter test integration_test/`

**Evening:**
- [ ] Fix any failing integration tests
- [ ] Document test results
- [ ] Update test coverage report

**Deliverables:**
- Widget tests for 3+ key screens
- Integration tests for 2+ critical flows
- Updated coverage report

---

### Day 3: Manual Testing & Bug Fixing

**Morning (3 hours):**
- [ ] Follow TESTING_QA_GUIDE.md manual checklist
- [ ] Test on physical Android device:
  - Prayer times accuracy
  - Task CRUD operations
  - AI assistant responses
  - Voice input (Android)
  - Offline functionality
  - Permissions handling
- [ ] Document all bugs found

**Afternoon (4 hours):**
- [ ] Prioritize bugs (Critical > High > Medium > Low)
- [ ] Fix all critical bugs
- [ ] Fix high-priority bugs
- [ ] Re-test fixed issues

**Evening (1 hour):**
- [ ] Test on iOS device (if available) or iOS Simulator
- [ ] Document platform-specific issues
- [ ] Update bug tracker

**Deliverables:**
- Completed manual testing checklist
- Bug report with severity levels
- All critical bugs fixed

---

### Day 4: Release Build Creation & Verification

**Morning (2 hours):**
- [ ] Ensure .env file has all required API keys
- [ ] Verify .gitignore excludes sensitive files
- [ ] Update version number in pubspec.yaml (1.0.0+1)
- [ ] Clean build: `flutter clean && flutter pub get`

**Release Build Steps:**

**APK Build:**
```bash
# Build release APK
flutter build apk --release

# Check output
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Verify size (target: < 30 MB)
du -h build/app/outputs/flutter-apk/app-release.apk
```

**AAB Build (for Google Play):**
```bash
# Build app bundle
flutter build appbundle --release

# Check output
ls -lh build/app/outputs/bundle/release/app-release.aab

# Verify size
du -h build/app/outputs/bundle/release/app-release.aab

# Analyze size
flutter build appbundle --release --analyze-size
```

**iOS Build (if on macOS):**
```bash
# Build iOS release
flutter build ios --release

# Or archive in Xcode:
# open ios/Runner.xcworkspace
# Product → Archive
```

**Afternoon (3 hours):**
- [ ] Install release APK on physical device
- [ ] Verify all features work in release mode
- [ ] Test that debug features are disabled
- [ ] Verify analytics and crashlytics work
- [ ] Test offline functionality
- [ ] Check app size on device

**Evening (2 hours):**
- [ ] Document release build checklist results
- [ ] If issues found: fix and rebuild
- [ ] Create backup of release builds
- [ ] Tag release in git: `git tag v1.0.0-rc1`

**Deliverables:**
- Release APK (< 30 MB)
- Release AAB (< 50 MB)
- iOS IPA (if applicable)
- Release build verification report

---

### Day 5: Performance Optimization

**Morning (3 hours):**

**Profile App Launch Time:**
```bash
# Run with performance overlay
flutter run --release --profile

# Use DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

**Check:**
- [ ] App launch time (target: < 3s)
- [ ] Frame rendering (target: 60 FPS, no jank)
- [ ] Memory usage (target: < 150 MB)
- [ ] CPU usage (shouldn't be constantly high)

**Optimizations:**
- [ ] Lazy-load heavy widgets
- [ ] Optimize image loading (if any large images)
- [ ] Review unnecessary rebuilds
- [ ] Check for memory leaks in DevTools

**Afternoon (3 hours):**

**App Size Optimization:**
```bash
# Analyze what's taking space
flutter build apk --release --analyze-size

# Enable code shrinking (should already be in build.gradle)
# minifyEnabled true
# shrinkResources true
```

**Check:**
- [ ] Remove unused dependencies
- [ ] Optimize asset sizes
- [ ] Verify ProGuard rules configured
- [ ] Check for duplicate code

**Evening (2 hours):**
- [ ] Run benchmarks again
- [ ] Compare before/after metrics
- [ ] Document optimizations made
- [ ] Rebuild release if significant improvements

**Deliverables:**
- Performance profiling report
- Optimization recommendations implemented
- Before/after metrics comparison

---

### Day 6: Production Monitoring Setup

**Morning (3 hours):**

**Firebase Crashlytics Setup:**

1. **Ensure Firebase is configured** (if not already):
```bash
# Check firebase_core and firebase_crashlytics in pubspec.yaml
# Should already be there from previous setup
```

2. **Update main.dart** to initialize Crashlytics:
```dart
// In lib/main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

3. **Test Crashlytics:**
```dart
// Add test crash button (remove before production)
FirebaseCrashlytics.instance.crash(); // Forces a crash
```

**Firebase Analytics Setup:**
- [ ] Verify analytics configured in main.dart
- [ ] Add screen tracking for key screens
- [ ] Add event tracking for key actions
- [ ] Test events in Firebase Console Debug View

**Afternoon (3 hours):**

**Logging Review:**
- [ ] Verify all `print()` statements removed
- [ ] Ensure `Logger.debug()` calls won't log in production
- [ ] Check for sensitive data in logs
- [ ] Test logger configuration

**Remote Config Setup** (Optional):
- [ ] Set up Firebase Remote Config
- [ ] Add feature flags (e.g., enable/disable features)
- [ ] Test remote config in app

**Evening (2 hours):**
- [ ] Build release with monitoring enabled
- [ ] Test crash reporting works
- [ ] Verify analytics events appear in Firebase
- [ ] Document monitoring setup

**Deliverables:**
- Crashlytics integrated and tested
- Analytics tracking key events
- Clean logs (no debug info in production)
- Monitoring documentation

---

### Day 7: Beta Launch Preparation

**Morning (3 hours):**

**Beta Tester Selection:**
- [ ] Identify 5-10 internal testers:
  - Team members
  - Friends/family
  - Trusted community members
- [ ] Create tester list with emails
- [ ] Prepare welcome email (see BETA_TESTING_GUIDE.md)

**Google Play Internal Testing:**
- [ ] Log in to Play Console
- [ ] Go to Testing → Internal testing
- [ ] Create new release
- [ ] Upload app-release.aab
- [ ] Add release notes (Beta 1)
- [ ] Create email list with tester emails
- [ ] Share testing link with testers

**Apple TestFlight** (if iOS ready):
- [ ] Log in to App Store Connect
- [ ] Upload build via Xcode
- [ ] Wait for processing (~15 minutes)
- [ ] Add internal testers
- [ ] Submit for Beta Review (if external testers)
- [ ] Share TestFlight link

**Afternoon (2 hours):**

**Beta Communication:**
- [ ] Send welcome email to testers
- [ ] Create feedback form (Google Forms)
- [ ] Set up Discord channel (optional)
- [ ] Prepare FAQ document

**Welcome Email Template:**
```
Subject: 🚀 Welcome to TaskFlow Pro Beta!

Hi [Name],

Thank you for joining the TaskFlow Pro beta test!

📱 Getting Started:
Download the app: [TestFlight/Play Store link]

🎯 What to Test:
• Prayer time accuracy in your location
• Task creation and management
• AI assistant functionality
• Overall user experience

🐛 Found a Bug?
Report it here: [Google Form link]
or email: beta@taskflowpro.com

⭐ Your Feedback Matters:
We'll use your input to improve the app before public launch.

Testing period: 1-2 weeks
Reward: Lifetime Pro features (when we add them!)

Questions? Reply to this email.

Thanks for helping make TaskFlow Pro better! 🙏

Best,
[Your Name]
```

**Evening (3 hours):**
- [ ] Monitor first installations
- [ ] Respond to tester questions
- [ ] Check crash reports
- [ ] Fix any critical issues immediately
- [ ] Communicate with testers

**Deliverables:**
- Beta released to 5-10 internal testers
- Welcome email sent
- Feedback form created
- Monitoring active

---

## Testing Execution

### Automated Testing Checklist

**Unit Tests:**
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/todo_service_test.dart

# Run with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Tests to Implement:**

**TodoService Tests** (`test/services/todo_service_test.dart`):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_pro/core/services/todo_service.dart';
import 'package:taskflow_pro/models/task.dart';

void main() {
  group('TodoService Tests', () {
    setUp(() async {
      // Clear any existing data
      await TodoService.clearAllTasks();
    });

    test('createTask should add a new task', () async {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Test Task',
        description: 'Test Description',
        dueDate: DateTime.now(),
        priority: TaskPriority.medium,
      );

      await TodoService.addTask(task);
      final tasks = await TodoService.getAllTasks();

      expect(tasks.length, 1);
      expect(tasks.first.title, 'Test Task');
    });

    test('deleteTask should remove task', () async {
      final task = Task(
        id: 1,
        title: 'Test Task',
        dueDate: DateTime.now(),
      );

      await TodoService.addTask(task);
      await TodoService.deleteTask(task.id);
      final tasks = await TodoService.getAllTasks();

      expect(tasks.length, 0);
    });

    test('toggleTaskStatus should mark task complete', () async {
      final task = Task(
        id: 1,
        title: 'Test Task',
        dueDate: DateTime.now(),
      );

      await TodoService.addTask(task);
      await TodoService.toggleTaskStatus(task);
      final tasks = await TodoService.getAllTasks();

      expect(tasks.first.isCompleted, true);
    });
  });
}
```

**PrayerTimeService Tests** (`test/services/prayer_time_service_test.dart`):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_pro/core/services/prayer_time_service.dart';

void main() {
  group('PrayerTimeService Tests', () {
    test('getPrayerTimes should return valid times', () async {
      final times = await PrayerTimeService.getPrayerTimesForDate(
        DateTime.now(),
        city: 'Abu Dhabi',
        country: 'United Arab Emirates',
      );

      expect(times, isNotNull);
      expect(times!['Fajr'], isNotNull);
      expect(times['Dhuhr'], isNotNull);
      expect(times['Asr'], isNotNull);
      expect(times['Maghrib'], isNotNull);
      expect(times['Isha'], isNotNull);
    });

    test('calculatePrayerRelativeTime should calculate correctly', () async {
      final time = await PrayerTimeService.calculatePrayerRelativeTime(
        'dhuhr_before_15',
        DateTime.now(),
      );

      expect(time, isNotNull);
      // Should be 15 minutes before Dhuhr
    });
  });
}
```

**Widget Tests:**

**DashboardScreen Test** (`test/screens/dashboard_screen_test.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_pro/screens/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen renders without crash', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DashboardScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify key widgets exist
    expect(find.text('Today\'s Tasks'), findsOneWidget);
  });
}
```

**Integration Tests:**

**Full Task Lifecycle** (`integration_test/task_lifecycle_test.dart`):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:taskflow_pro/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete task lifecycle', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Tap add task button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Enter task details
    await tester.enterText(find.byType(TextField).first, 'Test Task');
    await tester.pumpAndSettle();

    // Save task
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify task appears
    expect(find.text('Test Task'), findsOneWidget);

    // Complete task
    // (Add tap on checkbox or swipe gesture)

    // Delete task
    // (Add swipe left gesture)
  });
}
```

---

### Manual Testing Execution

**Follow TESTING_QA_GUIDE.md checklist:**

**Critical Flows to Test:**
1. ✅ Prayer times display correctly
2. ✅ Create task with prayer-relative time
3. ✅ Edit existing task
4. ✅ Mark task as complete
5. ✅ Delete task
6. ✅ AI assistant responds to queries
7. ✅ Voice input works (Android)
8. ✅ Create space/project
9. ✅ Assign task to space
10. ✅ Export data
11. ✅ Import data
12. ✅ App works offline
13. ✅ Notifications fire correctly
14. ✅ Permissions requested properly

**Test on Multiple Devices:**
- Android 7.0 (min SDK)
- Android 13+ (new permissions)
- iOS 13+ (if available)
- Tablet (if available)

**Document Results:**
```
Test: Prayer Times Accuracy
Device: Pixel 6, Android 13
Result: ✅ PASS
Notes: Times accurate for Abu Dhabi, matches IslamicFinder.org

Test: Voice Input
Device: Pixel 6, Android 13
Result: ✅ PASS
Notes: Transcription accurate, handles background noise

Test: Offline Mode
Device: Pixel 6, Android 13
Result: ✅ PASS
Notes: All features work without internet
```

---

## Release Build Creation

### Pre-Build Checklist

**Environment Setup:**
- [ ] `.env` file has all API keys
- [ ] `google-services.json` in `android/app/` (if using Firebase)
- [ ] `GoogleService-Info.plist` in `ios/Runner/` (if using Firebase)
- [ ] Android keystore created (for signing)
- [ ] `key.properties` configured

**Code Cleanup:**
- [ ] Remove all `print()` statements
- [ ] Remove debug/test code
- [ ] Disable debug UI elements
- [ ] Update app version in `pubspec.yaml`
- [ ] Update build number

**Configuration:**
```yaml
# pubspec.yaml
version: 1.0.0+1  # 1.0.0 = version name, 1 = build number
```

### Android Release Build

**Step 1: Generate Keystore** (if not done yet)
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Move to project
mv ~/upload-keystore.jks android/app/
```

**Step 2: Create key.properties**
```properties
# android/key.properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=upload-keystore.jks
```

**Step 3: Build APK**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

**Step 4: Build AAB**
```bash
flutter build appbundle --release
```

**Verify Builds:**
```bash
# Check APK size
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Check AAB size
ls -lh build/app/outputs/bundle/release/app-release.aab

# Install APK on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS Release Build

**Step 1: Open Xcode**
```bash
open ios/Runner.xcworkspace
```

**Step 2: Archive**
```
1. Select "Any iOS Device" as target
2. Product → Archive
3. Wait for build to complete
```

**Step 3: Export**
```
1. Window → Organizer
2. Select archive
3. Distribute App → App Store Connect
4. Upload
```

---

## Performance Optimization

### Launch Time Optimization

**Target: < 3 seconds**

**Profile:**
```bash
flutter run --profile --trace-startup
```

**Optimizations:**
- Lazy-load non-critical widgets
- Defer heavy computations
- Optimize initial data loading
- Use const constructors where possible

### Memory Optimization

**Target: < 150 MB**

**Profile with DevTools:**
```bash
flutter run --profile
# Open DevTools
# Monitor memory tab
# Look for leaks
```

**Optimizations:**
- Dispose controllers properly
- Cancel streams/timers
- Clear caches when appropriate
- Optimize image loading

### App Size Optimization

**Target: APK < 30 MB, AAB < 50 MB**

**Analyze:**
```bash
flutter build apk --release --analyze-size
```

**Optimizations:**
- Remove unused dependencies
- Enable code shrinking (ProGuard/R8)
- Optimize assets
- Split APKs by architecture (if needed)

---

## Production Monitoring Setup

### Firebase Crashlytics

**Setup:**
```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:ui';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

**Custom Error Logging:**
```dart
try {
  // Risky operation
} catch (e, stack) {
  FirebaseCrashlytics.instance.recordError(e, stack);
  Logger.error('Operation failed', error: e, stackTrace: stack);
}
```

### Firebase Analytics

**Track Key Events:**
```dart
// Track screen views
await FirebaseAnalytics.instance.logScreenView(
  screenName: 'DashboardScreen',
);

// Track custom events
await FirebaseAnalytics.instance.logEvent(
  name: 'task_created',
  parameters: {
    'priority': task.priority.name,
    'has_prayer_time': task.prayerRelativeTime != null,
  },
);
```

---

## Beta Launch Preparation

### Internal Beta Checklist

**Before Launch:**
- [ ] Release build tested and verified
- [ ] Crashlytics working
- [ ] Analytics tracking events
- [ ] Beta tester list ready (5-10 people)
- [ ] Welcome email drafted
- [ ] Feedback form created
- [ ] Bug tracking system set up

**Google Play Internal Testing:**
```
1. Play Console → Testing → Internal testing
2. Create new release
3. Upload AAB
4. Add release notes
5. Create email list with testers
6. Save and review
7. Start rollout to Internal testing
8. Share link with testers
```

**TestFlight:**
```
1. Upload build via Xcode
2. Wait for processing
3. App Store Connect → TestFlight
4. Select build
5. Add internal testers
6. Testers receive email invite
```

### Beta Communication

**Welcome Email Checklist:**
- [ ] Thank testers for participation
- [ ] Provide download link
- [ ] List key features to test
- [ ] Explain how to report bugs
- [ ] Set expectations (1-2 week testing period)
- [ ] Mention rewards (lifetime Pro features)

**Feedback Collection:**
- Google Forms survey
- Email: beta@taskflowpro.com
- Discord channel (optional)
- In-app feedback form (future)

---

## Week 4 Deliverables

### Must Complete:
- [x] Clean `flutter analyze` output
- [x] 70%+ test coverage
- [x] All critical bugs fixed
- [x] Release APK < 30 MB
- [x] Release AAB < 50 MB
- [x] Crashlytics integrated
- [x] Beta released to 5+ testers

### Should Complete:
- [x] Widget tests for 3+ screens
- [x] Integration tests for 2+ flows
- [x] Manual testing checklist 100% done
- [x] Performance optimizations applied
- [x] Analytics tracking key events
- [x] Beta feedback form created

### Nice to Have:
- [ ] iOS beta on TestFlight
- [ ] 10+ internal beta testers
- [ ] Tablet testing complete
- [ ] 80%+ test coverage
- [ ] All medium bugs fixed

---

## Next Steps

**After Week 4:**

**Week 5: Beta Iteration & Bug Fixes**
- Collect beta feedback
- Fix reported bugs
- Improve onboarding based on feedback
- Plan version 1.0.1 updates
- Prepare for wider beta (closed testing)

**Week 6: Final Polish & Submission**
- Release version 1.0.0 to production
- Submit to Google Play Store
- Submit to Apple App Store
- Execute launch strategy
- Monitor initial user feedback

---

## Summary

Week 4 transforms documentation into action:
- From testing guides → actual tests running
- From release checklists → actual builds created
- From monitoring plans → Crashlytics integrated
- From beta strategy → real testers using the app

By end of this week, you'll have:
- ✅ Verified, tested app
- ✅ Production-ready release builds
- ✅ Active beta test with real users
- ✅ Monitoring infrastructure in place

**You're 2 weeks away from public launch!** 🚀

Good luck with Week 4! Let's make TaskFlow Pro production-ready! 💪
