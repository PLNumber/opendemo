import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Question 클래스 정의
class Question {
  final String def; // 질문
  final String word; // 정답
  final List<String> options; // 선택지
  final int w_id; // 문제 ID
  bool isCorrect; // 사용자가 문제를 맞췄는지 여부

  Question({
    required this.def,
    required this.word,
    required this.options,
    required this.w_id,
    this.isCorrect = true,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      def: map['def'] as String,
      word: map['word'] as String,
      options: List<String>.from(map['options']), // Firestore의 options 필드 매핑
      w_id: map['w_id'] as int, // wId에서 w_id로 변경
    );
  }
}

// ChoiceQuizPage 정의
class ChoiceQuizPage extends StatefulWidget {
  @override
  _ChoiceQuizPageState createState() => _ChoiceQuizPageState();
}

class _ChoiceQuizPageState extends State<ChoiceQuizPage> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('CQ').get();
      final questions = snapshot.docs.map((doc) => Question.fromMap(doc.data())).toList();
      questions.shuffle();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching questions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문제를 불러오는 데 실패했습니다. 다시 시도해주세요.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('객관식 퀴즈'), backgroundColor: Colors.teal),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('객관식 퀴즈'), backgroundColor: Colors.teal),
        body: Center(child: Text('퀴즈 데이터가 없습니다.')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('객관식 퀴즈'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 질문 카드
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black // 다크 모드일 때 배경색 검은색
                    : Colors.teal.shade50, // 라이트 모드일 때 배경색
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal, width: 2),
              ),
              child: Text(
                "문제: ${currentQuestion.def}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black, // 다크 모드에 따라 텍스트 색상 변경
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // 선택지 카드
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final option = currentQuestion.options[index];
                  return GestureDetector(
                    onTap: () => _checkAnswer(currentQuestion, option),
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black, // 다크 모드에 따라 텍스트 색상 변경
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswer(Question question, String selectedOption) {
    setState(() {
      if (selectedOption == question.word) {
        _showResultDialog(true);
      } else {
        question.isCorrect = false;
        _saveWrongAnswer(question);
        _showResultDialog(false);
      }
    });
  }

  void _saveWrongAnswer(Question question) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("사용자가 로그인되어 있지 않습니다.");
      }
      final uid = user.uid;

      final userDoc = FirebaseFirestore.instance.collection('UserData').doc(uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);

        if (!snapshot.exists) {
          transaction.set(userDoc, {
            'wrongAnswerIds': [question.w_id], // wId에서 w_id로 변경
          });
        } else {
          final data = snapshot.data() as Map<String, dynamic>;
          final wrongAnswerIds = List<int>.from(data['wrongAnswerIds'] ?? []);

          if (!wrongAnswerIds.contains(question.w_id)) {
            wrongAnswerIds.add(question.w_id);
            transaction.update(userDoc, {
              'wrongAnswerIds': wrongAnswerIds,
            });
          }
        }
      });

      print('틀린 문제 ID가 성공적으로 저장되었습니다: ${question.w_id}');
    } catch (e) {
      print('오답 저장 중 오류 발생: $e');
    }
  }

  void _showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCorrect ? '정답입니다!' : '오답입니다.'),
          content: Text(
            isCorrect
                ? '잘했습니다! 다음 문제로 넘어갑니다.'
                : '정답은 "${_questions[_currentQuestionIndex].word}"입니다.',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black, // 다크 모드에 따라 텍스트 색상 변경
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _moveToNextQuestion();
              },
              child: Text('다음'),
            ),
          ],
        );
      },
    );
  }

  void _moveToNextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('퀴즈 완료'),
          content: Text(
            '모든 문제를 푸셨습니다!',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black, // 다크 모드에 따라 텍스트 색상 변경
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('메인으로'),
            ),
          ],
        );
      },
    );
  }
}
