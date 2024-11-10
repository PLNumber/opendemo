import 'package:flutter/material.dart';
import 'profile.dart';
import 'battle.dart';
import 'quiz.dart';
import 'option.dart';
import 'dictionary.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

/*앱*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MainPage(),
    );
  }
}

/*메인 화면*/
class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('메인 화면'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*이미지 창*/
              Container(
                child: Text("이미지 siuuuu"),
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
                              borderRadius: BorderRadius.circular(20.0)
                          )
                      ),
                      onPressed: (){
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => BattlePage())
                        );
                      },
                      child: const Center(child: Text("대전")))
              ),
              SizedBox(height: 20),

              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(200, 10),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)
                          )
                      ),
                      onPressed: (){
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => QuizMainPage())
                        );
                      },
                      child: const Center(child: Text("문해력 문제")))
              ),
              SizedBox(height: 20),

              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(200, 10),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)
                          )
                      ),
                      onPressed: (){
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => DictPage())
                        );
                      },
                      child: const Center(child: Text("단어 사전")))
              ),
              SizedBox(height: 20),

              Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(200, 10),
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)
                          )
                      ),
                      onPressed: (){
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => ProfilePage())
                        );
                      },
                      child: const Center(child: Text("프로필 수정")))
              ),
              SizedBox(height: 20),

              /*설정버튼*/
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => OptionPage())
                    );
                  },
                ),
              ),

            /*광고 배너*/
            Container(
              child: Text("광고 배너"),
              alignment: Alignment.center,
              color: Colors.red[100],
              height: 50,

            ),
            ],
          ),
        )

      );
  }
}
