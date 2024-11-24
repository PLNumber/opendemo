import 'package:flutter/material.dart';
import '../BattlePages/pve.dart';
import '../BattlePages/pvp.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Literacy Quiz Battle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BattlePage(),
    );
  }
}

/* 대전 페이지 */
class BattlePage extends StatefulWidget {
  const BattlePage({Key? key}) : super(key: key);

  @override
  _BattlePageState createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  int score = 0;

  void incrementScore() {
    setState(() {
      score += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("대전 페이지"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/default.jpg'), // 프로필 사진
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                "$score 점",
                style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              // 버튼 카드 리스트
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // PVP 버튼 카드
                  _buildFeatureCard(
                    context,
                    Icons.people,
                    "PVP",
                    Colors.lightGreen,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PVPPage()),
                      );
                    },
                  ),
                  const SizedBox(width: 20.0),
                  // PVE 버튼 카드
                  _buildFeatureCard(
                    context,
                    Icons.computer,
                    "PVE",
                    Colors.lightBlueAccent,
                        () {
                      incrementScore();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PVEPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 버튼 카드 위젯 생성
  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: color,
        child: Container(
          width: 175, // 카드의 너비 설정
          height: 175, // 카드의 높이 설정
          padding: const EdgeInsets.all(20.0), // 내부 여백
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.white), // 아이콘 색상 조정
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
