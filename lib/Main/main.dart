import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Pages/ProfilePages/profileMain.dart';
import '../Pages/BattlePages/battleMain.dart';
import '../Pages/QuizPages/quizMain.dart';
import '../Pages/OptionPages/option.dart';
import '../../Pages/dictionary.dart';
import '../Function/Option/option_func.dart';
import '../Main/Login/pages/auth_page.dart';
import '../Main/Login/pages/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: 'assets/config/.env');
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider()..init(), // 앱 시작 시 테마 상태 초기화
      child: MyApp(),
    ),
  );
}


/*앱*/
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: '문해북',
          theme: themeProvider.currentTheme,  // 현재 테마 적용
          home: AuthPage(),
        );
      },
    );
  }
}

/*메인 화면*/
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  bool isAdVisible = true; // 광고 배너 표시 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('문해북'),
          centerTitle: true,
        ),

        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // 상단 이미지 배너
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.book, size: 80, color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      "문해북에 오신 것을 환영합니다!",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // 버튼 카드 리스트
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
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


              // 하단 설정 및 광고 배너
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.settings_outlined, size: 30),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => OptionPage()));
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  /*광고 배너*/
                  isAdVisible
                      ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      child: Text("광고 배너"),
                      alignment: Alignment.center,
                      color: Colors.red[100],
                      height: 50,
                    ),
                  ) : Container(),
                ],
              ),





            ],
          ),
        ));
  }
}



/*기능 카드 위젯*/
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
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
