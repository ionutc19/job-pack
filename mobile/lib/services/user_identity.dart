import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class UserIdentity {
  static final UserIdentity _instance = UserIdentity._();
  factory UserIdentity() => _instance;
  UserIdentity._();

  static const String _userIdKey = 'app_user_id';
  static const String _deviceIdKey = 'app_device_id';

  String _userId = '';
  String _deviceId = '';

  String get userId => _userId;
  String get deviceId => _deviceId;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_userIdKey) ?? '';
    _deviceId = prefs.getString(_deviceIdKey) ?? '';

    if (_userId.isEmpty) {
      _userId = _generateUuid();
      await prefs.setString(_userIdKey, _userId);
    }
    if (_deviceId.isEmpty) {
      _deviceId = _generateUuid();
      await prefs.setString(_deviceIdKey, _deviceId);
    }
  }

  static String _generateUuid() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }
}
