import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repository/auth_repository.dart';
import '../data/models/customer_model.dart';

// Auth State
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final CustomerModel customer;

  const AuthAuthenticated(this.customer);

  @override
  List<Object?> get props => [customer];
}

class AuthUnauthenticated extends AuthState {}

class AuthEmailNotVerified extends AuthState {
  final String email;

  const AuthEmailNotVerified(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Auth Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    try {
      final customer = await _authRepository.getCurrentCustomer();
      if (customer != null) {
        emit(AuthAuthenticated(customer));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      print('🔐 AuthCubit: Starting login for $email');
      emit(AuthLoading());
      final customer = await _authRepository.login(email: email, password: password);
      print('✅ AuthCubit: Login successful for ${customer.email}');
      emit(AuthAuthenticated(customer));
    } catch (e) {
      print('❌ AuthCubit: Login error - $e');
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      // Check if error is EMAIL_NOT_VERIFIED
      if (errorMessage == 'EMAIL_NOT_VERIFIED') {
        print('📧 AuthCubit: Email not verified, emitting AuthEmailNotVerified');
        emit(AuthEmailNotVerified(email));
      } else {
        print('📝 AuthCubit: Emitting AuthError with message: $errorMessage');
        emit(AuthError(errorMessage));
      }
      print('🔄 AuthCubit: Current state after error: ${state.runtimeType}');
    }
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required String gender,
    required String password,
    double? addressLatitude,
    double? addressLongitude,
    String? profileImagePath,
  }) async {
    try {
      emit(AuthLoading());
      final customer = await _authRepository.register(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        gender: gender,
        password: password,
        addressLatitude: addressLatitude,
        addressLongitude: addressLongitude,
        profileImagePath: profileImagePath,
      );
      emit(AuthAuthenticated(customer));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email);
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Update profile
  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? gender,
    String? profileImagePath,
    String? addressFull,
    double? addressLatitude,
    double? addressLongitude,
  }) async {
    try {
      emit(AuthLoading());
      await _authRepository.updateCustomerProfile(
        name: name,
        phoneNumber: phoneNumber,
        gender: gender,
        profileImagePath: profileImagePath,
        addressFull: addressFull,
        addressLatitude: addressLatitude,
        addressLongitude: addressLongitude,
      );

      // Refresh customer data
      final customer = await _authRepository.getCurrentCustomer();
      if (customer != null) {
        emit(AuthAuthenticated(customer));
      } else {
        emit(AuthError('Failed to refresh profile data.'));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Get current customer
  CustomerModel? get currentCustomer {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).customer;
    }
    return null;
  }

  // Email Verification Methods

  // Check if email is verified and update state accordingly
  Future<void> checkEmailVerification() async {
    try {
      final isVerified = await _authRepository.isEmailVerified();

      if (isVerified) {
        // Email is verified, get customer and authenticate
        final customer = await _authRepository.getCurrentCustomer();
        if (customer != null) {
          emit(AuthAuthenticated(customer));
        } else {
          emit(AuthError('Failed to fetch customer profile.'));
        }
      }
      // If not verified, state remains unchanged
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _authRepository.sendEmailVerification();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Reload user to get latest verification status
  Future<void> reloadUser() async {
    await _authRepository.reloadUser();
  }
}
