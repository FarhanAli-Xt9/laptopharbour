// Laptop Harbour – Validators Unit Tests
//
// Tests every static method in Validators to ensure correct validation logic
// for authentication and checkout form fields.

import 'package:flutter_test/flutter_test.dart';
import 'package:laptopharbour/utils/validators.dart';

void main() {
  // ─── Email ───────────────────────────────────────────────────────────────
  group('Validators.validateEmail', () {
    test('returns null for valid email', () {
      expect(Validators.validateEmail('pilot@harbour.io'), isNull);
      expect(Validators.validateEmail('user+tag@sub.domain.com'), isNull);
    });

    test('returns error for null input', () {
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('returns error for missing @ symbol', () {
      expect(Validators.validateEmail('noemail.com'), isNotNull);
    });

    test('returns error for missing domain', () {
      expect(Validators.validateEmail('user@'), isNotNull);
    });

    test('returns error for whitespace-only input', () {
      expect(Validators.validateEmail('   '), isNotNull);
    });
  });

  // ─── Password ────────────────────────────────────────────────────────────
  group('Validators.validatePassword', () {
    test('returns null for password meeting min length', () {
      expect(Validators.validatePassword('secure1'), isNull);
      expect(Validators.validatePassword('abcdef'), isNull);
    });

    test('returns error for null password', () {
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('returns error for empty password', () {
      expect(Validators.validatePassword(''), isNotNull);
    });

    test('returns error when password is shorter than minLength', () {
      expect(Validators.validatePassword('ab', minLength: 6), isNotNull);
    });

    test('respects custom minLength', () {
      expect(Validators.validatePassword('ab', minLength: 2), isNull);
      expect(Validators.validatePassword('a', minLength: 2), isNotNull);
    });
  });

  // ─── Confirm Password ────────────────────────────────────────────────────
  group('Validators.validateConfirmPassword', () {
    test('returns null when passwords match', () {
      expect(Validators.validateConfirmPassword('pass123', 'pass123'), isNull);
    });

    test('returns error when passwords do not match', () {
      expect(Validators.validateConfirmPassword('pass123', 'different'), isNotNull);
    });

    test('returns error for null confirm password', () {
      expect(Validators.validateConfirmPassword(null, 'pass123'), isNotNull);
    });

    test('returns error for empty confirm password', () {
      expect(Validators.validateConfirmPassword('', 'pass123'), isNotNull);
    });
  });

  // ─── Name ────────────────────────────────────────────────────────────────
  group('Validators.validateName', () {
    test('returns null for valid name', () {
      expect(Validators.validateName('Ada Lovelace'), isNull);
      expect(Validators.validateName('Jo'), isNull);
    });

    test('returns error for null name', () {
      expect(Validators.validateName(null), isNotNull);
    });

    test('returns error for empty name', () {
      expect(Validators.validateName(''), isNotNull);
    });

    test('returns error for single character name', () {
      expect(Validators.validateName('A'), isNotNull);
    });

    test('uses custom fieldName in error message', () {
      final error = Validators.validateName('', fieldName: 'Full Name');
      expect(error, contains('Full Name'));
    });
  });

  // ─── Phone ───────────────────────────────────────────────────────────────
  group('Validators.validatePhone', () {
    test('returns null for valid international phone', () {
      expect(Validators.validatePhone('+1234567890'), isNull);
      expect(Validators.validatePhone('0712345678'), isNull);
    });

    test('returns null when number has spaces/dashes (stripped)', () {
      expect(Validators.validatePhone('071-234-5678'), isNull);
    });

    test('returns error for null phone', () {
      expect(Validators.validatePhone(null), isNotNull);
    });

    test('returns error for empty phone', () {
      expect(Validators.validatePhone(''), isNotNull);
    });

    test('returns error for too-short phone number', () {
      expect(Validators.validatePhone('123'), isNotNull);
    });

    test('returns error for non-digit characters', () {
      expect(Validators.validatePhone('abc-defg-hij'), isNotNull);
    });
  });

  // ─── Card Number ─────────────────────────────────────────────────────────
  group('Validators.validateCardNumber', () {
    test('returns null for 16-digit card number', () {
      expect(Validators.validateCardNumber('4111111111111111'), isNull);
    });

    test('returns null for card number with spaces', () {
      expect(Validators.validateCardNumber('4111 1111 1111 1111'), isNull);
    });

    test('returns error for null card number', () {
      expect(Validators.validateCardNumber(null), isNotNull);
    });

    test('returns error for too-short card number', () {
      expect(Validators.validateCardNumber('41111'), isNotNull);
    });

    test('returns error for non-digit characters', () {
      expect(Validators.validateCardNumber('ABCD-EFGH-IJKL-MNOP'), isNotNull);
    });
  });

  // ─── Card Expiry ─────────────────────────────────────────────────────────
  group('Validators.validateCardExpiry', () {
    test('returns null for valid MM/YY format', () {
      expect(Validators.validateCardExpiry('12/27'), isNull);
      expect(Validators.validateCardExpiry('01/30'), isNull);
    });

    test('returns error for null expiry', () {
      expect(Validators.validateCardExpiry(null), isNotNull);
    });

    test('returns error for invalid month (13)', () {
      expect(Validators.validateCardExpiry('13/27'), isNotNull);
    });

    test('returns error for wrong format (MMYY without slash)', () {
      expect(Validators.validateCardExpiry('1227'), isNotNull);
    });
  });

  // ─── CVV ─────────────────────────────────────────────────────────────────
  group('Validators.validateCvv', () {
    test('returns null for 3-digit CVV', () {
      expect(Validators.validateCvv('123'), isNull);
    });

    test('returns null for 4-digit CVV (Amex)', () {
      expect(Validators.validateCvv('1234'), isNull);
    });

    test('returns error for null CVV', () {
      expect(Validators.validateCvv(null), isNotNull);
    });

    test('returns error for too-short CVV', () {
      expect(Validators.validateCvv('12'), isNotNull);
    });

    test('returns error for non-digit CVV', () {
      expect(Validators.validateCvv('abc'), isNotNull);
    });
  });

  // ─── Address ─────────────────────────────────────────────────────────────
  group('Validators.validateAddress', () {
    test('returns null for valid address', () {
      expect(Validators.validateAddress('123 Harbour Street, Dock City'), isNull);
    });

    test('returns error for null address', () {
      expect(Validators.validateAddress(null), isNotNull);
    });

    test('returns error for too-short address', () {
      expect(Validators.validateAddress('1 St'), isNotNull);
    });
  });
}
