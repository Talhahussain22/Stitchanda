import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';


Future<String?> uploadImageToSupabase({
  required String role,
  required String uid,
  required String type,
  required XFile? file,
}) async {
  try {
    // Expect caller to provide an already picked file (do not open picker here)
    if (file == null) {
      print('❌ Upload Error: No file provided');
      return null;
    }

    final f = File(file.path);

    // Verify file exists
    if (!await f.exists()) {
      print('❌ Upload Error: File does not exist at path: ${file.path}');
      return null;
    }

    // Get file size for logging
    final fileSize = await f.length();
    print('📤 Uploading image: ${fileSize} bytes');

    // Build file path with timestamp to avoid caching issues
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '$role/$uid/$uid-$type-$timestamp.jpg';

    print('📁 Upload path: $filePath');

    final client = Supabase.instance.client;

    // Upload file to Supabase bucket
    print('⏳ Starting upload to Supabase...');
    await client.storage
        .from('app-images')
        .upload(
          filePath,
          f,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    print('✅ Upload successful');

    // Get the public URL
    final publicUrl = client.storage
        .from('app-images')
        .getPublicUrl(filePath);

    print('🔗 Public URL: $publicUrl');

    if (publicUrl.isEmpty) {
      print('❌ Error: Public URL is empty');
      return null;
    }

    return publicUrl;
  } on StorageException catch (e) {
    print('❌ Supabase Storage Error: ${e.message}');
    print('Error details: ${e.statusCode}');
    return null;
  } catch (e) {
    print('❌ Error uploading image: $e');
    return null;
  }
}
