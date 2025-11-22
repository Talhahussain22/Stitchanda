import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload profile image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      print('Starting image upload for user: ${user.uid}');

      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      print('Image file exists, size: ${await imageFile.length()} bytes');

      // Create a unique file name with timestamp
      final String fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child('customer_profiles/$fileName');

      print('Uploading to path: customer_profiles/$fileName');

      // Set metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload the file with metadata
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() => print('Upload complete'));

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Download URL obtained: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage Error: ${e.code} - ${e.message}');

      // Provide user-friendly error messages
      switch (e.code) {
        case 'unauthorized':
          throw Exception('You do not have permission to upload images. Please check Firebase Storage rules.');
        case 'canceled':
          throw Exception('Upload was cancelled.');
        case 'unknown':
          throw Exception('An unknown error occurred. Please check your internet connection and try again.');
        case 'object-not-found':
          throw Exception('File not found.');
        case 'quota-exceeded':
          throw Exception('Storage quota exceeded.');
        case 'unauthenticated':
          throw Exception('Please sign in again to upload images.');
        default:
          throw Exception('Upload failed: ${e.message ?? e.code}');
      }
    } catch (e) {
      print('General error uploading image: $e');
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  /// Delete old profile image from storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;

      print('Attempting to delete old image: $imageUrl');

      // Extract the file path from URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();

      print('Old image deleted successfully');
    } catch (e) {
      // Silently fail if image doesn't exist or can't be deleted
      print('Failed to delete old image: $e');
    }
  }
}

