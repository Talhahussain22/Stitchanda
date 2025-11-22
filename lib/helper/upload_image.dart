import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

final supabase = Supabase.instance.client;


Future<String?> uploadImageToSupabase({
  required String role,
  required String uid,
  required String type,
  required XFile? file,
}) async {
  try {
    // Expect caller to provide an already picked file (do not open picker here)
    if (file == null) return null;

    final f = File(file.path);

    // Build file path
    final filePath = '$role/$uid/$uid-$type.jpg';

    // Upload file to Supabase bucket
    await supabase.storage
        .from('app-images')
        .upload(filePath, f, fileOptions: FileOptions(upsert: true));

    // Get the public URL
    final publicUrl = supabase.storage
        .from('app-images')
        .getPublicUrl(filePath);

    return publicUrl;
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}
