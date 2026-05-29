import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum LapinPhotoError { tooLarge }

class LapinPhotoException implements Exception {
  final LapinPhotoError error;

  const LapinPhotoException(this.error);
}

class LapinPhotoService {
  static const int maxBytes = 200 * 1024;

  final SupabaseClient supabase;
  final ImagePicker _picker;
  final ImageCropper _cropper;

  LapinPhotoService({
    required this.supabase,
    ImagePicker? picker,
    ImageCropper? cropper,
  })  : _picker = picker ?? ImagePicker(),
        _cropper = cropper ?? ImageCropper();

  Future<String?> pickCropAndValidate({
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (picked == null) return null;

    final cropped = await _cropper.cropImage(
      sourcePath: picked.path,
      compressQuality: 80,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer',
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Recadrer',
        ),
      ],
    );
    if (cropped == null) return null;

    final file = File(cropped.path);
    final size = await file.length();
    if (size > maxBytes) {
      throw const LapinPhotoException(LapinPhotoError.tooLarge);
    }
    return cropped.path;
  }

  Future<String> uploadLapinPhoto({
    required String lapinId,
    required String filePath,
  }) async {
    final bucket = supabase.storage.from('lapins');
    final path = '$lapinId.jpg';

    await bucket.upload(
      path,
      File(filePath),
      fileOptions: const FileOptions(
        upsert: true,
        contentType: 'image/jpeg',
      ),
    );

    return bucket.getPublicUrl(path);
  }
}
