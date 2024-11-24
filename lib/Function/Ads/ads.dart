// ads.dart
import 'package:shared_preferences/shared_preferences.dart';

class AdManager {
  static const String _adVisibilityKey = 'adVisibility';

  // 광고 표시 여부를 저장하는 함수
  static Future<void> setAdVisibility(bool isVisible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adVisibilityKey, isVisible);
  }

  // 광고 표시 여부를 가져오는 함수
  static Future<bool> getAdVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adVisibilityKey) ?? true; // 기본값은 true
  }
}
