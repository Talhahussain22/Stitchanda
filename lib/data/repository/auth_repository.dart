import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login with email/password and return the domain model
  Future<CustomerModel> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = _auth.currentUser;

      // Check if email is verified
      if (user != null && !user.emailVerified) {
        // Send verification email
        await user.sendEmailVerification();
        await _auth.signOut();
        throw Exception('EMAIL_NOT_VERIFIED');
      }

      final customer = await getCurrentCustomer();
      if (customer == null) {
        await _auth.signOut();
        throw Exception('Customer profile not found. Please complete registration.');
      }
      return customer;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      // Check for network errors
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      // If it's already an Exception we threw, rethrow it
      if (e is Exception) rethrow;
      throw Exception('Login failed. Please try again.');
    }
  }

  // Register new customer; pushes all provided fields
  Future<CustomerModel> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String address, // full address text
    required String gender,
    required String password,
    double? addressLatitude,
    double? addressLongitude,
    String? profileImagePath,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);

        // Send email verification
        await user.sendEmailVerification();

        final now = DateTime.now();
        final newCustomer = CustomerModel(
          customerId: user.uid,
          name: name,
          gender: gender,
          email: email.toLowerCase(),
          phone: phoneNumber,
          profileImagePath: profileImagePath?.trim() ?? '',
          address: Address(
            fullAddress: address,
            latitude: addressLatitude ?? 0.0,
            longitude: addressLongitude ?? 0.0,
          ),
          createdAt: now,
          updatedAt: now,
        );

        final data = newCustomer.toJson();

        // Overwrite date fields with server timestamps
        data['createdAt'] = FieldValue.serverTimestamp();
        data['updatedAt'] = FieldValue.serverTimestamp();

        await _firestore.collection('customer').doc(user.uid).set(data);

        return newCustomer;
      }
      throw Exception('Registration failed');
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      // Check for network errors
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      throw Exception('Registration failed. Please try again.');
    }
  }

  // Get current logged-in customer (null if none or email not verified)
  Future<CustomerModel?> getCurrentCustomer() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Reload user to get latest email verification status
      await user.reload();
      final refreshedUser = _auth.currentUser;

      // Check if email is verified
      if (refreshedUser != null && !refreshedUser.emailVerified) {
        return null; // Don't return customer if email not verified
      }

      try {
        final doc = await _firestore.collection('customer').doc(user.uid).get();
        if (!doc.exists) return null;

        final data = doc.data()!;
        final json = Map<String, dynamic>.from(data)..['customerId'] = user.uid;
        return CustomerModel.fromJson(json);
      } catch (_) {
        // Swallow and return null to let caller decide auth state
      }
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      // Check for network errors
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      throw Exception('Failed to send password reset email. Please try again.');
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update to new password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      // Check for network errors
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      // If it's already an Exception we threw, rethrow it
      if (e is Exception) rethrow;
      throw Exception('Failed to change password. Please try again.');
    }
  }

  // Update customer profile; accepts granular address updates
  Future<void> updateCustomerProfile({
    String? name,
    String? phoneNumber,
    String? gender,
    String? profileImagePath,
    String? addressFull,
    double? addressLatitude,
    double? addressLongitude,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final updates = <String, dynamic>{};

      if (name != null) {
        updates['name'] = name;
        await user.updateDisplayName(name);
      }
      if (phoneNumber != null) updates['phone'] = phoneNumber;
      if (gender != null) updates['gender'] = gender;
      if (profileImagePath != null) updates['profileImagePath'] = profileImagePath;

      // Address
      if (addressFull != null || addressLatitude != null || addressLongitude != null) {
        updates['address'] = {
          'fullAddress': addressFull ?? '',
          'latitude': addressLatitude ?? 0.0,
          'longitude': addressLongitude ?? 0.0,
        };
      }

      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('customer').doc(user.uid).update(updates);
      }
    } catch (e) {
      // Check for network errors
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      throw Exception('Failed to update profile. Please try again.');
    }
  }

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Your email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Email Verification Methods

  // Check if current user's email is verified
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    // Reload user to get latest verification status
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Send verification email to current user
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      if (user.emailVerified) {
        throw Exception('Email is already verified');
      }

      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        throw Exception('Too many verification emails sent. Please try again later.');
      }
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      // Check for network errors
      if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection. Please check your network.');
      }
      // If it's already an Exception we threw, rethrow it
      if (e is Exception) rethrow;
      throw Exception('Failed to send verification email. Please try again.');
    }
  }

  // Reload current user to refresh email verification status
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }
}
