import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;  // 기본적으로 라이트 모드 설정

  bool get isDarkMode => _isDarkMode;

  // 테마 설정을 저장하는 메서드
  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;  // 저장된 값이 없다면 기본값 false (라이트 모드)
    notifyListeners();  // 상태 변경을 알림
  }

  // 테마 전환 메서드
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    // 테마 상태를 로컬에 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();  // 상태 변경을 알림
  }

  // 앱 시작 시 호출되어야 할 메서드
  Future<void> init() async {
    await _loadTheme();  // 앱 시작 시 저장된 테마 상태를 로드
  }

  // 현재 테마 반환
  ThemeData get currentTheme {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
}
