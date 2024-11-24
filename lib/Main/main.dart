import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Function/Ads/ads.dart';
import '../Function/Ads/ads_provider.dart';
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
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: 'assets/config/.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (context) => AdVisibilityProvider()), // 광고 표시 여부 관리
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

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adVisibilityProvider = Provider.of<AdVisibilityProvider>(context, listen: false);
    if (adVisibilityProvider.isAdVisible) {
      _createBannerAd();
    }
  }

  void _createBannerAd() { // 광고
    _bannerAd = BannerAd(
      size: AdSize.fluid,
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
        title: Text('문해북', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 이미지 배너
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9), // 부드러운 연두색
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.book, size: 80, color: Colors.teal),
                  SizedBox(height: 8),
                  Text(
                    "문해북에 오신 것을 환영합니다!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // 버튼 카드 리스트
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  FeatureCard(
                    icon: Icons.sports_esports,
                    title: "대전",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BattlePage()));
                    },
                  ),
                  FeatureCard(
                    icon: Icons.quiz,
                    title: "문해력 문제",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => QuizMainPage()));
                    },
                  ),
                  FeatureCard(
                    icon: Icons.book,
                    title: "단어 사전",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DictPage()));
                    },
                  ),
                  FeatureCard(
                    icon: Icons.person,
                    title: "프로필 수정",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                    },
                  ),
                ],
              ),
            ),

            // 광고 배너
            if (adVisibilityProvider.isAdVisible) // 광고 표시 여부에 따라 조건부 렌더링
              _bannerAd == null
                  ? Container(
                alignment: Alignment.center,
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: const CircularProgressIndicator(), // 로딩 중
              )
                  : Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                height: 50,
                width: double.infinity,
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50), // 광고 배너와 겹치지 않도록 여백 추가
        child: Container(
          width: 80, // 버튼의 너비 설정
          height: 80, // 버튼의 높이 설정
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OptionPage()));
            },
            child: Icon(Icons.settings_outlined, size: 50), // 아이콘 크기 조정
            backgroundColor: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked, // 위치 조정
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
