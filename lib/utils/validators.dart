/// Form input validation helpers for authentication and checkout.
class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  /// Validates email address format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  /// Validates password / passkey length and content
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Passkey is required.';
    }
    if (value.length < minLength) {
      return 'Passkey must be at least $minLength characters.';
    }
    return null;
  }

  /// Validates confirm password matches original password
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your passkey.';
    }
    if (value != originalPassword) {
      return 'Passkeys do not match.';
    }
    return null;
  }

  /// Validates required name field
  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters.';
    }
    return null;
  }

  /// Validates shipping address
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Shipping destination is required.';
    }
    if (value.trim().length < 8) {
      return 'Please enter a complete delivery address.';
    }
    return null;
  }

  /// Validates phone number (for checkout)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact phone number is required.';
    }
    final clean = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (clean.length < 7 || clean.length > 15 || !RegExp(r'^\+?[0-9]+$').hasMatch(clean)) {
      return 'Please enter a valid contact phone number.';
    }
    return null;
  }

  /// Validates credit card number (demo check: 13-19 digits)
  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required.';
    }
    final clean = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (clean.length < 13 || clean.length > 19 || !RegExp(r'^[0-9]+$').hasMatch(clean)) {
      return 'Please enter a valid card number (13-19 digits).';
    }
    return null;
  }

  /// Validates card expiry format (MM/YY)
  static String? validateCardExpiry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'MM/YY required.';
    }
    final clean = value.trim();
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(clean)) {
      return 'Use MM/YY format.';
    }
    return null;
  }

  /// Validates CVV (3 or 4 digits)
  static String? validateCvv(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV required.';
    }
    final clean = value.trim();
    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(clean)) {
      return '3-4 digits.';
    }
    return null;
  }
}
