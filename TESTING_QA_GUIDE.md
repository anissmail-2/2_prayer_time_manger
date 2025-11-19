# Testing & QA Guide for TaskFlow Pro

Comprehensive testing procedures to ensure TaskFlow Pro is production-ready.

## Table of Contents
1. [Testing Strategy](#testing-strategy)
2. [Manual Testing Checklist](#manual-testing-checklist)
3. [Automated Testing](#automated-testing)
4. [Performance Testing](#performance-testing)
5. [Security Testing](#security-testing)
6. [Bug Tracking](#bug-tracking)

---

## Testing Strategy

### Testing Pyramid

```
        /\
       /  \      E2E Tests (5%)
      /____\     
     /      \    Integration Tests (15%)
    /________\   
   /          \  Unit Tests (80%)
  /__________  \
```

**Our Approach:**
- **Unit Tests**: Service logic, helpers, models
- **Widget Tests**: UI components, screens
- **Integration Tests**: Complete user flows
- **Manual Tests**: UX, edge cases, real devices

---

## Manual Testing Checklist

### 1. Core Functionality Tests

#### Prayer Times ✓
- [ ] **Accurate Calculations**
  - Test in different cities (Abu Dhabi, New York, London)
  - Verify times match reliable sources (IslamicFinder, etc.)
  - Check calculation methods (Dubai, ISNA, MWL)
  - Test edge cases (polar regions if supported)

- [ ] **Location Services**
  - Grant location permission → shows accurate times
  - Deny location permission → uses default location
  - Manual location selection → updates times correctly
  - Change location → times update immediately

- [ ] **Prayer Duration Settings**
  - Set custom durations for each prayer
  - Verify timeline reflects durations
  - Reset to defaults → restores original values

#### Task Management ✓
- [ ] **CRUD Operations**
  - Create task → appears in list
  - Edit task → changes reflect immediately
  - Delete task → removed from all views
  - Mark complete → shows in completed section

- [ ] **Task Properties**
  - Title (required) → validation works
  - Description (optional) → saves correctly
  - Due date/time → displays properly
  - Priority (High/Medium/Low) → colors correct
  - Recurrence patterns → tasks repeat correctly

- [ ] **Prayer-Relative Scheduling**
  - "15 minutes before Dhuhr" → calculates correct time
  - "After Maghrib" → schedules after prayer
  - Different prayers → all work correctly
  - Edge cases (midnight prayers) → handles gracefully

- [ ] **Filters & Search**
  - Filter by priority → shows only matching tasks
  - Filter by space → shows only space tasks
  - Search by title → finds relevant tasks
  - Search by tags → finds tagged tasks
  - Combined filters → works correctly
  - Clear filters → resets to all tasks

- [ ] **Swipe Gestures**
  - Swipe right → mark complete/incomplete
  - Swipe left → delete confirmation
  - Dismiss dialog → cancels action
  - Confirm → executes action

#### AI Assistant ✓
- [ ] **Natural Language Input**
  - "Add task buy groceries tomorrow" → creates task
  - "Schedule meeting 3pm" → sets correct time
  - "Remind me before Dhuhr" → prayer-relative task
  - Complex requests → parsed correctly

- [ ] **Smart Suggestions**
  - Requests suggestions → receives realistic ideas
  - Schedule optimization → proposes better times
  - Contextual responses → relevant to conversation

- [ ] **Voice Input (Android Only)**
  - Tap microphone → starts recording
  - Speak clearly → transcribes accurately
  - Background noise → handles reasonably
  - Long input → doesn't cut off
  - Permission denied → shows error gracefully

#### Spaces/Projects ✓
- [ ] **Space Management**
  - Create space → appears in list
  - Edit space → updates name/color
  - Delete space → confirmation required
  - Delete with tasks → option to reassign or delete

- [ ] **Task-Space Association**
  - Add #spaceId to task → links correctly
  - View space → shows only space tasks
  - Remove space tag → task becomes unassigned
  - Multiple spaces → handled correctly

- [ ] **Hierarchy**
  - Parent-child relationships → display correctly
  - Nested spaces → indentation shows structure
  - Breadcrumbs → navigation works

### 2. User Interface Tests

#### Navigation ✓
- [ ] **Main Navigation**
  - Dashboard → loads correctly
  - Agenda → shows all tasks
  - Spaces → displays projects
  - Timeline → renders schedule
  - AI Assistant → chat interface works
  - Prayer Schedule → shows times
  - Settings → opens configuration

- [ ] **Back Navigation**
  - Back button → returns to previous screen
  - Android system back → behaves correctly
  - Deep navigation → back stack works

#### Visual Polish ✓
- [ ] **Design System**
  - Gradient headers → display correctly
  - AnimatedCard → scales on tap
  - ShimmerCard → loading animation smooth
  - EmptyState → shows with fade-in
  - StatCards → entrance animations work

- [ ] **Responsive Layout**
  - Phone portrait → layout correct
  - Phone landscape → adapts properly
  - Tablet → uses available space
  - Desktop → sidebar navigation works

- [ ] **Theme Support**
  - Light theme → colors correct
  - Dark theme (if implemented) → readable
  - System theme → follows OS setting

#### Accessibility ✓
- [ ] **Screen Reader**
  - All buttons → have semantic labels
  - Images → have descriptions
  - Forms → labels associated
  - Navigation → logical order

- [ ] **Font Scaling**
  - Small text → app readable
  - Large text → no overflow
  - Extra large → UI doesn't break

- [ ] **Touch Targets**
  - All buttons → minimum 44x44 pt
  - Swipe areas → adequate size
  - Form fields → easy to tap

### 3. Data & Storage Tests

#### Local Storage ✓
- [ ] **Data Persistence**
  - Create task → close app → task persists
  - Edit task → close app → changes saved
  - Delete task → close app → stays deleted
  - App settings → persist across restarts

- [ ] **Offline Mode**
  - No internet → all features work
  - Prayer times → cached from last fetch
  - Tasks → full CRUD works
  - Data integrity → no corruption

- [ ] **Data Export**
  - Export data → JSON file created
  - File location → accessible to user
  - Export again → new file created
  - File contents → valid JSON

- [ ] **Data Import**
  - Select valid file → data imported
  - Invalid file → error message shown
  - Duplicate IDs → handled correctly
  - Import progress → shown to user

#### Cloud Sync (If Firebase Enabled) ✓
- [ ] **Authentication**
  - Sign up → account created
  - Sign in → authentication successful
  - Sign out → local data retained
  - Password reset → email received

- [ ] **Sync Operations**
  - Create task → syncs to cloud
  - Edit task → updates in cloud
  - Delete task → removes from cloud
  - Sync conflict → resolved correctly

- [ ] **Multi-Device**
  - Device A creates task → Device B sees it
  - Device B edits → Device A gets update
  - Offline edits → merge on reconnect

### 4. Notifications Tests

#### Local Notifications ✓
- [ ] **Permission Handling**
  - First launch → requests permission
  - Grant permission → notifications work
  - Deny permission → graceful handling
  - Change in settings → reflects in app

- [ ] **Notification Delivery**
  - Task reminder → fires at correct time
  - Prayer reminder → fires before prayer
  - Recurring task → repeats correctly
  - Missed notification → doesn't duplicate

- [ ] **Notification Actions**
  - Tap notification → opens relevant screen
  - Swipe away → dismissed
  - Mark complete from notification → updates task
  - Snooze (if implemented) → re-schedules

### 5. Edge Cases & Error Handling

#### Error Scenarios ✓
- [ ] **No Internet**
  - API calls → fail gracefully
  - Cached data → still accessible
  - Error message → user-friendly
  - Retry → works when online

- [ ] **Invalid Input**
  - Empty required fields → validation error
  - Invalid date → prevents submission
  - Special characters → handled correctly
  - SQL injection attempts → sanitized

- [ ] **Large Datasets**
  - 1000+ tasks → performance acceptable
  - Long task titles → truncate properly
  - Complex recurrence → calculates correctly
  - Memory usage → doesn't leak

- [ ] **Rapid Actions**
  - Tap button repeatedly → no duplicates
  - Quick navigation → no crashes
  - Fast scrolling → smooth rendering

#### Permission Denied ✓
- [ ] **Location Permission**
  - Denied → uses default location
  - Error message → explains impact
  - Settings link → opens system settings

- [ ] **Notification Permission**
  - Denied → explains why useful
  - Reminders → disabled appropriately
  - Re-request → doesn't spam

- [ ] **Microphone Permission (Android)**
  - Denied → voice input unavailable
  - UI indication → shows disabled state
  - Alternative → manual typing works

### 6. Platform-Specific Tests

#### Android Specific ✓
- [ ] **System Integration**
  - Back button → behaves correctly
  - Home button → app backgrounds
  - Recent apps → resume correctly
  - App switcher → shows correct preview

- [ ] **Adaptive Icons**
  - Different shapes → all look good
  - Different launchers → icon correct
  - Icon color → matches theme

- [ ] **Android Versions**
  - Android 7 (API 24) → works
  - Android 10 → gestures work
  - Android 13+ → permissions correct
  - Latest version → all features work

#### iOS Specific ✓
- [ ] **System Integration**
  - Swipe back → returns to previous screen
  - Home gesture → app backgrounds
  - App switcher → resume correctly
  - Shake to undo → works if implemented

- [ ] **Safe Areas**
  - iPhone notch → content not hidden
  - Home indicator → spacing correct
  - Status bar → content visible

- [ ] **iOS Versions**
  - iOS 13 → minimum support
  - iOS 15 → all features work
  - Latest iOS → fully compatible

---

## Automated Testing

### Unit Tests

**Test Coverage Goals:** 80% minimum

**Critical Services to Test:**
```dart
// TodoService Tests
✓ createTask() - creates task with correct properties
✓ getAllTasks() - returns all tasks
✓ getTaskById() - finds specific task
✓ updateTask() - modifies task correctly
✓ deleteTask() - removes task
✓ toggleTaskStatus() - marks complete/incomplete

// PrayerTimeService Tests
✓ getPrayerTimes() - returns valid times
✓ calculatePrayerRelativeTime() - correct calculation
✓ parsePrayerRelativeString() - parses format correctly

// SpaceService Tests
✓ createSpace() - creates with unique ID
✓ deleteSpace() - handles task reassignment
✓ getSpaceById() - retrieves correct space

// Helpers Tests
✓ Logger - formats messages correctly
✓ ConnectivityHelper - detects network state
✓ StorageHelper - saves/retrieves data
```

**Run Tests:**
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Widget Tests

**Test Critical Screens:**
```dart
// DashboardScreen Widget Tests
✓ Renders without crash
✓ Shows shimmer when loading
✓ Displays tasks when loaded
✓ Shows empty state when no tasks
✓ FAB opens add task screen

// AgendaScreen Widget Tests
✓ Filter button opens dialog
✓ Search updates task list
✓ Swipe gesture shows options
✓ Empty state has action button

// AI Assistant Widget Tests
✓ Text input field works
✓ Send button enabled with text
✓ Messages display in list
✓ Microphone button (Android only)
```

### Integration Tests

**Critical User Flows:**
```dart
// Full task lifecycle
✓ Open app → Create task → View in list → Edit → Complete → Delete

// Prayer-relative scheduling
✓ Open add task → Set prayer-relative time → Verify calculation

// Data persistence
✓ Create task → Kill app → Reopen → Verify task exists

// Offline mode
✓ Disable network → Create task → Enable network → Verify sync
```

**Run Integration Tests:**
```bash
flutter test integration_test/
```

---

## Performance Testing

### Metrics to Track

| Metric | Target | Acceptable |
|--------|--------|------------|
| **App Launch** | < 2s | < 3s |
| **Screen Navigation** | < 300ms | < 500ms |
| **List Scrolling** | 60 FPS | 55 FPS |
| **Prayer Time Fetch** | < 1s | < 2s |
| **AI Response** | < 3s | < 5s |
| **Data Export** | < 2s | < 5s |
| **Memory Usage** | < 150 MB | < 200 MB |
| **APK Size** | < 30 MB | < 50 MB |

### Performance Testing Tools

**Flutter DevTools:**
```bash
# Run with performance overlay
flutter run --profile

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

**Key Checks:**
- **Frame rendering** → No jank (dropped frames)
- **Memory leaks** → Memory graph stable
- **CPU usage** → Not constantly high
- **Network calls** → Cached appropriately

**App Size:**
```bash
# Check release APK size
flutter build apk --release --analyze-size

# Check app bundle size
flutter build appbundle --release --analyze-size
```

---

## Security Testing

### Security Checklist

#### API Keys ✓
- [ ] No hardcoded API keys in source
- [ ] .env file not committed
- [ ] Keys loaded from environment
- [ ] Invalid keys → graceful error

#### Authentication ✓
- [ ] Passwords → not stored plain text
- [ ] Session tokens → stored securely
- [ ] Re-authentication → required for sensitive ops
- [ ] Logout → clears all tokens

#### Data Security ✓
- [ ] HTTPS → all API calls
- [ ] Local storage → SharedPreferences appropriate
- [ ] Sensitive data → consider FlutterSecureStorage
- [ ] Export files → warn about security

#### Input Validation ✓
- [ ] User input → sanitized
- [ ] SQL injection → prevented (if using SQL)
- [ ] XSS attempts → blocked
- [ ] File uploads → validated

---

## Bug Tracking

### Bug Report Template

```markdown
**Bug Title:** [Short description]

**Priority:** Critical / High / Medium / Low

**Environment:**
- Device: [e.g., Pixel 6, iPhone 14]
- OS: [e.g., Android 13, iOS 16]
- App Version: [e.g., 1.0.0 (1)]

**Steps to Reproduce:**
1. Step one
2. Step two
3. Step three

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Screenshots/Video:**
[Attach if applicable]

**Logs:**
```
[Paste relevant logs]
```

**Additional Context:**
Any other relevant information
```

### Bug Severity Levels

**Critical (Fix immediately):**
- App crashes on launch
- Data loss occurs
- Security vulnerability
- Core features completely broken

**High (Fix before launch):**
- Major features don't work
- Crashes in common scenarios
- Significant UX issues
- Performance problems

**Medium (Fix soon):**
- Minor features broken
- Visual glitches
- Edge case crashes
- Non-critical errors

**Low (Nice to fix):**
- UI polish issues
- Rare edge cases
- Cosmetic problems
- Minor inconveniences

---

## Testing Schedule

### Week 3 Timeline

**Day 1-2: Automated Testing**
- Write unit tests for services
- Widget tests for main screens
- Integration tests for key flows
- Aim for 80% coverage

**Day 3-4: Manual Testing**
- Complete full checklist
- Test on multiple devices
- Test different OS versions
- Document all bugs

**Day 5: Performance & Security**
- Run performance profiling
- Check memory leaks
- Security audit
- Optimize bottlenecks

**Day 6: Bug Fixes**
- Fix critical and high bugs
- Re-test fixed issues
- Regression testing

**Day 7: Final Validation**
- Complete checklist again
- Release candidate build
- Ready for beta testing

---

## Release Criteria

### Must Pass Before Beta:
- [ ] All critical bugs fixed
- [ ] All high priority bugs fixed
- [ ] Core features work on target devices
- [ ] No crashes in common flows
- [ ] Performance meets targets
- [ ] Security audit passed

### Should Pass Before Production:
- [ ] All medium priority bugs fixed
- [ ] 80%+ test coverage
- [ ] Tested on 5+ devices
- [ ] Accessibility features work
- [ ] Privacy policy reviewed
- [ ] Terms of service finalized

---

## Testing Tools

### Essential Tools
- **Flutter DevTools** - Performance, memory
- **Firebase Crashlytics** - Crash reporting
- **Sentry** (alternative) - Error tracking
- **Charles Proxy** - Network debugging
- **Android Studio Profiler** - Android-specific
- **Xcode Instruments** - iOS-specific

### Optional Tools
- **Appium** - Cross-platform testing
- **Detox** - E2E testing
- **BrowserStack** - Device cloud testing
- **Firebase Test Lab** - Automated testing

---

## Next Steps

After completing testing:
1. ✅ Fix all critical/high bugs
2. ✅ Create release candidate build
3. ✅ Proceed to beta testing (Week 3)
4. ✅ Collect beta feedback
5. ✅ Final fixes before production

---

**Remember:** Quality over speed. A well-tested app gets better reviews and fewer support requests!

Good luck with testing! 🧪✨
