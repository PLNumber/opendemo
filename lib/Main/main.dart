import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Function/Ads/ads_provider.dart';
import '../Function/Battle/inputDB.dart';
import '../Function/splash_screen/splash_screen.dart';
import '../Pages/BattlePages/battleMain.dart';
import '../Pages/ProfilePages/profileMain.dart';
import '../Pages/OptionPages/battleMain_beta.dart';
import '../Pages/QuizPages/quizMain.dart';
import '../Pages/QuizPages/dailyQuiz.dart';
import '../Pages/OptionPages/option.dart';
import '../Pages/DictionaryPages/dictionary.dart';
import '../Function/Option/option_func.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Function/Ads/google_ads.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final soundProvider = SoundProvider();
  await soundProvider.init(); // SoundProvider 초기화
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  MobileAds.instance.initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: 'assets/config/.env');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (context) => AdVisibilityProvider()),
        ChangeNotifierProvider(create: (_) => soundProvider),
        // 초기화된 SoundProvider 전달
      ],
      child: MyApp(),
    ),
  );
  await migrateWQToSharedDatabase();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: '문해북',
          theme: themeProvider.currentTheme,
          home: SplashScreen(),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  late AudioPlayer player;
  BannerAd? _bannerAd;
  String userName = ""; // DB에서 가져올 사용자 이름
  bool _isQuizButtonDisabled = false;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // 앱(Android/iOS) 환경에서만 AudioPlayer 초기화
      _loadAd();
    }
    _fetchUserName();
    _checkLastQuizAttempt();
    _scheduleResetAtMidnight();
  }

  void _loadAd() {
    if (!kIsWeb) {
      final adVisibilityProvider =
          Provider.of<AdVisibilityProvider>(context, listen: false);
      if (adVisibilityProvider.isAdVisible) {
        _createBannerAd();
      }
    }
  }

  void _createBannerAd() {
    if (!kIsWeb) {
      _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerAdListener,
        request: const AdRequest(),
      )..load();
    }
  }

  Future<void> _fetchUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("사용자가 로그인되지 않았습니다.");
      }

      String uid = currentUser.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? '사용자';
        });
      } else {
        setState(() {
          userName = '사용자';
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  Future<void> _checkLastQuizAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAttemptString = prefs.getString('lastQuizAttemptTime');

    if (lastAttemptString != null) {
      final lastAttempt = DateTime.parse(lastAttemptString);
      final now = DateTime.now();

      if (_isSameDay(lastAttempt, now)) {
        setState(() {
          _isQuizButtonDisabled = true; // 오늘 퀴즈를 이미 풀었으므로 버튼 비활성화
        });
      }
    }
  }

  void _scheduleResetAtMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1); // 다음 자정
    final duration = midnight.difference(now);

    _resetTimer = Timer(duration, () {
      setState(() {
        _isQuizButtonDisabled = false; // 자정이 되면 버튼 활성화
      });
    });
  }

  Future<void> _onStartQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'lastQuizAttemptTime', DateTime.now().toIso8601String());
    setState(() {
      _isQuizButtonDisabled = true; // 퀴즈 시작 시 버튼 비활성화
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SingleQuizPage()),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _bannerAd?.dispose();
    }
    player.dispose();
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adVisibilityProvider = Provider.of<AdVisibilityProvider>(context);
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark; // 다크 모드 여부 확인

    return PopScope(
      canPop: false, // 시스템 뒤로가기를 비활성화
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("종료"),
            content: const Text("정말 앱을 종료하시겠습니까?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // 취소
                child: const Text("취소"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // 확인
                  // 앱 종료
                  SystemNavigator.pop();
                },
                child: const Text("확인"),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '문해북',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 환영 메시지 및 사용자 정보
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black : Colors.white, // 배경색 변경
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        "안녕하세요, $userName님!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : Colors.black, // 다크 모드에 따라 색상 변경
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // 학습 섹션
              Text(
                "더 학습하기",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkMode ? Colors.white : Colors.black, // 다크 모드에 따라 색상 변경
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black54 : Colors.teal[100], // 배경색 변경
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "일일 픽업 퀴즈",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.black, // 다크 모드에 따라 색상 변경
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "하루에 한 번! 다량의 포인트 획득 기회",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.black54, // 다크 모드에 따라 색상 변경
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isQuizButtonDisabled ? null : _onStartQuiz,
                      child: Text("시작하기"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // 계속 공부하기 섹션
              Text(
                "계속 공부하기",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkMode ? Colors.white : Colors.black, // 다크 모드에 따라 색상 변경
                ),
              ),
              SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                // GridView의 크기를 부모에 맞춤
                physics: NeverScrollableScrollPhysics(),
                // 스크롤 비활성화
                children: [
                  FeatureCard(
                    icon: Icons.sports_esports,
                    title: "대전",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BattlePage()),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.quiz,
                    title: "문해력 퀴즈",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizMainPage()),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.book,
                    title: "단어 사전",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DictPage()),
                      );
                    },
                  ),
                  FeatureCard(
                    icon: Icons.person,
                    title: "프로필 수정",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: (!kIsWeb && adVisibilityProvider.isAdVisible)
            ? _bannerAd == null
                ? null // 웹에서는 로딩창도 출력하지 않음
                : Container(
                    height: 50,
                    child: AdWidget(ad: _bannerAd!),
                  )
            : null,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OptionPage()));
          },
          child: Icon(Icons.settings_outlined),
          backgroundColor: Colors.teal,
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.teal),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black, // 다크 모드에 따라 색상 변경
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
