import 'package:shared_preferences/shared_preferences.dart';

import '../models/enums.dart';
import 'oil_storage.dart';

class ThemeStorage {
  Future<AppThemeMode?> readThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(OilStorageKeys.themeMode);
    if (stored == AppThemeMode.dark.name) {
      return AppThemeMode.dark;
    }
    if (stored == AppThemeMode.light.name) {
      return AppThemeMode.light;
    }
    return null;
  }

  Future<void> writeThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(OilStorageKeys.themeMode, mode.name);
  }
}
