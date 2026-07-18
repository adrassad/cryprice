import 'package:shared_preferences/shared_preferences.dart';

class PushTokenLocalStore {
  PushTokenLocalStore({SharedPreferences? preferences})
      : _preferences = preferences;

  SharedPreferences? _preferences;
  static const _lastRegisteredTokenKey = 'push_last_registered_token';

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<String?> readLastRegisteredToken() async {
    final prefs = await _prefs();
    return prefs.getString(_lastRegisteredTokenKey);
  }

  Future<void> writeLastRegisteredToken(String token) async {
    final prefs = await _prefs();
    await prefs.setString(_lastRegisteredTokenKey, token);
  }

  Future<void> clearLastRegisteredToken() async {
    final prefs = await _prefs();
    await prefs.remove(_lastRegisteredTokenKey);
  }
}
