import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Session {
  static const _storage = FlutterSecureStorage();
  static String? token;
  static String? email;

  static Future<void> save(String newtoken, String newEmail) async {
    token = newtoken;
    email = newEmail;
    await _storage.write(key: 'token', value: newtoken);
    await _storage.write(key: 'email', value: newEmail);
  }

  static Future<void> load() async {
    token = await _storage.read(key: 'token');
    email = await _storage.read(key: 'email');
  }

  static Future<void> clear() async {
    token = null;
    email = null;

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'email');
  }
}
