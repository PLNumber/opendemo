import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Function/Ads/ads_provider.dart';
import '../Function/Profile/secure.dart';
import '../Function/class.dart';
import '../Pages/ProfilePages/profileMain.dart';
import '../Pages/BattlePages/battleMain.dart';
import '../Pages/QuizPages/quizMain.dart';
import '../Pages/OptionPages/option.dart';
import '../Pages/DictionaryPages/dictionary.dart';
import '../Function/Option/option_func.dart';
import '../Main/Login/pages/auth_page.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Function/Ads/google_ads.dart'; // AdManager를 임포트합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 세로 모드로 잠금
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await migrateQuestionsToRealtimeDatabase();
  await dotenv.load(fileName: 'assets/config/.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (context) => AdVisibilityProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: '문해북',
          theme: themeProvider.currentTheme,
          home: AuthPage(),
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
  BannerAd? _bannerAd;
  String? playerName; // 기본값

  @override
  void initState() {
    super.initState();
    _loadAd();
    _loadPlayerProfile();
  }

  Future<void> _loadPlayerProfile() async {
    String? savedName = await loadDataSecure('playerName');

    setState(() {
      playerName = savedName ?? "Player"; // 저장된 이름이 없으면 기본값 사용
    });
  }

  void _loadAd() {
    final adVisibilityProvider =
        Provider.of<AdVisibilityProvider>(context, listen: false);
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

  @override
  void dispose() {
    _bannerAd?.dispose();
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
        // 스크롤 가능하도록 설정
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
                    child: Text("안녕하세요, ${playerName}님!",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text("2300 Exp. Points\n32 Ranking",
                        textAlign: TextAlign.center),
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
                      Text("일일 퀴즈",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("20문항", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuizMainPage()));
                    },
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
              shrinkWrap: true,
              // GridView의 크기를 부모에 맞춤
              physics: NeverScrollableScrollPhysics(),
              // 스크롤 비활성화
              children: [
                FeatureCard(
                  icon: Icons.sports_esports,
                  title: "대전",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => BattlePage()));
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      // 광고 배너
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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => OptionPage()));
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
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Color(0xFFFFFFFF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.teal),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
