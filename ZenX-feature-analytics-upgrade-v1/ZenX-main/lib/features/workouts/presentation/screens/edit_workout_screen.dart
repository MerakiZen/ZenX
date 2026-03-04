import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/base_screen.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/network/graphql_client.dart';
import '../../../home/presentation/providers/feed_providers.dart';
import '../../data/services/feed_post_service.dart';

/// Edit workout screen (Hevy Pro style)
class EditWorkoutScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const EditWorkoutScreen({
    super.key,
    required this.workoutId,
  });

  @override
  ConsumerState<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  File? _selectedImage;
  String _caption = '';
  bool _isUploading = false;
  final _imagePicker = ImagePicker();
  final _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _savePost(BuildContext context) async {
    setState(() => _isUploading = true);
    try {
      final gqlClient = ref.read(graphqlClientProvider);
      final service = FeedPostService(gqlClient);

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await service.uploadImage(_selectedImage!);
      }

      // For now we use the workoutId as the postId since EnsureFeedPost
      // creates posts with the same ID pattern. In a future iteration we could
      // fetch the actual post ID.
      final postId = widget.workoutId;

      await service.updateFeedPost(
        postId: postId,
        caption: _captionController.text.isNotEmpty
            ? _captionController.text
            : null,
        imageUrl: imageUrl,
      );

      // Invalidate feed cache so the changes appear immediately.
      ref.invalidate(homeFeedProvider);
      ref.invalidate(discoverFeedProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post updated!'),
            backgroundColor: HevyColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save post: $e'),
            backgroundColor: HevyColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final padding = isSmallScreen ? 12.0 : DesignTokens.paddingScreen;

    return Scaffold(
      backgroundColor: HevyColors.background,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: HevyColors.primary,
              fontSize: DesignTokens.bodyMedium,
            ),
          ),
        ),
        title: const Text(
          'Edit Post',
          style: TextStyle(
            fontSize: DesignTokens.titleLarge,
            fontWeight: FontWeight.w600,
            color: HevyColors.textPrimary,
          ),
        ),
        backgroundColor: HevyColors.background,
        elevation: 0,
        actions: [
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: () => _savePost(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spacingM,
                  vertical: DesignTokens.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: HevyColors.primary,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: DesignTokens.bodyMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: HevyColors.border, height: 1),
            // Photo section
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacingS),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Change photo'),
                          style: TextButton.styleFrom(
                            foregroundColor: HevyColors.primary,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => setState(() => _selectedImage = null),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Remove'),
                          style: TextButton.styleFrom(
                            foregroundColor: HevyColors.error,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : DesignTokens.spacingM),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: HevyColors.border,
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                          color: HevyColors.surfaceElevated,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: HevyColors.textSecondary,
                              size: isSmallScreen ? 24 : DesignTokens.iconLarge,
                            ),
                            SizedBox(width: isSmallScreen ? 10 : DesignTokens.spacingM),
                            Flexible(
                              child: Text(
                                'Add a photo',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                                  color: HevyColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(color: HevyColors.border, height: 1),
            // Caption section
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Caption',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : DesignTokens.bodySmall,
                      color: HevyColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacingS),
                  TextField(
                    controller: _captionController,
                    maxLines: 4,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                      color: HevyColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write a caption for your workout...', 
                      hintStyle: TextStyle(
                        color: HevyColors.textSecondary,
                        fontSize: isSmallScreen ? 13 : DesignTokens.bodyMedium,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                        borderSide: const BorderSide(color: HevyColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                        borderSide: const BorderSide(color: HevyColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                        borderSide: const BorderSide(color: HevyColors.primary),
                      ),
                      filled: true,
                      fillColor: HevyColors.surfaceElevated,
                    ),
                    onChanged: (v) => _caption = v,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
