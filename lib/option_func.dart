import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/*테마 설정 함수*/
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
    await prefs.setBool('isDarkMode', _isDarkMode);;
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

// 제작자 정보 다이얼로그를 보여주는 함수
void showCreatorInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("제작자 정보", textAlign: TextAlign.center,),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            Text(
              "안재모\n허재민\n백승태\n위지웅",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30.0),
              ),
            SizedBox(height: 20.0,),

            Text(
              "이 앱은 Flutter로 개발되었습니다",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.0, color: Colors.blue),
            ),

          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();  // 다이얼로그 닫기
            },
            child: const Text("닫기"),
          ),
        ],
      );
    },
  );
}

// URL을 여는 함수
Future<void> launchURL(String url) async {
  final Uri uri = Uri.parse(url);

  // URL을 열기 전에 확인
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch $url';
  }
}

