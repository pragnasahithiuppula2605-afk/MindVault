import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'encryption_service.dart';

class AppLockService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _pinHashKey =
      'app_lock_pin_hash';

  static const String _masterKeyKey =
      'master_key';

  static const String _enabledKey =
      'app_lock_enabled';

  static String _hashPin(String pin) {
    return sha256
        .convert(
          utf8.encode(pin),
        )
        .toString();
  }

  static Future<void> savePin(
    String pin,
  ) async {
    final hash = _hashPin(pin);

    final masterKey =
        EncryptionService.generateMasterKey();

    await _storage.write(
      key: _pinHashKey,
      value: hash,
    );

    await _storage.write(
      key: _masterKeyKey,
      value: masterKey,
    );

    await _storage.write(
      key: _enabledKey,
      value: 'true',
    );
  }

  static Future<bool> verifyPin(
    String pin,
  ) async {
    final storedHash =
        await _storage.read(
      key: _pinHashKey,
    );

    if (storedHash == null) {
      return false;
    }

    return storedHash ==
        _hashPin(pin);
  }

  static Future<String?> getMasterKey() async {
    return await _storage.read(
      key: _masterKeyKey,
    );
  }

  static Future<bool> isEnabled() async {
    return (await _storage.read(
          key: _enabledKey,
        )) ==
        'true';
  }

  static Future<String?> getPin() async {
    return null;
  }

  /// Clears all secure storage values.
  /// Used when the user resets MindVault using "Forgot PIN".
  static Future<void> reset() async {
    await _storage.deleteAll();
  }

  static Future<void> disable() async {
    await _storage.delete(
      key: _pinHashKey,
    );

    await _storage.delete(
      key: _masterKeyKey,
    );

    await _storage.delete(
      key: _enabledKey,
    );
  }
}