import 'package:flutter/material.dart';
import 'profile.dart';
import 'battle.dart';
import 'quiz.dart';
import 'option.dart';
import 'dictionary.dart';
import 'api.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'option_func.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
          home: MainPage(),
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

              /*이미지 창*/
              Container(
                child: Text("대충 문해북 이미지"),
                alignment: Alignment.center,
                padding: EdgeInsets.all(50),
                color: Colors.amber[600],
                //child: Image.network("https://flutter.github.io/assets-for-api-docs/assets/widgets/container_b.png"),
                width: 400,
                height: 200,
              ),
              SizedBox(height: 20),

              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(200, 10),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BattlePage()));
                      },
                      child: const Center(child: Text("대전")))),
              SizedBox(height: 20),

              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(200, 10),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuizMainPage()));
                      },
                      child: const Center(child: Text("문해력 문제")))),
              SizedBox(height: 20),


              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(200, 10),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DictPage()));
                      },
                      child: const Center(child: Text("단어 사전")))),
              SizedBox(height: 20),
              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(200, 10),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfilePage()));
                      },
                      child: const Center(child: Text("프로필 수정")))),
              SizedBox(height: 20),

              /*설정버튼*/
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  iconSize: 50.0,
                  selectedIcon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => OptionPage()));
                  },
                ),
              ),

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
        ));
  }
}
