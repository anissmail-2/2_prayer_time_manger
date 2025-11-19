import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/location_service.dart';
import '../../core/helpers/logger.dart';
import '../../models/location_settings.dart';
import 'notification_permission_screen.dart';

class ManualLocationScreen extends StatefulWidget {
  const ManualLocationScreen({super.key});

  @override
  State<ManualLocationScreen> createState() => _ManualLocationScreenState();
}

class _ManualLocationScreenState extends State<ManualLocationScreen> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  bool _isLoading = false;

  // Common cities for quick selection
  final List<Map<String, String>> _popularCities = const [
    {'city': 'Abu Dhabi', 'country': 'United Arab Emirates'},
    {'city': 'Dubai', 'country': 'United Arab Emirates'},
    {'city': 'Riyadh', 'country': 'Saudi Arabia'},
    {'city': 'Mecca', 'country': 'Saudi Arabia'},
    {'city': 'Medina', 'country': 'Saudi Arabia'},
    {'city': 'London', 'country': 'United Kingdom'},
    {'city': 'New York', 'country': 'United States'},
    {'city': 'Toronto', 'country': 'Canada'},
    {'city': 'Cairo', 'country': 'Egypt'},
    {'city': 'Kuala Lumpur', 'country': 'Malaysia'},
  ];

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Location'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Choose Your City',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),

              Text(
                'Select a city for accurate prayer times',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),

              // Manual input
              Text(
                'Enter Manually',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  hintText: 'e.g., Abu Dhabi',
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: 'Country',
                  hintText: 'e.g., United Arab Emirates',
                  prefixIcon: const Icon(Icons.public),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Confirm button for manual input
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveManualLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirm Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Divider
              const Divider(),
              const SizedBox(height: 16),

              // Popular cities
              Text(
                'Or Choose a Popular City',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),

              // Popular cities list
              ..._popularCities.map((city) => _buildCityTile(
                    city['city']!,
                    city['country']!,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityTile(String city, String country) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.location_city,
            color: AppTheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          city,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(country),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectCity(city, country),
      ),
    );
  }

  Future<void> _saveManualLocation() async {
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();

    if (city.isEmpty || country.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both city and country'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await _selectCity(city, country);
  }

  Future<void> _selectCity(String city, String country) async {
    setState(() => _isLoading = true);

    try {
      // Save location settings
      final locationSettings = LocationSettings(
        customCity: city,
        customCountry: country,
        useGPS: false,
      );

      await LocationService.saveLocationSettings(locationSettings);

      Logger.success(
        'Location set to: $city, $country',
        tag: 'ManualLocation',
      );

      if (mounted) {
        // Proceed to next screen
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const NotificationPermissionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              return SlideTransition(
                position: animation.drive(tween),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to save location',
        error: e,
        stackTrace: stackTrace,
        tag: 'ManualLocation',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save location. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
