import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _storeName = 'Rongila Reshom';
  String _storeLogoPath = '';
  String _languageCode = 'en';
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  String get storeName => _storeName;
  String get storeLogoPath => _storeLogoPath;
  String get languageCode => _languageCode;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  // Initialize settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _storeName = prefs.getString('store_name') ?? 'Rongila Reshom';
      _storeLogoPath = prefs.getString('store_logo') ?? '';
      _languageCode = prefs.getString('language_code') ?? 'en';
      
      final themeIndex = prefs.getInt('theme_mode') ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('store_name', _storeName);
      await prefs.setString('store_logo', _storeLogoPath);
      await prefs.setString('language_code', _languageCode);
      await prefs.setInt('theme_mode', _themeMode.index);
    } catch (e) {
      // Silently fail
    }
  }

  void updateStoreName(String name) {
    _storeName = name;
    _saveSettings();
    notifyListeners();
  }

  void updateStoreLogo(String path) {
    _storeLogoPath = path;
    _saveSettings();
    notifyListeners();
  }

  void updateLanguage(String code) {
    _languageCode = code;
    _saveSettings();
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveSettings();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }
}
