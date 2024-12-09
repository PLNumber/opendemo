import 'package:flutter/material.dart';
import 'quiz.dart';
import 'errorNote.dart';
import 'choice_quiz.dart';

class QuizMainPage extends StatelessWidget {
  const QuizMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 현재 테마의 밝기를 확인
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("문해력 퀴즈"),
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
                  isDarkMode, // 다크 모드 상태 전달
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
                  isDarkMode, // 다크 모드 상태 전달
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
                  isDarkMode, // 다크 모드 상태 전달
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
      BuildContext context, IconData icon, String title, VoidCallback onTap, bool isDarkMode) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDarkMode ? Colors.black : Colors.white, // 다크 모드일 때 배경색 변경
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
                style: TextStyle(
                  fontSize: 20, // 텍스트 크기 줄이기
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black, // 다크 모드일 때 글씨 색상 변경
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
