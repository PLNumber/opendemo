import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Function/Ads/ads_provider.dart';
import '../Function/Battle/inputDB.dart';
import '../Function/splash_screen/splash_screen.dart';
import '../Pages/ProfilePages/profileMain.dart';
import '../Pages/BattlePages/battleMain.dart';
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
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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
        ChangeNotifierProvider(create: (_) => soundProvider), // 초기화된 SoundProvider 전달
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
          theme: Provider.of<ThemeProvider>(context).currentTheme,
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
    _loadAd();
    _fetchUserName();
    _checkLastQuizAttempt();
    _scheduleResetAtMidnight();

  }


  void _loadAd() {
    final adVisibilityProvider = Provider.of<AdVisibilityProvider>(context, listen: false);
    if (adVisibilityProvider.isAdVisible) {
      _createBannerAd();
    }
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: AdMobService.bannerAdUnitId!,
      listener: AdMobService.bannerAdListener,
      request: const AdRequest(),
    )..load();
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
    _bannerAd?.dispose();
    _resetTimer?.cancel();
    player.dispose(); // AudioPlayer 리소스 해제y
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adVisibilityProvider = Provider.of<AdVisibilityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('문해북'),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Center(
                    child: Text("안녕하세요, $userName님!",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // 학습 섹션
            Text("더 학습하기",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("일일 픽업 퀴즈",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("하루에 한 번! 다량의 포인트 획득 기회", style: TextStyle(fontSize: 14)),
                    ],
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
            Text("계속 공부하기",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true, // GridView의 크기를 부모에 맞춤
              physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
              children: [
                FeatureCard(
                  icon: Icons.sports_esports,
                  title: "대전",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BattlePage()));
                  },
                ),
                FeatureCard(
                  icon: Icons.quiz,
                  title: "문해력 문제",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuizMainPage()));
                  },
                ),
                FeatureCard(
                  icon: Icons.book,
                  title: "단어 사전",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DictPage()));
                  },
                ),
                FeatureCard(
                  icon: Icons.person,
                  title: "프로필 수정",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfilePage()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: adVisibilityProvider.isAdVisible
          ? _bannerAd == null
          ? Container(
        height: 50,
        child: const Center(child: CircularProgressIndicator()),
      )
          : Container(
        height: 50,
        child: AdWidget(ad: _bannerAd!),
      )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => OptionPage()));
        },
        child: Icon(Icons.settings_outlined),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const FeatureCard(
      {Key? key, required this.icon, required this.title, required this.onTap})
      : super(key: key);

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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
