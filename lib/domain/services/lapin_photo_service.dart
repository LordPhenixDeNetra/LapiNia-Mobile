import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/app_logger.dart';

enum LapinPhotoError { tooLarge }

class LapinPhotoException implements Exception {
  final LapinPhotoError error;

  const LapinPhotoException(this.error);
}

class LapinPhotoService {
  static const int maxBytes = 200 * 1024;

  final SupabaseClient supabase;
  final AppConfig config;
  final ImagePicker _picker;
  bool _isBusy = false;

  LapinPhotoService({
    required this.supabase,
    required this.config,
    ImagePicker? picker,
  })  : _picker = picker ?? ImagePicker(),
        super();

  Future<String?> pickCropAndValidate({
    required ImageSource source,
  }) async {
    if (_isBusy) return null;
    _isBusy = true;
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 60,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null) return null;

      final file = File(picked.path);
      final size = await file.length();
      if (size > maxBytes) {
        throw const LapinPhotoException(LapinPhotoError.tooLarge);
      }
      return picked.path;
    } finally {
      _isBusy = false;
    }
  }

  Future<String> uploadLapinPhoto({
    required String userId,
    required String lapinId,
    required String filePath,
  }) async {
    final bucket = supabase.storage.from('lapins');
    final path = '$userId/$lapinId.jpg';
    final token = supabase.auth.currentSession?.accessToken;

    AppLogger.info(
      'Storage upload lapin photo',
      data: {
        'bucket': 'lapins',
        'path': path,
        'authUserId': supabase.auth.currentUser?.id,
        'hasSession': (supabase.auth.currentSession?.accessToken.isNotEmpty ?? false),
        'userIdParamMatchesAuth': supabase.auth.currentUser?.id == userId,
      },
    );

    try {
      await bucket.upload(
        path,
        File(filePath),
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );
    } catch (e) {
      final raw = e.toString();
      final looksLikeRls = raw.contains('row-level security policy') ||
          raw.contains('statuscode: 403') ||
          raw.contains('statusCode: 403');

      if (!looksLikeRls) rethrow;

      if (token == null || token.isEmpty) {
        rethrow;
      }

      await _uploadViaHttp(
        token: token,
        path: path,
        filePath: filePath,
      );
    }

    return bucket.getPublicUrl(path);
  }

  Future<void> _uploadViaHttp({
    required String token,
    required String path,
    required String filePath,
  }) async {
    final base = config.supabaseUrl.endsWith('/')
        ? config.supabaseUrl.substring(0, config.supabaseUrl.length - 1)
        : config.supabaseUrl;
    final uri = Uri.parse('$base/storage/v1/object/lapins/$path');

    final file = File(filePath);
    final bytes = await file.readAsBytes();

    final client = HttpClient();
    try {
      client.connectionTimeout = const Duration(seconds: 10);

      final start = DateTime.now();
      int attempt = 0;
      while (true) {
        attempt++;
        try {
          final request = await client.postUrl(uri);
          request.headers.set('Authorization', 'Bearer $token');
          request.headers.set('apikey', config.supabaseAnonKey);
          request.headers.set('Content-Type', 'image/jpeg');
          request.headers.set('Accept', 'application/json');
          request.headers.set('x-upsert', 'true');
          request.contentLength = bytes.length;
          request.add(bytes);

          final response = await request
              .close()
              .timeout(const Duration(seconds: 60));
          if (response.statusCode >= 200 && response.statusCode < 300) {
            AppLogger.info(
              'Storage upload lapin photo (HTTP fallback) OK',
              data: {
                'path': path,
                'statusCode': response.statusCode,
                'attempt': attempt,
                'durationMs': DateTime.now().difference(start).inMilliseconds,
              },
            );
            return;
          }

          final body = await response.transform(utf8.decoder).join();
          final shouldRetry = (response.statusCode == 502 ||
                  response.statusCode == 503 ||
                  response.statusCode == 504) &&
              attempt < 3;
          if (!shouldRetry) {
            throw Exception('Storage upload failed (${response.statusCode}): $body');
          }
        } catch (e) {
          final shouldRetry = attempt < 3 &&
              (e is TimeoutException || e is SocketException);
          if (!shouldRetry) rethrow;
        }

        await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
      }
    } finally {
      client.close(force: true);
    }
  }
}
