import 'package:flutter/material.dart';
import 'quiz.dart';
import 'errorNote.dart';

class QuizMainPage extends StatelessWidget {
  const QuizMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("문제 메인창"),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 퀴즈 풀기 버튼 카드
              _buildFeatureCard(
                context,
                Icons.quiz,
                "퀴즈 풀기",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizPage()),
                  );
                },
              ),
              const SizedBox(height: 50),
              // 오답 노트 버튼 카드
              _buildFeatureCard(
                context,
                Icons.note,
                "오답 노트",
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 버튼 카드 위젯 생성
  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Container(
          width: 200, // 카드의 너비를 설정
          height: 200, // 카드의 높이를 설정
          padding: const EdgeInsets.all(20.0), // 내부 여백
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: Colors.teal), // 아이콘 크기 증가
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24, // 텍스트 크기 증가
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
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
