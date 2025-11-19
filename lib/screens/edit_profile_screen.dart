import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../core/services/auth_service.dart';
import '../core/helpers/logger.dart';
import '../core/helpers/analytics_helper.dart';
import '../core/helpers/permission_helper.dart';
import '../core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  File? _selectedImage;
  bool _isLoading = false;
  String? _currentPhotoURL;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _currentPhotoURL = user?.photoURL;

    AnalyticsHelper.logScreenView('edit_profile');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Check permissions
      bool hasPermission = false;
      if (source == ImageSource.camera) {
        hasPermission = await PermissionHelper.hasCameraPermission();
        if (!hasPermission) {
          hasPermission = await PermissionHelper.requestCameraPermission();
        }
      } else {
        hasPermission = await PermissionHelper.hasGalleryPermission();
        if (!hasPermission) {
          hasPermission = await PermissionHelper.requestGalleryPermission();
        }
      }

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                source == ImageSource.camera
                    ? 'Camera permission is required'
                    : 'Gallery permission is required',
              ),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        Logger.info('Profile image selected', tag: 'EditProfile');
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to pick image',
        error: e,
        stackTrace: stackTrace,
        tag: 'EditProfile',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.primary),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_currentPhotoURL != null || _selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.error),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _currentPhotoURL = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String newName = _nameController.text.trim();

      // Update display name
      if (newName.isNotEmpty && newName != AuthService.currentUser?.displayName) {
        await AuthService.updateProfile(displayName: newName);
        Logger.success('Profile name updated', tag: 'EditProfile');
      }

      // Upload and update photo if selected
      if (_selectedImage != null) {
        // For now, we'll store the local path
        // In production, upload to Firebase Storage or similar
        final photoURL = _selectedImage!.path;
        await AuthService.updateProfile(photoURL: photoURL);
        Logger.success('Profile photo updated', tag: 'EditProfile');
      } else if (_currentPhotoURL == null && AuthService.currentUser?.photoURL != null) {
        // Remove photo
        await AuthService.updateProfile(photoURL: null);
        Logger.success('Profile photo removed', tag: 'EditProfile');
      }

      AnalyticsHelper.logEvent('profile_updated');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to update profile',
        error: e,
        stackTrace: stackTrace,
        tag: 'EditProfile',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (_currentPhotoURL != null
                      ? NetworkImage(_currentPhotoURL!) as ImageProvider
                      : null),
              child: (_selectedImage == null && _currentPhotoURL == null)
                  ? Icon(
                      Icons.person,
                      size: 60,
                      color: AppTheme.primary.withOpacity(0.5),
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppTheme.headlineMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  )
                : Text(
                    'Save',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar Section
            _buildAvatarSection(),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Change Photo'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Name Field
            Text(
              'Display Name',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide(color: AppTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide(color: AppTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Email Field (Read-only)
            Text(
              'Email Address',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide(color: AppTheme.borderLight),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide(color: AppTheme.borderLight),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: Tooltip(
                  message: 'Email cannot be changed here',
                  child: Icon(
                    Icons.info_outline,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Email address cannot be changed from here',
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
