// fight.dart
import 'package:flutter/material.dart';
import '../class.dart'; // Question 클래스를 가져옵니다.

void startFight(BuildContext context, List<Question> questions, Function(int, int) onScoresUpdated) {
  int player1Score = 0;
  int player2Score = 0;

  // 질문 인덱스
  int questionIndex = 0;

  // 퀴즈 화면
  void showQuiz() {
    if (questionIndex < questions.length) {
      showDialog(
        context: context,
        builder: (context) {
          final question = questions[questionIndex]; // Question 객체 사용
          return AlertDialog(
            title: Text(question.word), // 단어를 질문으로 사용
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(question.def), // 정의를 보여줍니다.
                SizedBox(height: 10),
                // 정답 또는 오답 선택지 (예시로 4개 답변을 추가할 수 있습니다)
                ElevatedButton(
                  child: Text(question.word), // 단어를 답변으로 사용
                  onPressed: () {
                    player1Score++; // 플레이어 1 점수 추가
                    questionIndex++;
                    Navigator.of(context).pop(); // 대화상자 닫기
                    showQuiz(); // 다음 질문 표시
                  },
                ),
                // 다른 답변들도 추가할 수 있습니다.
              ],
            ),
          );
        },
      );
    } else {
      // 퀴즈 종료 후 점수 반환
      onScoresUpdated(player1Score, player2Score);
      Navigator.of(context).pop(); // PVP 화면으로 돌아가기
    }
  }

  showQuiz(); // 첫 질문 표시
}
