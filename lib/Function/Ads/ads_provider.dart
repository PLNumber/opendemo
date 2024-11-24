import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdVisibilityProvider with ChangeNotifier {
  static const String _adVisibilityKey = 'adVisibility';
  bool _isAdVisible = true;

  AdVisibilityProvider() {
    _loadAdVisibility();
  }

  bool get isAdVisible => _isAdVisible;

  Future<void> _loadAdVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    _isAdVisible = prefs.getBool(_adVisibilityKey) ?? true;
    notifyListeners();
  }

  Future<void> setAdVisibility(bool isVisible) async {
    _isAdVisible = isVisible;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adVisibilityKey, isVisible);
    notifyListeners();
  }
}
