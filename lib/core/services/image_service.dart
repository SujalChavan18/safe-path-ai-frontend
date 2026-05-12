import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Image picking service for SafePath AI.
///
/// Wraps [ImagePicker] to provide a typed interface for
/// capturing photos or selecting from the gallery.
class ImageService {
  ImageService._();

  static final ImageService instance = ImageService._();

  final ImagePicker _picker = ImagePicker();

  /// Pick a single image from the camera.
  ///
  /// Returns the file path, or `null` if cancelled.
  Future<File?> pickFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth ?? 1920,
        maxHeight: maxHeight ?? 1080,
        imageQuality: imageQuality ?? 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('ImageService.pickFromCamera error: $e');
      return null;
    }
  }

  /// Pick a single image from the gallery.
  ///
  /// Returns the file, or `null` if cancelled.
  Future<File?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth ?? 1920,
        maxHeight: maxHeight ?? 1080,
        imageQuality: imageQuality ?? 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('ImageService.pickFromGallery error: $e');
      return null;
    }
  }

  /// Pick multiple images from the gallery.
  ///
  /// Returns a list of files (empty list if cancelled).
  Future<List<File>> pickMultipleFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth ?? 1920,
        maxHeight: maxHeight ?? 1080,
        imageQuality: imageQuality ?? 85,
        limit: limit,
      );
      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('ImageService.pickMultipleFromGallery error: $e');
      return [];
    }
  }
}
