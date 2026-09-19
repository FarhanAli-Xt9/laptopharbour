import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import 'storage_service.dart';

/// Result object for authentication actions with descriptive messages.
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserModel? user;

  const AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.success(UserModel user) =>
      AuthResult._(isSuccess: true, user: user);

  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}

/// Local/demo authentication service managing user sessions,
/// credentials validation, profile data, and persistence.
/// Designed with clean interfaces so a real backend / REST API can be integrated seamlessly.
class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final ValueNotifier<UserModel?> currentUser = ValueNotifier<UserModel?>(null);

  bool get isAuthenticated => currentUser.value != null;

  /// Restores logged-in session from local storage on app start
  Future<void> init() async {
    try {
      final json = StorageService.instance.getJson(AppConstants.keyUserSession);
      if (json != null) {
        currentUser.value = UserModel.fromJson(json);
      }
    } catch (e) {
      debugPrint('[AuthService] Error restoring user session: $e');
    }
  }

  /// Demo login flow with simulated network latency and validation
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // 1. Client-side input validation
    final emailError = Validators.validateEmail(email);
    if (emailError != null) return AuthResult.failure(emailError);

    final passError = Validators.validatePassword(password);
    if (passError != null) return AuthResult.failure(passError);

    // 2. Simulated network latency
    await Future.delayed(const Duration(milliseconds: 700));

    // 3. Demo authentication validation
    final cleanEmail = email.trim().toLowerCase();

    UserModel user;

    // Admin account check
    if (cleanEmail == 'farhan2407a@gmail.com') {
      if (password != 'farhan xt9') {
        return AuthResult.failure('Invalid admin password. Access denied.');
      }
      user = UserModel.adminUser();
    } else if (cleanEmail == 'captain@harbour.com') {
      // Default demo account
      user = UserModel.defaultUser();
    } else {
      // Any other email — generic user
      user = UserModel(
        id: 'LHP-${10000 + DateTime.now().millisecondsSinceEpoch % 90000}',
        name: cleanEmail.split('@').first.toUpperCase(),
        email: cleanEmail,
        role: 'Crew Officer',
        tier: 'SILVER VOYAGER',
        loyaltyPoints: 3400,
        joinedDate: 'September 2026',
      );
    }

    currentUser.value = user;
    await _persistSession(user);
    return AuthResult.success(user);
  }

  /// Demo registration flow with validation
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final nameError = Validators.validateName(name, fieldName: 'Crew Name');
    if (nameError != null) return AuthResult.failure(nameError);

    final emailError = Validators.validateEmail(email);
    if (emailError != null) return AuthResult.failure(emailError);

    final passError = Validators.validatePassword(password);
    if (passError != null) return AuthResult.failure(passError);

    final confirmError = Validators.validateConfirmPassword(confirmPassword, password);
    if (confirmError != null) return AuthResult.failure(confirmError);

    await Future.delayed(const Duration(milliseconds: 700));

    final newUser = UserModel(
      id: 'LHP-${10000 + DateTime.now().millisecondsSinceEpoch % 90000}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: 'Fleet Cadet',
      tier: 'BRONZE NAVIGATOR',
      loyaltyPoints: 500,
      joinedDate: 'September 2026',
    );

    currentUser.value = newUser;
    await _persistSession(newUser);
    return AuthResult.success(newUser);
  }

  /// Clears active user session
  Future<void> logout() async {
    currentUser.value = null;
    await StorageService.instance.remove(AppConstants.keyUserSession);
  }

  /// Updates current user profile attributes (preferences, notifications, etc.)
  Future<void> updateProfile(UserModel updatedUser) async {
    currentUser.value = updatedUser;
    await _persistSession(updatedUser);
  }

  Future<void> _persistSession(UserModel user) async {
    try {
      await StorageService.instance.setJson(
        AppConstants.keyUserSession,
        user.toJson(),
      );
    } catch (e) {
      debugPrint('[AuthService] Error saving user session: $e');
    }
  }
}
