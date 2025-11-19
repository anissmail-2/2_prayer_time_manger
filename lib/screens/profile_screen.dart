import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../core/services/auth_service.dart';
import '../core/services/data_export_service.dart';
import '../core/helpers/analytics_helper.dart';
import '../core/helpers/logger.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_extensions.dart';
import '../widgets/animated_card.dart';
import 'notification_settings_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'language_settings_screen.dart';
import 'sync_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView('profile');
  }

  Future<void> _handleExportData() async {
    try {
      final filePath = await DataExportService.exportToFile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported to:\n${filePath.split('/').last}'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      AnalyticsHelper.logEvent(name: 'data_exported');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to export data',
        error: e,
        stackTrace: stackTrace,
        tag: 'Profile',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleImportData() async {
    try {
      // Pick a JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return; // User canceled
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        throw 'Failed to access file';
      }

      // Read file content
      final file = File(filePath);
      final jsonString = await file.readAsString();

      // Show confirmation dialog
      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Data'),
            content: const Text(
              'This will import data from the backup file. '
              'Existing data with the same IDs will be overwritten. '
              'Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
                child: const Text('Import'),
              ),
            ],
          ),
        );

        if (confirmed != true) {
          return;
        }
      }

      // Import data
      final importResult = await DataExportService.importData(jsonString);

      if (mounted) {
        // Show result dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  importResult.hasErrors ? Icons.warning : Icons.check_circle,
                  color: importResult.hasErrors ? AppTheme.warning : AppTheme.success,
                ),
                const SizedBox(width: 8),
                const Text('Import Complete'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('✓ ${importResult.tasksImported} tasks imported'),
                Text('✓ ${importResult.spacesImported} spaces imported'),
                Text('✓ ${importResult.activitiesImported} activities imported'),
                if (importResult.hasErrors) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Errors:',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...importResult.errors.map((error) => Text(
                        '• $error',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
                      )),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        AnalyticsHelper.logEvent(name: 'data_imported');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to import data',
        error: e,
        stackTrace: stackTrace,
        tag: 'Profile',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import data: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showDataExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file, color: AppTheme.primary),
              title: const Text('Export Data'),
              subtitle: const Text('Save your data to a file'),
              onTap: () {
                Navigator.pop(context);
                _handleExportData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: AppTheme.primary),
              title: const Text('Import Data'),
              subtitle: const Text('Restore data from a backup'),
              onTap: () {
                Navigator.pop(context);
                _handleImportData();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

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
          'Profile',
          style: AppTheme.headlineMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header with Gradient
          GradientCard(
            gradient: AppThemeExtensions.primaryGradient,
            child: Column(
              children: [
                // Avatar with gradient border
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppThemeExtensions.successGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: user != null && user.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              user.photoURL!,
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultAvatar(),
                            ),
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  user?.displayName ?? 'User',
                  style: AppTheme.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Email
                Text(
                  user?.email ?? 'Not signed in',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                // Account status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user != null ? Icons.check_circle : Icons.offline_bolt,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user != null ? 'Signed In' : 'Offline Mode',
                        style: AppTheme.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Account Settings Section
          _buildSectionHeader('Account Settings'),
          _buildSettingCard(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your name and photo',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
              // Refresh if profile was updated
              if (result == true && mounted) {
                setState(() {});
              }
            },
          ),
          _buildSettingCard(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: user?.email ?? 'Not available',
            onTap: null,
          ),
          _buildSettingCard(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          _buildSettingCard(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English (US)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingCard(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Data & Privacy Section
          _buildSectionHeader('Data & Privacy'),
          _buildSettingCard(
            icon: Icons.cloud_outlined,
            title: 'Sync Settings',
            subtitle: 'Manage cloud synchronization',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SyncSettingsScreen(),
                ),
              );
            },
          ),
          _buildSettingCard(
            icon: Icons.download_outlined,
            title: 'Export/Import Data',
            subtitle: 'Backup or restore your data',
            onTap: () {
              _showDataExportDialog();
            },
          ),
          _buildSettingCard(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            textColor: AppTheme.error,
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),

          const SizedBox(height: 24),

          // Sign Out Button
          if (user != null)
            ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  await AuthService.signOut();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 48,
      color: AppTheme.primary,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppTheme.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    final isError = textColor == AppTheme.error;
    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: isError
                ? AppThemeExtensions.errorGradient
                : LinearGradient(
                    colors: [
                      (textColor ?? AppTheme.primary),
                      (textColor ?? AppTheme.primary).withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: (textColor ?? AppTheme.primary).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: onTap != null
            ? Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: (textColor ?? AppTheme.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: textColor ?? AppTheme.primary,
                  size: 18,
                ),
              )
            : null,
      ),
    );
  }

  Future<void> _handleDeleteAccount() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Deleting account...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Clear all app data
      await DataExportService.clearAllData();

      // Delete Firebase auth account if signed in
      if (AuthService.isLoggedIn) {
        try {
          await AuthService.deleteAccount();
        } catch (e) {
          Logger.warning(
            'Failed to delete Firebase account, but local data was cleared: $e',
            tag: 'Profile',
          );
        }
      }

      Logger.success('Account and all data deleted', tag: 'Profile');
      AnalyticsHelper.logEvent(name: 'account_deleted');

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account and all data have been deleted'),
            backgroundColor: AppTheme.success,
          ),
        );

        // Go back to previous screen
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to delete account',
        error: e,
        stackTrace: stackTrace,
        tag: 'Profile',
      );

      if (mounted) {
        // Close loading dialog if it's showing
        Navigator.pop(context);

        String errorMessage = 'Failed to delete account';
        if (e.toString().contains('requires-recent-login')) {
          errorMessage =
              'Please sign in again to delete your account. Your local data has been cleared.';
          // Clear local data anyway
          await DataExportService.clearAllData();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('• All tasks and activities'),
            const Text('• All spaces and projects'),
            const Text('• All settings and preferences'),
            const Text('• Your account (if signed in)'),
            const SizedBox(height: 12),
            const Text('Are you sure you want to continue?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleDeleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
