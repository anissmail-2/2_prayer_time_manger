import 'package:flutter/material.dart';
import '../core/helpers/logger.dart';
import '../core/helpers/analytics_helper.dart';
import '../core/theme/app_theme.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'en_US'; // Default language

  final List<LanguageOption> _languages = [
    LanguageOption(
      code: 'en_US',
      name: 'English (US)',
      nativeName: 'English',
      flag: '🇺🇸',
      isAvailable: true,
    ),
    LanguageOption(
      code: 'ar_AE',
      name: 'Arabic (UAE)',
      nativeName: 'العربية',
      flag: '🇦🇪',
      isAvailable: false,
    ),
    LanguageOption(
      code: 'fr_FR',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
      isAvailable: false,
    ),
    LanguageOption(
      code: 'es_ES',
      name: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
      isAvailable: false,
    ),
    LanguageOption(
      code: 'de_DE',
      name: 'German',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
      isAvailable: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView('language_settings');
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    // TODO: Load saved language preference
    // For now, default to English
    setState(() {
      _selectedLanguage = 'en_US';
    });
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    // TODO: Save language preference and apply localization
    setState(() {
      _selectedLanguage = languageCode;
    });

    Logger.info('Language preference saved: $languageCode', tag: 'LanguageSettings');
    AnalyticsHelper.logEvent(name: 'language_changed', parameters: {'language': languageCode});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language will be applied in future update'),
          backgroundColor: AppTheme.info,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Language Settings',
          style: AppTheme.headlineMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.info,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Multi-language support is coming soon. Currently only English is available.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language Selection
          Text(
            'Select Language',
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Language List
          ..._languages.map((language) {
            final isSelected = _selectedLanguage == language.code;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.borderLight,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                enabled: language.isAvailable,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 32),
                ),
                title: Text(
                  language.name,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: language.isAvailable
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
                subtitle: Text(
                  language.nativeName,
                  style: AppTheme.bodyMedium.copyWith(
                    color: language.isAvailable
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondary.withOpacity(0.5),
                  ),
                ),
                trailing: language.isAvailable
                    ? (isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppTheme.primary,
                            size: 28,
                          )
                        : null)
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                onTap: language.isAvailable
                    ? () => _saveLanguagePreference(language.code)
                    : null,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isAvailable;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.isAvailable,
  });
}
