# Onboarding Flow Implementation Guide

**Create a welcoming first-time user experience for TaskFlow Pro.**

## Table of Contents
1. [Why Onboarding Matters](#why-onboarding-matters)
2. [Onboarding Strategy](#onboarding-strategy)
3. [Screen-by-Screen Implementation](#screen-by-screen-implementation)
4. [Code Implementation](#code-implementation)
5. [Testing Onboarding](#testing-onboarding)
6. [Analytics & Optimization](#analytics--optimization)

---

## Why Onboarding Matters

### First Impressions Count

**Statistics:**
- 77% of users delete apps within 3 days
- 25% of apps are abandoned after ONE use
- Good onboarding increases retention by 50%+

**TaskFlow Pro Specific:**
- App has unique features (prayer-relative scheduling)
- Users need to grant permissions (location, notifications)
- Setup required (prayer times, preferences)

### Goals of Onboarding

**Primary:**
- ✅ Explain core value proposition
- ✅ Get required permissions
- ✅ Set up prayer times (location)
- ✅ Show key features

**Secondary:**
- ✅ Create first task (engagement)
- ✅ Build excitement
- ✅ Set expectations

---

## Onboarding Strategy

### Flow Overview

```
Launch App
    ↓
[Welcome Screen]
    ↓
[Value Proposition] (What makes TaskFlow Pro special)
    ↓
[Location Permission] (For accurate prayer times)
    ↓
[Notification Permission] (For task reminders)
    ↓
[Prayer Times Preview] (Show accurate times for their location)
    ↓
[Create First Task] (Interactive tutorial)
    ↓
[Done! → Dashboard]
```

### Onboarding Principles

**Keep It Short:**
- Target: 3-5 screens maximum
- Time: < 60 seconds to complete
- Skip option available (but not prominent)

**Show, Don't Tell:**
- Use visuals over text
- Interactive tutorials > static instructions
- Real data (actual prayer times, not placeholders)

**Progressive Disclosure:**
- Don't overwhelm with all features
- Teach as users explore
- In-app tips for advanced features

---

## Screen-by-Screen Implementation

### Screen 1: Welcome

**Purpose**: Make great first impression, set expectations

**Design:**
```
┌─────────────────────────────┐
│                             │
│      [App Icon/Logo]        │
│                             │
│     TaskFlow Pro            │
│                             │
│   "Your AI-powered          │
│    productivity             │
│    companion that           │
│    respects your            │
│    prayer times"            │
│                             │
│                             │
│   [Get Started Button]      │
│                             │
│   [Skip] (subtle)           │
│                             │
└─────────────────────────────┘
```

**Content:**
- **Title**: TaskFlow Pro
- **Tagline**: "Productivity that respects your prayers"
- **Image**: Beautiful illustration or app screenshot
- **CTA**: "Get Started" (primary button)
- **Skip**: "Skip" (text button, less prominent)

**Implementation:**
```dart
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo/icon
              Icon(
                Icons.task_alt,
                size: 120,
                color: AppTheme.primary,
              ),
              SizedBox(height: 32),

              // App name
              Text(
                'TaskFlow Pro',
                style: AppTheme.headlineLarge.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              // Tagline
              Text(
                'Productivity that respects your prayers',
                textAlign: TextAlign.center,
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 48),

              // Get started button
              ElevatedButton(
                onPressed: () => _onGetStarted(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 16),

              // Skip button (subtle)
              TextButton(
                onPressed: () => _onSkip(context),
                child: Text(
                  'Skip',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onGetStarted(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ValuePropositionScreen()),
    );
  }

  void _onSkip(BuildContext context) {
    _completeOnboarding(context);
  }
}
```

---

### Screen 2: Value Proposition (Feature Highlights)

**Purpose**: Explain what makes TaskFlow Pro special

**Design:**
```
┌─────────────────────────────┐
│  Why TaskFlow Pro?          │
│                             │
│  [Icon] Prayer Times        │
│  Accurate times for 300+    │
│  cities worldwide           │
│                             │
│  [Icon] Smart Scheduling    │
│  "15 minutes before Dhuhr"  │
│  AI understands prayers     │
│                             │
│  [Icon] Works Offline       │
│  All features available     │
│  without internet           │
│                             │
│  ●●○ (page indicator)       │
│                             │
│  [Next]                     │
└─────────────────────────────┘
```

**Features to Highlight:**
1. **Prayer Time Integration** - "Never miss a prayer"
2. **Smart Scheduling** - "Plan around what matters"
3. **AI Assistant** - "Natural language task creation"
4. **Offline First** - "Works everywhere, anytime"

**Implementation:**
```dart
class ValuePropositionScreen extends StatefulWidget {
  @override
  _ValuePropositionScreenState createState() => _ValuePropositionScreenState();
}

class _ValuePropositionScreenState extends State<ValuePropositionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingFeature> _features = [
    OnboardingFeature(
      icon: Icons.mosque,
      title: 'Accurate Prayer Times',
      description: 'Get precise prayer times for 300+ cities worldwide',
      color: AppTheme.primary,
    ),
    OnboardingFeature(
      icon: Icons.schedule,
      title: 'Prayer-Aware Scheduling',
      description: 'Schedule tasks like "15 minutes before Dhuhr"',
      color: AppTheme.secondary,
    ),
    OnboardingFeature(
      icon: Icons.smart_toy,
      title: 'AI Assistant',
      description: 'Create tasks with natural language',
      color: AppTheme.success,
    ),
    OnboardingFeature(
      icon: Icons.offline_bolt,
      title: 'Works Offline',
      description: 'Full functionality without internet',
      color: AppTheme.info,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _completeOnboarding(context),
                child: Text('Skip'),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  return _buildFeaturePage(_features[index]);
                },
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _features.length,
                (index) => _buildPageIndicator(index),
              ),
            ),
            SizedBox(height: 24),

            // Next button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _onNext,
                child: Text(
                  _currentPage == _features.length - 1
                      ? 'Get Started'
                      : 'Next',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePage(OnboardingFeature feature) {
    return Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              feature.icon,
              size: 60,
              color: feature.color,
            ),
          ),
          SizedBox(height: 32),
          Text(
            feature.title,
            style: AppTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            feature.description,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primary
            : AppTheme.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _onNext() {
    if (_currentPage < _features.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LocationPermissionScreen()),
      );
    }
  }
}

class OnboardingFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
```

---

### Screen 3: Location Permission

**Purpose**: Request location for accurate prayer times

**Design:**
```
┌─────────────────────────────┐
│                             │
│     [Location Icon]         │
│                             │
│  Enable Location            │
│                             │
│  We need your location to   │
│  provide accurate prayer    │
│  times for your city.       │
│                             │
│  Your location is never     │
│  shared or stored on our    │
│  servers.                   │
│                             │
│                             │
│  [Enable Location]          │
│                             │
│  [Set Manually]             │
│                             │
└─────────────────────────────┘
```

**Implementation:**
```dart
class LocationPermissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 100,
                color: AppTheme.primary,
              ),
              SizedBox(height: 32),

              Text(
                'Enable Location',
                style: AppTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              Text(
                'We need your location to provide accurate prayer times for your city.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyLarge,
              ),
              SizedBox(height: 16),

              Text(
                '🔒 Your location is never shared or stored on our servers.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 48),

              ElevatedButton(
                onPressed: () => _requestLocation(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Enable Location'),
              ),
              SizedBox(height: 16),

              TextButton(
                onPressed: () => _setManually(context),
                child: Text('Set Location Manually'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestLocation(BuildContext context) async {
    // Request location permission
    final hasPermission = await PermissionHelper.requestLocationPermission();

    if (hasPermission) {
      // Get current location
      try {
        final location = await LocationService.getCurrentLocation();
        // Proceed to next screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotificationPermissionScreen()),
        );
      } catch (e) {
        // If location failed, let user set manually
        _setManually(context);
      }
    } else {
      // Permission denied, show manual option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permission required for accurate prayer times'),
          action: SnackBarAction(
            label: 'Set Manually',
            onPressed: () => _setManually(context),
          ),
        ),
      );
    }
  }

  void _setManually(BuildContext context) {
    // Show city selection dialog or screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ManualLocationScreen()),
    );
  }
}
```

---

### Screen 4: Notification Permission

**Purpose**: Enable task reminders

**Design:**
```
┌─────────────────────────────┐
│                             │
│   [Notification Icon]       │
│                             │
│  Enable Notifications       │
│                             │
│  Get reminders for your     │
│  tasks and upcoming         │
│  prayers.                   │
│                             │
│  You can customize or       │
│  disable them anytime in    │
│  settings.                  │
│                             │
│                             │
│  [Enable Notifications]     │
│                             │
│  [Skip for Now]             │
│                             │
└─────────────────────────────┘
```

**Implementation:**
```dart
class NotificationPermissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active,
                size: 100,
                color: AppTheme.secondary,
              ),
              SizedBox(height: 32),

              Text(
                'Enable Notifications',
                style: AppTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              Text(
                'Get reminders for your tasks and upcoming prayers.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyLarge,
              ),
              SizedBox(height: 16),

              Text(
                'You can customize or disable them anytime in settings.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 48),

              ElevatedButton(
                onPressed: () => _requestNotifications(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Enable Notifications'),
              ),
              SizedBox(height: 16),

              TextButton(
                onPressed: () => _skipNotifications(context),
                child: Text('Skip for Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestNotifications(BuildContext context) async {
    final hasPermission = await PermissionHelper.requestNotificationPermission();

    // Proceed regardless of permission result
    _proceedToNext(context);
  }

  void _skipNotifications(BuildContext context) {
    _proceedToNext(context);
  }

  void _proceedToNext(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PrayerTimesPreviewScreen()),
    );
  }
}
```

---

### Screen 5: Prayer Times Preview

**Purpose**: Show prayer times, build trust

**Design:**
```
┌─────────────────────────────┐
│  Your Prayer Times          │
│  Abu Dhabi, UAE             │
│                             │
│  ┌─────────────────────┐   │
│  │ Fajr      05:15 AM  │   │
│  │ Sunrise   06:30 AM  │   │
│  │ Dhuhr     12:25 PM  │   │
│  │ Asr       03:45 PM  │   │
│  │ Maghrib   06:20 PM  │   │
│  │ Isha      07:50 PM  │   │
│  └─────────────────────┘   │
│                             │
│  Times are accurate for     │
│  your location              │
│                             │
│  [Looks Good!]              │
│                             │
│  [Change Location]          │
└─────────────────────────────┘
```

**Implementation:**
```dart
class PrayerTimesPreviewScreen extends StatefulWidget {
  @override
  _PrayerTimesPreviewScreenState createState() => _PrayerTimesPreviewScreenState();
}

class _PrayerTimesPreviewScreenState extends State<PrayerTimesPreviewScreen> {
  Map<String, String>? _prayerTimes;
  String _city = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final times = await PrayerTimeService.getPrayerTimesForDate(DateTime.now());
      final location = await LocationService.getCurrentCity();

      setState(() {
        _prayerTimes = times;
        _city = location ?? 'Abu Dhabi, UAE';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    SizedBox(height: 32),

                    Text(
                      'Your Prayer Times',
                      style: AppTheme.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      _city,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 32),

                    // Prayer times card
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: _prayerTimes?.entries.map((entry) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key,
                                  style: AppTheme.bodyLarge,
                                ),
                                Text(
                                  entry.value,
                                  style: AppTheme.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList() ?? [],
                      ),
                    ),
                    SizedBox(height: 24),

                    Text(
                      '✓ Times are accurate for your location',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.success,
                      ),
                    ),

                    Spacer(),

                    ElevatedButton(
                      onPressed: _onConfirm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                      child: Text('Looks Good!'),
                    ),
                    SizedBox(height: 16),

                    TextButton(
                      onPressed: _changeLocation,
                      child: Text('Change Location'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _onConfirm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateFirstTaskScreen()),
    );
  }

  void _changeLocation() {
    // Show location selection
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ManualLocationScreen()),
    );
  }
}
```

---

### Screen 6: Create First Task (Interactive)

**Purpose**: Engage user, teach core feature

**Design:**
```
┌─────────────────────────────┐
│  Create Your First Task     │
│                             │
│  Try it out! Create a task  │
│  using prayer-relative      │
│  scheduling.                │
│                             │
│  ┌─────────────────────┐   │
│  │ Task: ____________  │   │
│  │                     │   │
│  │ When: [Before] ▼   │   │
│  │       [Dhuhr ] ▼   │   │
│  │       [15 min] ▼   │   │
│  └─────────────────────┘   │
│                             │
│  Example: "Call mom"        │
│           "Buy groceries"   │
│                             │
│  [Create Task]              │
│                             │
│  [Skip] I'll do this later  │
└─────────────────────────────┘
```

**Implementation:**
```dart
class CreateFirstTaskScreen extends StatefulWidget {
  @override
  _CreateFirstTaskScreenState createState() => _CreateFirstTaskScreenState();
}

class _CreateFirstTaskScreenState extends State<CreateFirstTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedPrayer = 'Dhuhr';
  bool _isBefore = true;
  int _minutesOffset = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),

              Text(
                'Create Your First Task',
                style: AppTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),

              Text(
                'Try it out! Create a task using prayer-relative scheduling.',
                style: AppTheme.bodyLarge,
              ),
              SizedBox(height: 32),

              // Task title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Task',
                  hintText: 'e.g., Call mom',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Prayer-relative scheduling
              Text(
                'When:',
                style: AppTheme.titleMedium,
              ),
              SizedBox(height: 12),

              Row(
                children: [
                  // Before/After dropdown
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      value: _isBefore,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: true, child: Text('Before')),
                        DropdownMenuItem(value: false, child: Text('After')),
                      ],
                      onChanged: (value) {
                        setState(() => _isBefore = value!);
                      },
                    ),
                  ),
                  SizedBox(width: 12),

                  // Prayer dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPrayer,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']
                          .map((prayer) => DropdownMenuItem(
                                value: prayer,
                                child: Text(prayer),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedPrayer = value!);
                      },
                    ),
                  ),
                  SizedBox(width: 12),

                  // Minutes dropdown
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _minutesOffset,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [5, 10, 15, 30, 60]
                          .map((min) => DropdownMenuItem(
                                value: min,
                                child: Text('$min min'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _minutesOffset = value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Examples
              Text(
                'Examples:',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• "Call mom" before Dhuhr\n• "Buy groceries" after Maghrib',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),

              Spacer(),

              // Create button
              ElevatedButton(
                onPressed: _titleController.text.isEmpty ? null : _createTask,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
                child: Text('Create Task'),
              ),
              SizedBox(height: 16),

              // Skip button
              TextButton(
                onPressed: _skip,
                child: Text('I\'ll do this later'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    // Create the task
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleController.text,
      scheduleType: ScheduleType.prayerRelative,
      relatedPrayer: _selectedPrayer.toLowerCase(),
      isBeforePrayer: _isBefore,
      minutesOffset: _minutesOffset,
      createdAt: DateTime.now(),
    );

    await TodoService.addTask(task);

    // Show success and complete onboarding
    _completeOnboarding();
  }

  void _skip() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Mark onboarding as complete
    _setOnboardingComplete();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome to TaskFlow Pro! 🎉'),
        backgroundColor: AppTheme.success,
      ),
    );

    // Navigate to main app
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainLayout()),
      (route) => false,
    );
  }

  Future<void> _setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }
}
```

---

## Code Implementation

### Onboarding Flow Manager

**File: `lib/core/services/onboarding_service.dart`**

```dart
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _key = 'onboarding_complete';

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Mark onboarding as complete
  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Reset onboarding (for testing)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, false);
  }
}
```

---

### Main App Entry Point

**Update `lib/main.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/onboarding_service.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Error handling (Crashlytics)
  // ... (existing error handlers)

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow Pro',
      theme: ThemeData(/* your theme */),
      home: FutureBuilder<bool>(
        future: OnboardingService.hasCompletedOnboarding(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final hasCompleted = snapshot.data ?? false;

          if (hasCompleted) {
            // User has completed onboarding, go to main app
            return MainLayout();
          } else {
            // Show onboarding
            return WelcomeScreen();
          }
        },
      ),
    );
  }
}
```

---

## Testing Onboarding

### Manual Testing Checklist

**First-Time User Flow:**
- [ ] App launches to Welcome Screen (not Dashboard)
- [ ] "Get Started" → Value Proposition screens
- [ ] Swipe through all 4 feature highlights
- [ ] Page indicators update correctly
- [ ] "Next" button changes to "Get Started" on last page
- [ ] Location permission requested correctly
- [ ] Prayer times display for user's location
- [ ] Notification permission requested
- [ ] First task creation works
- [ ] After completion → redirected to Dashboard
- [ ] Second launch → goes directly to Dashboard (onboarding skipped)

**Skip Flow:**
- [ ] "Skip" button on Welcome → goes to Dashboard
- [ ] "Skip" on features → goes to Dashboard
- [ ] "Skip for Now" on notifications → continues onboarding
- [ ] Skipped permissions can be granted later in Settings

**Permission Handling:**
- [ ] Location denied → manual location selection works
- [ ] Notification denied → app continues without errors
- [ ] Permissions can be granted later from Settings

---

### Reset Onboarding (Testing)

**Add to Settings screen:**

```dart
// In SettingsScreen (DEBUG mode only)
#if DEBUG
ListTile(
  leading: Icon(Icons.restart_alt),
  title: Text('Reset Onboarding (Debug)'),
  onTap: () async {
    await OnboardingService.resetOnboarding();
    // Restart app
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
      (route) => false,
    );
  },
),
#endif
```

---

## Analytics & Optimization

### Track Onboarding Metrics

**Key Events to Track:**

```dart
// Track onboarding start
await FirebaseAnalytics.instance.logEvent(
  name: 'onboarding_started',
);

// Track screen views
await FirebaseAnalytics.instance.logScreenView(
  screenName: 'onboarding_welcome',
);

// Track completion
await FirebaseAnalytics.instance.logEvent(
  name: 'onboarding_completed',
  parameters: {
    'completed_task': createdFirstTask,
    'granted_location': hasLocationPermission,
    'granted_notifications': hasNotificationPermission,
  },
);

// Track skip
await FirebaseAnalytics.instance.logEvent(
  name: 'onboarding_skipped',
  parameters: {
    'skipped_at_screen': 'welcome', // or 'features', 'permissions', etc.
  },
);
```

---

### Metrics to Monitor

| Metric | Target | How to Measure |
|--------|--------|----------------|
| **Completion Rate** | > 80% | Users who finish vs skip |
| **Drop-off Points** | < 10% per screen | Where users abandon |
| **Time to Complete** | 30-60 seconds | Average duration |
| **Permission Grant Rate** | > 70% | Location + Notifications |
| **First Task Created** | > 50% | Users who create task in onboarding |

---

### A/B Testing Ideas

**Test Different Approaches:**

1. **Screen Order**: Location first vs Features first
2. **Copy**: Different taglines/descriptions
3. **Visuals**: Illustrations vs Screenshots
4. **Length**: 3 screens vs 5 screens
5. **First Task**: Required vs Optional

**Implementation:**
```dart
// Use remote config or feature flags
final variant = RemoteConfig.instance.getString('onboarding_variant');

if (variant == 'short') {
  return ShortOnboardingFlow();
} else {
  return StandardOnboardingFlow();
}
```

---

## Best Practices

### Do's ✅

- **Keep it short**: 3-5 screens maximum
- **Show value first**: Features before permissions
- **Use real data**: Actual prayer times, not placeholders
- **Make it skippable**: Let users explore on their own
- **Request permissions in context**: Explain WHY you need them
- **Interactive tutorial**: Let users DO something (create task)
- **Celebrate completion**: Positive reinforcement

### Don'ts ❌

- **Don't overwhelm**: Too many screens or features
- **Don't hide skip**: Let users choose
- **Don't request all permissions upfront**: Ask in context
- **Don't use lorem ipsum**: Real, meaningful content
- **Don't block progress**: Make everything optional
- **Don't be boring**: Engaging copy and visuals

---

## Onboarding Checklist

### Implementation:
- [ ] WelcomeScreen created
- [ ] ValuePropositionScreen with PageView
- [ ] LocationPermissionScreen
- [ ] NotificationPermissionScreen
- [ ] PrayerTimesPreviewScreen
- [ ] CreateFirstTaskScreen
- [ ] OnboardingService implemented
- [ ] main.dart routing based on onboarding status

### Testing:
- [ ] First launch shows onboarding
- [ ] All screens navigate correctly
- [ ] Skip button works
- [ ] Permissions requested properly
- [ ] First task creation works
- [ ] Second launch skips onboarding
- [ ] Reset works for testing

### Analytics:
- [ ] Onboarding start event
- [ ] Screen view events
- [ ] Completion event
- [ ] Skip events
- [ ] Permission grant tracking

### Polish:
- [ ] Smooth animations
- [ ] Consistent branding
- [ ] Clear, concise copy
- [ ] Beautiful illustrations/icons
- [ ] Loading states handled
- [ ] Error states handled

---

## Summary

**Onboarding Flow:**
1. Welcome → 2. Features → 3. Location → 4. Notifications → 5. Prayer Times → 6. First Task → Dashboard

**Time to Complete**: 30-60 seconds
**Skip Available**: Yes, at every step
**Completion Target**: 80%+

**Key Principles:**
- Show value before asking for permissions
- Make it interactive and engaging
- Keep it short and sweet
- Let users skip if they want
- Use real data (actual prayer times)

---

**Your users' first experience will set the tone. Make it count!** 🎉
