import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  EncryptionService._();

  /// Generate a random 256-bit master key
  static String generateMasterKey() {
    final random = Random.secure();

    final bytes = Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );

    return base64Encode(bytes);
  }

  /// Encrypt bytes using AES-256-CBC
  static Uint8List encryptBytes({
    required Uint8List data,
    required String masterKey,
  }) {
    final key = encrypt.Key(
      base64Decode(masterKey),
    );

    final iv = encrypt.IV.fromSecureRandom(16);

    final aes = encrypt.Encrypter(
      encrypt.AES(
        key,
        mode: encrypt.AESMode.cbc,
      ),
    );

    final encrypted = aes.encryptBytes(
      data,
      iv: iv,
    );

    return Uint8List.fromList([
      ...iv.bytes,
      ...encrypted.bytes,
    ]);
  }

  /// Decrypt bytes
  static Uint8List decryptBytes({
    required Uint8List encryptedData,
    required String masterKey,
  }) {
    if (encryptedData.length < 17) {
      throw Exception("Invalid encrypted data.");
    }

    final key = encrypt.Key(
      base64Decode(masterKey),
    );

    final iv = encrypt.IV(
      encryptedData.sublist(0, 16),
    );

    final encrypted = encrypt.Encrypted(
      encryptedData.sublist(16),
    );

    final aes = encrypt.Encrypter(
      encrypt.AES(
        key,
        mode: encrypt.AESMode.cbc,
      ),
    );

    final decrypted = aes.decryptBytes(
      encrypted,
      iv: iv,
    );

    return Uint8List.fromList(
      decrypted,
    );
  }
}