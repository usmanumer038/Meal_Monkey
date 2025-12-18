import 'dart:io' show File;
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class StorageService {
  static const String _bucketName = 'avatars';

  // Mobile/desktop: upload File
  static Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final fileName = 'profile_$userId.jpg';
      final path = fileName;
      await supabase.storage.from(_bucketName).upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      return supabase.storage.from(_bucketName).getPublicUrl(path);
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  // Web-safe upload using bytes (Uint8List)
  static Future<String?> uploadProfileImageBytes(
      Uint8List bytes, String userId) async {
    try {
      final fileName = 'profile_$userId.jpg';
      final path = fileName;
      await supabase.storage.from(_bucketName).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      return supabase.storage.from(_bucketName).getPublicUrl(path);
    } catch (e) {
      print('Upload error (bytes): $e');
      return null;
    }
  }

  static String? getProfileImageUrl(String userId) {
    try {
      final fileName = 'profile_$userId.jpg';
      return supabase.storage.from(_bucketName).getPublicUrl(fileName);
    } catch (e) {
      return null;
    }
  }
}