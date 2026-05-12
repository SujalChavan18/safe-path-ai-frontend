import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_dimensions.dart';

/// Simulated image picker UI for incident reporting.
class ImagePickerField extends StatefulWidget {
  const ImagePickerField({super.key});

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  bool _hasImage = false;

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.surfaceVariant,
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Take a photo', style: TextStyle(color: AppColors.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _simulateUpload();
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.surfaceVariant,
                  child: Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: const Text('Choose from gallery', style: TextStyle(color: AppColors.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  _simulateUpload();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateUpload() {
    // In a real app, this would use image_picker
    setState(() => _hasImage = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasImage) {
      return Stack(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              image: const DecorationImage(
                // Placeholder image for the mockup
                image: NetworkImage('https://picsum.photos/400/200'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _hasImage = false),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _showPickerOptions,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppColors.outline,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_rounded,
              size: 32,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppDimensions.space8),
            Text(
              'Add a photo (Optional)',
              style: TextStyle(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
