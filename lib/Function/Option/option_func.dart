import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용을 위한 import

/*테마 설정 함수*/
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false; // 기본적으로 라이트 모드 설정

  bool get isDarkMode => _isDarkMode;

  // 테마 설정을 저장하는 메서드
  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode =
        prefs.getBool('isDarkMode') ?? false; // 저장된 값이 없다면 기본값 false (라이트 모드)
    notifyListeners(); // 상태 변경을 알림
  }

  // 테마 전환 메서드
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    // 테마 상태를 로컬에 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    ;
    notifyListeners(); // 상태 변경을 알림
  }

  // 앱 시작 시 호출되어야 할 메서드
  Future<void> init() async {
    await _loadTheme(); // 앱 시작 시 저장된 테마 상태를 로드
  }

  // 현재 테마 반환
  ThemeData get currentTheme {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }
}

// 제작자 정보 다이얼로그를 보여주는 함수
void showCreatorInfoDialog(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark; // 다크 모드 확인

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // 모서리를 둥글게 설정
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 타이틀
              Text(
                "제작자 정보",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87, // 다크 모드 글씨 색상
                ),
              ),
              const SizedBox(height: 15.0),

              // 제작자 명단
              Text(
                "안재모\n허재민\n백승태\n위지웅",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white70 : Colors.black54, // 다크 모드 글씨 색상
                ),
              ),
              const SizedBox(height: 20.0),

              // 추가 설명
              Text(
                "이 앱은 Flutter로 개발되었습니다.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  color: isDarkMode ? Colors.blueAccent : Colors.blueAccent, // 버튼 색상은 그대로 유지
                ),
              ),
              const SizedBox(height: 20.0),

              // 닫기 버튼
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // 버튼 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 10.0,
                  ),
                ),
                child: const Text(
                  "닫기",
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
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

// 사운드 함수
class SoundProvider with ChangeNotifier {
  bool _isSoundOn = true; // 기본값: 소리 켜짐
  bool get isSoundOn => _isSoundOn;

  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false; // 현재 재생 중인지 여부

  // 저장된 소리 설정을 로드하고 초기 상태에 따라 동작
  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isSoundOn = prefs.getBool('isSoundOn') ?? true;
    notifyListeners();

    if (_isSoundOn) {
      // 플랫폼에 따라 오디오 재생
      if (!kIsWeb) { // 모바일 앱인 경우
        await _playSound(); // 소리 재생
      }
    } else {
      await _stopSound(); // 꺼진 상태라면 정지
    }
  }

  // 소리 on/off 전환
  Future<void> toggleSound() async {
    _isSoundOn = !_isSoundOn;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundOn', _isSoundOn);
    notifyListeners();

    if (_isSoundOn) {
      if (!kIsWeb) { // 모바일 앱인 경우
        await _playSound(); // 소리 켜졌을 때 소리 재생
      }
    } else {
      await _stopSound(); // 소리 꺼졌을 때 소리 정지
    }
  }

  // 오디오 재생 함수
  Future<void> _playSound() async {
    if (!_isPlaying) { // 이미 재생 중이 아닐 때만 재생
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // 무한 반복 설정
      await _audioPlayer.play(AssetSource('audio/cozy_main.mp3'));
      _isPlaying = true;
    }
  }

  // 오디오 정지 함수
  Future<void> _stopSound() async {
    if (_isPlaying) { // 현재 재생 중일 때만 정지
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // AudioPlayer 리소스 해제
    super.dispose();
  }
}