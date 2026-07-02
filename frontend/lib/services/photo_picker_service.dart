// lib/services/photo_picker_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

/// Picks an image and returns its bytes. Uses `file_picker`, which works across
/// mobile, web AND desktop (macOS/Windows/Linux) — unlike `image_picker`, whose
/// gallery source is unsupported on macOS.
class PhotoPickerService {
  Future<Uint8List?> pickImageFromGallery() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true, // load bytes directly (needed on web; convenient on desktop)
      );
      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      if (file.bytes != null) return file.bytes;
      if (file.path != null) return await File(file.path!).readAsBytes();
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }
}
