import 'package:flutter/material.dart';
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
                            context, MaterialPageRoute(builder: (context) => QuizPage())
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

/*대전 페이지*/
class BattlePage extends StatelessWidget {
  const BattlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("대전 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: Text('대전 광역시'),
            alignment: Alignment.center,
            padding: EdgeInsets.all(50),
            color: Colors.orange[600],
            width: 400,
            height: 400,
          ),
        )
    );

  }
}

/*퀴즈 페이지*/
class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("퀴즈 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: Text('퀴즈 어쩌구'),
            alignment: Alignment.center,
            padding: EdgeInsets.all(50),
            color: Colors.orange[600],
            width: 400,
            height: 400,
          ),
        )
    );

  }
}

/*사전 페이지*/
class DictPage extends StatelessWidget {
  const DictPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("사전 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: Text('사전 어쩌구'),
            alignment: Alignment.center,
            padding: EdgeInsets.all(50),
            color: Colors.orange[600],
            width: 400,
            height: 400,
          ),
        )
    );

  }
}

/*프로필 페이지*/
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("프로필 창"),
          centerTitle: true,
        ),
        body: Center(

        )
    );

  }
}


/*옵션 페이지*/
class OptionPage extends StatelessWidget {
  const OptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("옵션 창"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Text('설정 어쩌구'),
          alignment: Alignment.center,
          padding: EdgeInsets.all(50),
          color: Colors.orange[600],
          width: 400,
          height: 400,
        ),
      )
    );

  }
}

