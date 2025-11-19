import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../core/services/data_sync_service.dart';
import '../core/helpers/logger.dart';
import '../core/helpers/analytics_helper.dart';
import '../core/helpers/storage_helper.dart';
import '../core/theme/app_theme.dart';

class SyncSettingsScreen extends StatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  State<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends State<SyncSettingsScreen> {
  bool _autoSyncEnabled = true;
  bool _wifiOnlySync = false;
  String _conflictResolution = 'newest'; // newest, local, remote
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView('sync_settings');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Load sync settings from storage
      final autoSync = await StorageHelper.getBool('auto_sync_enabled') ?? true;
      final wifiOnly = await StorageHelper.getBool('wifi_only_sync') ?? false;
      final conflict =
          await StorageHelper.getString('conflict_resolution') ?? 'newest';
      final lastSync = await StorageHelper.getString('last_sync_time');

      setState(() {
        _autoSyncEnabled = autoSync;
        _wifiOnlySync = wifiOnly;
        _conflictResolution = conflict;
        if (lastSync != null) {
          _lastSyncTime = DateTime.tryParse(lastSync);
        }
      });
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to load sync settings',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncSettings',
      );
    }
  }

  Future<void> _saveSettings() async {
    try {
      await StorageHelper.saveBool('auto_sync_enabled', _autoSyncEnabled);
      await StorageHelper.saveBool('wifi_only_sync', _wifiOnlySync);
      await StorageHelper.saveString('conflict_resolution', _conflictResolution);

      Logger.success('Sync settings saved', tag: 'SyncSettings');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to save sync settings',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncSettings',
      );
    }
  }

  Future<void> _performManualSync() async {
    if (!FirebaseService.isConfigured || !FirebaseService.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloud sync is not configured'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      await DataSyncService.syncAllData();

      setState(() {
        _lastSyncTime = DateTime.now();
        _isSyncing = false;
      });

      await StorageHelper.saveString(
        'last_sync_time',
        _lastSyncTime!.toIso8601String(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }

      AnalyticsHelper.logEvent('manual_sync_completed');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to sync data',
        error: e,
        stackTrace: stackTrace,
        tag: 'SyncSettings',
      );

      setState(() {
        _isSyncing = false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSyncAvailable =
        FirebaseService.isConfigured && FirebaseService.isInitialized;

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
          'Sync Settings',
          style: AppTheme.headlineMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSyncAvailable
                  ? AppTheme.success.withOpacity(0.1)
                  : AppTheme.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: isSyncAvailable
                    ? AppTheme.success.withOpacity(0.3)
                    : AppTheme.warning.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  isSyncAvailable ? Icons.cloud_done : Icons.cloud_off,
                  size: 48,
                  color: isSyncAvailable ? AppTheme.success : AppTheme.warning,
                ),
                const SizedBox(height: 12),
                Text(
                  isSyncAvailable ? 'Sync Available' : 'Sync Not Configured',
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSyncAvailable
                      ? (_lastSyncTime != null
                          ? 'Last synced: ${_getTimeAgo(_lastSyncTime!)}'
                          : 'Never synced')
                      : 'Enable Firebase in settings to use cloud sync',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isSyncAvailable) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSyncing ? null : _performManualSync,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.sync),
                      label: Text(
                        _isSyncing ? 'Syncing...' : 'Sync Now',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Auto Sync
          Text(
            'Sync Options',
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto Sync'),
                  subtitle: const Text('Automatically sync data in background'),
                  value: _autoSyncEnabled,
                  activeColor: AppTheme.primary,
                  onChanged: isSyncAvailable
                      ? (value) {
                          setState(() {
                            _autoSyncEnabled = value;
                          });
                          _saveSettings();
                        }
                      : null,
                ),
                Divider(height: 1, color: AppTheme.borderLight),
                SwitchListTile(
                  title: const Text('Wi-Fi Only'),
                  subtitle: const Text('Sync only when connected to Wi-Fi'),
                  value: _wifiOnlySync,
                  activeColor: AppTheme.primary,
                  onChanged: isSyncAvailable && _autoSyncEnabled
                      ? (value) {
                          setState(() {
                            _wifiOnlySync = value;
                          });
                          _saveSettings();
                        }
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Conflict Resolution
          Text(
            'Conflict Resolution',
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how to handle conflicts when data differs between devices',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Newest Wins'),
                  subtitle: const Text('Use most recently modified version'),
                  value: 'newest',
                  groupValue: _conflictResolution,
                  activeColor: AppTheme.primary,
                  onChanged: isSyncAvailable
                      ? (value) {
                          if (value != null) {
                            setState(() {
                              _conflictResolution = value;
                            });
                            _saveSettings();
                          }
                        }
                      : null,
                ),
                Divider(height: 1, color: AppTheme.borderLight),
                RadioListTile<String>(
                  title: const Text('Local Priority'),
                  subtitle: const Text('Always keep local data'),
                  value: 'local',
                  groupValue: _conflictResolution,
                  activeColor: AppTheme.primary,
                  onChanged: isSyncAvailable
                      ? (value) {
                          if (value != null) {
                            setState(() {
                              _conflictResolution = value;
                            });
                            _saveSettings();
                          }
                        }
                      : null,
                ),
                Divider(height: 1, color: AppTheme.borderLight),
                RadioListTile<String>(
                  title: const Text('Remote Priority'),
                  subtitle: const Text('Always use cloud data'),
                  value: 'remote',
                  groupValue: _conflictResolution,
                  activeColor: AppTheme.primary,
                  onChanged: isSyncAvailable
                      ? (value) {
                          if (value != null) {
                            setState(() {
                              _conflictResolution = value;
                            });
                            _saveSettings();
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),

          if (!isSyncAvailable) ...[
            const SizedBox(height: 24),
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
                      'Cloud sync requires Firebase configuration. '
                      'The app currently works in offline mode with local storage.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
