import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

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
              Container(
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
                      onPressed: (){},
                      child: const Center(child: Text("플레이어와 대결")))
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
                      onPressed: (){},
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
                      onPressed: (){},
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
                      onPressed: (){},
                      child: const Center(child: Text("프로필 수정")))
              ),
              SizedBox(height: 20),

              /*설정버튼*/
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  onPressed: () { },
                ),
              ),

            /*광고 배너*/
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(50),
              color: Colors.red[100],
              height: 50,
            ),
            ],
          ),
        )

      );
  }
}
