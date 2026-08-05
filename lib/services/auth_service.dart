import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';
  static const String _loggedInKey = 'is_logged_in';
  static const String _onboardingKey =
      'onboarding_completed';

  // ============================
  // Register
  // ============================

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _nameKey, value: name);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
  }

  // ============================
  // Login
  // ============================

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final savedEmail = await _storage.read(key: _emailKey);
    final savedPassword = await _storage.read(key: _passwordKey);

    if (savedEmail == email &&
        savedPassword == password) {
      await _storage.write(
        key: _loggedInKey,
        value: 'true',
      );
      return true;
    }

    return false;
  }

  // ============================
  // Logged In
  // ============================

  static Future<void> setLoggedIn() async {
    await _storage.write(
      key: _loggedInKey,
      value: 'true',
    );
  }

  static Future<void> logout() async {
    await _storage.delete(key: _loggedInKey);
  }

  static Future<bool> isLoggedIn() async {
    return (await _storage.read(key: _loggedInKey)) ==
        'true';
  }

  // ============================
  // Account
  // ============================

  static Future<bool> hasAccount() async {
    final email = await _storage.read(key: _emailKey);
    return email != null && email.isNotEmpty;
  }

  static Future<String?> getName() async {
    return await _storage.read(key: _nameKey);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  // ============================
  // Delete Account
  // ============================

  static Future<void> deleteAccount() async {
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _loggedInKey);
    await _storage.delete(key: _onboardingKey);
  }

  // ============================
  // Onboarding
  // ============================

  static Future<bool> hasCompletedOnboarding() async {
    return (await _storage.read(
          key: _onboardingKey,
        )) ==
        'true';
  }

  static Future<void> completeOnboarding() async {
    await _storage.write(
      key: _onboardingKey,
      value: 'true',
    );
  }
}