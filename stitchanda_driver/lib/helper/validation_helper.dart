class ValidationHelper {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email address.';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password.';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }
    return null;
  }

  static String? validatePakistanPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Please enter a phone number.';
    }
    // Regex for Pakistani phone numbers
    // Supports formats: 03xxxxxxxxx, +923xxxxxxxxx, 3xxxxxxxxx
    final phoneRegex = RegExp(r'^((\+92)|(0))?3\d{9}$');
    if (!phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[- ]'), ''))) {
      return 'Please enter a valid Pakistani phone number (e.g., 03123456789).';
    }
    return null;
  }
}
