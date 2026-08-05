import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider extends ChangeNotifier {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _themeKey = "dark_mode";

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await _storage.read(key: _themeKey);

    _isDarkMode = savedTheme == "true";

    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;

    await _storage.write(
      key: _themeKey,
      value: value.toString(),
    );

    notifyListeners();
  }
}