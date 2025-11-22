import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String getErrorMessage(FirebaseException e, {String? context}) {
    _logError(e, context: context);
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'requires-recent-login':
        return 'This operation is sensitive and requires recent authentication. Log in again before retrying this request.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'network-request-failed':
        return 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.';
      case 'user-mismatch':
        return 'The credentials provided do not correspond to the user.';
      case 'invalid-credential':
        return 'The credential used to authenticate is malformed or has expired.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      // Add more cases as needed for different error codes
      default:
        return 'An undefined error happened.';
    }
  }

  static void _logError(FirebaseException e, {String? context}) {
    _firestore.collection('errors').add({
      'code': e.code,
      'message': e.message,
      'stackTrace': e.stackTrace.toString(),
      'context': context ?? 'Not provided',
      'timestamp': FieldValue.serverTimestamp(),
    }).catchError((error) {
      print("Failed to log error to Firestore: $error");
    });
  }
}
