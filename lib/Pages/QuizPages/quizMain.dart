import 'package:flutter/material.dart';
import 'quiz.dart';
import 'errorNote.dart';
import 'choice_quiz.dart';

class QuizMainPage extends StatelessWidget {
  const QuizMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("문제 메인창"),
        centerTitle: true,
        backgroundColor: Colors.teal, // 앱바 색상 변경
        iconTheme: const IconThemeData(color: Colors.white), // 아이콘 색상 변경
      ),
      body: Center(
        child: SingleChildScrollView( // 스크롤 가능하게 설정
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 퀴즈 풀기 버튼 카드 (주관식 퀴즈)
                _buildFeatureCard(
                  context,
                  Icons.quiz,
                  "단답식 퀴즈",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuizPage()),
                    );
                  },
                ),
                const SizedBox(height: 30), // 간격 줄이기
                // 객관식 퀴즈 풀기 버튼 카드
                _buildFeatureCard(
                  context,
                  Icons.check_circle,
                  "객관식 퀴즈",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChoiceQuizPage()),
                    );
                  },
                ),
                const SizedBox(height: 30), // 간격 줄이기
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
      ),
    );
  }

  // 버튼 카드 위젯 생성
  Widget _buildFeatureCard(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Container(
          width: 180, // 카드의 너비를 줄임
          height: 180, // 카드의 높이를 줄임
          padding: const EdgeInsets.all(16.0), // 내부 여백 줄임
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.teal), // 아이콘 크기 줄이기
              const SizedBox(height: 12), // 간격 줄이기
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20, // 텍스트 크기 줄이기
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
