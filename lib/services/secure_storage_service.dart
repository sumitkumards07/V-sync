import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  
  static const _emailKey = 'user_email';
  static const _passwordKey = 'user_password';

  Future<void> saveEmailPassword(String email, String password) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
  }

  Future<Map<String, String?>> getEmailPassword() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    return {
      'email': email,
      'password': password,
    };
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
