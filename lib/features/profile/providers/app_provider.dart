import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  bool _isDarkMode = false;
  String _languageCode = 'en';
  bool _notificationsEnabled = true;
  bool _isOnboardingCompleted = false;

  // Authentication & Farmer Profile details
  bool _isLoggedIn = false;
  String _farmerName = 'Mr. Abhay Kumar';
  String _farmerLocation = 'Faridabad, Haryana, India';
  String _farmerId = 'AV-2026-904';

  // Extended Profile Features
  double _farmSize = 5.0;
  String _soilType = 'Loamy';
  String _primaryCrop = 'Tomato';

  AppProvider(this._prefs) {
    _loadPreferences();
  }

  bool get isDarkMode => _isDarkMode;
  String get languageCode => _languageCode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  
  bool get isLoggedIn => _isLoggedIn;
  String get farmerName => _farmerName;
  String get farmerLocation => _farmerLocation;
  String get farmerId => _farmerId;

  double get farmSize => _farmSize;
  String get soilType => _soilType;
  String get primaryCrop => _primaryCrop;

  void _loadPreferences() {
    _isDarkMode = _prefs.getBool('is_dark_mode') ?? false;
    _languageCode = _prefs.getString('language_code') ?? 'en';
    _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
    _isOnboardingCompleted = _prefs.getBool('onboarding_completed') ?? false;

    _isLoggedIn = _prefs.getBool('is_logged_in') ?? false;
    _farmerName = _prefs.getString('farmer_name') ?? 'Mr. Abhay Kumar';
    _farmerLocation = _prefs.getString('farmer_location') ?? 'Faridabad, Haryana, India';
    _farmerId = _prefs.getString('farmer_id') ?? 'AV-2026-904';

    _farmSize = _prefs.getDouble('farm_size') ?? 5.0;
    _soilType = _prefs.getString('soil_type') ?? 'Loamy';
    _primaryCrop = _prefs.getString('primary_crop') ?? 'Tomato';
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('is_dark_mode', value);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _languageCode = lang;
    await _prefs.setString('language_code', lang);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    await _prefs.setBool('notifications_enabled', value);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isOnboardingCompleted = true;
    await _prefs.setBool('onboarding_completed', true);
    notifyListeners();
  }

  // Auth Operations
  Future<void> login(String email, String password) async {
    _isLoggedIn = true;
    await _prefs.setBool('is_logged_in', true);
    notifyListeners();
  }

  Future<void> signup({
    required String name,
    required String location,
    required String email,
    required String password,
  }) async {
    _isLoggedIn = true;
    _farmerName = name;
    _farmerLocation = location;
    
    final idSuffix = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    _farmerId = 'AV-2026-$idSuffix';

    await _prefs.setBool('is_logged_in', true);
    await _prefs.setString('farmer_name', name);
    await _prefs.setString('farmer_location', location);
    await _prefs.setString('farmer_id', _farmerId);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _prefs.setBool('is_logged_in', false);
    notifyListeners();
  }

  // Profile Edit
  Future<void> updateProfile({
    required String name,
    required String location,
    required String id,
    required double farmSize,
    required String soilType,
    required String primaryCrop,
  }) async {
    _farmerName = name;
    _farmerLocation = location;
    _farmerId = id;
    _farmSize = farmSize;
    _soilType = soilType;
    _primaryCrop = primaryCrop;

    await _prefs.setString('farmer_name', name);
    await _prefs.setString('farmer_location', location);
    await _prefs.setString('farmer_id', id);
    await _prefs.setDouble('farm_size', farmSize);
    await _prefs.setString('soil_type', soilType);
    await _prefs.setString('primary_crop', primaryCrop);
    notifyListeners();
  }

  Future<void> resetApp() async {
    await _prefs.clear();
    _isDarkMode = false;
    _languageCode = 'en';
    _notificationsEnabled = true;
    _isOnboardingCompleted = false;
    _isLoggedIn = false;
    _farmerName = 'Mr. Abhay Kumar';
    _farmerLocation = 'Faridabad, Haryana, India';
    _farmerId = 'AV-2026-904';
    _farmSize = 5.0;
    _soilType = 'Loamy';
    _primaryCrop = 'Tomato';
    notifyListeners();
  }
}
