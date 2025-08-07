import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class WebStorageService {
  static const _key = 'user_profile';

  static Future<void> saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_key, user.toJson());
  }

  static Future<UserProfile?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json != null) {
      return UserProfile.fromJson(json);
    }
    return null;
  }

  static Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_key);
  }
}
