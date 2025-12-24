import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../providers/profile_providers.dart';

/// Edit Profile screen (Hevy style)
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  String _selectedSex = 'Prefer not to say';
  String? _selectedBirthday;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: HevyColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusXL),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HevyColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: HevyColors.textPrimary),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: HevyColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: HevyColors.textPrimary),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(color: HevyColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: HevyColors.error),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: HevyColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImage = null;
                    });
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showGenderSelector() {
    final genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: HevyColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusXL),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HevyColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingL,
                    vertical: DesignTokens.spacingM),
                child: Text(
                  'Select Gender',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: HevyColors.textPrimary,
                      ),
                ),
              ),
              ...genders.map((gender) => ListTile(
                    title: Text(
                      gender,
                      style: TextStyle(
                        color: _selectedSex == gender
                            ? HevyColors.primary
                            : HevyColors.textPrimary,
                        fontWeight: _selectedSex == gender
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: _selectedSex == gender
                        ? const Icon(Icons.check, color: HevyColors.primary)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedSex = gender;
                      });
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _initializeProfile(ProfileDetails profile) {
    if (_initialized) return;
    _nameController.text = profile.displayName ?? '';
    _bioController.text = profile.bio ?? '';
    _selectedSex = profile.gender ?? 'Prefer not to say';
    _selectedBirthday = profile.dateOfBirth;
    _initialized = true;
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(profileControllerProvider).updateProfile(
            displayName: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            gender: _selectedSex == 'Prefer not to say' ? null : _selectedSex,
            dateOfBirth: _selectedBirthday,
          );
      if (!mounted) return;
      context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatIsoDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _displayBirthday(String iso) {
    try {
      final date = DateTime.parse(iso);
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    } catch (_) {
      return iso;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: const Text('Edit Profile'),
      titleTextStyle: const TextStyle(
        fontSize: DesignTokens.titleLarge,
        fontWeight: FontWeight.w600,
        color: HevyColors.textPrimary,
      ),
      backgroundColor: HevyColors.background,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: _isSaving ? null : _submit,
          child: const Text(
            'Done',
            style: TextStyle(
              color: HevyColors.primary,
              fontSize: DesignTokens.bodyLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileViewProvider);
    return profileAsync.when(
      loading: () => Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: _buildAppBar(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load profile: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (data) {
        _initializeProfile(data.profile);
        return Scaffold(
          appBar: _buildAppBar(context),
          body: buildBody(context, ref),
        );
      },
    );
  }

  Widget buildBody(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: DesignTokens.spacingL),

          // Profile picture
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: HevyColors.surfaceElevated,
                      border: Border.all(
                        color: HevyColors.border,
                        width: 2,
                      ),
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: DesignTokens.iconXLarge, // 48dp (max size)
                            color: HevyColors.textSecondary,
                          ),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingS),
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: const Text(
                    'Change Picture',
                    style: TextStyle(
                      color: HevyColors.primary,
                      fontSize: DesignTokens.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // Public profile data section
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Public profile data',
                  style: TextStyle(
                    fontSize: DesignTokens.bodySmall,
                    fontWeight: FontWeight.w600,
                    color: HevyColors.textSecondary,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingM),

                // Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: DesignTokens.bodyLarge,
                        color: HevyColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: HevyColors.textPrimary),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: HevyColors.border),

                // Bio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: DesignTokens.spacingS),
                      child: Text(
                        'Bio',
                        style: TextStyle(
                          fontSize: DesignTokens.bodyLarge,
                          color: HevyColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _bioController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: HevyColors.textTertiary),
                        decoration: const InputDecoration(
                          hintText: 'Describe yourself',
                          hintStyle: TextStyle(color: HevyColors.textTertiary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: HevyColors.border),

                // Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Link',
                      style: TextStyle(
                        fontSize: DesignTokens.bodyLarge,
                        color: HevyColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _linkController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(color: HevyColors.textPrimary),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),

          // Private data section
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.paddingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Private data',
                      style: TextStyle(
                        fontSize: DesignTokens.bodySmall,
                        fontWeight: FontWeight.w600,
                        color: HevyColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.spacingXS),
                    GestureDetector(
                      onTap: () {
                        // TODO: Show info dialog
                      },
                      child: const Icon(
                        Icons.help_outline,
                        size: DesignTokens.iconSmall, // 16dp
                        color: HevyColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.spacingM),

                // Sex
                InkWell(
                  onTap: _showGenderSelector,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sex',
                        style: TextStyle(
                          fontSize: DesignTokens.bodyLarge,
                          color: HevyColors.textPrimary,
                        ),
                      ),
                      Text(
                        _selectedSex,
                        style: const TextStyle(
                          fontSize: DesignTokens.bodyLarge,
                          color: HevyColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: HevyColors.border),

                // Birthday
                InkWell(
                  onTap: () async {
                    DateTime initialDate =
                        DateTime.now().subtract(const Duration(days: 365 * 25));
                    if (_selectedBirthday != null &&
                        _selectedBirthday!.isNotEmpty) {
                      try {
                        initialDate = DateTime.parse(_selectedBirthday!);
                      } catch (_) {}
                    }

                    final date = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedBirthday = _formatIsoDate(date);
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Birthday',
                        style: TextStyle(
                          fontSize: DesignTokens.bodyLarge,
                          color: HevyColors.textPrimary,
                        ),
                      ),
                      Text(
                        _selectedBirthday != null
                            ? _displayBirthday(_selectedBirthday!)
                            : 'Select',
                        style: const TextStyle(
                          fontSize: DesignTokens.bodyLarge,
                          color: HevyColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: HevyColors.border),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spacingXL),
        ],
      ),
    );
  }
}
