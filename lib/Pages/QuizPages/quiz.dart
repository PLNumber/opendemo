import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Function/class.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('WQ').get();
      final questions =
          snapshot.docs.map((doc) => Question.fromMap(doc.data())).toList();
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
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 풀기')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 풀기')),
        body: Center(child: Text('퀴즈 데이터가 없습니다.')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('퀴즈 풀기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 질문 표시
            Text(
              "문제: ${currentQuestion.def}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // 답 입력 필드
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: '정답을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // 제출 버튼
            ElevatedButton(
              onPressed: () => _checkAnswer(currentQuestion),
              child: Text('제출'),
            ),
          ],
        ),
      ),
    );
  }

  // 정답 체크 및 오답 처리
  void _checkAnswer(Question question) {
    String userAnswer = _answerController.text.trim();

    setState(() {
      if (userAnswer.toLowerCase() == question.word.toLowerCase()) {
        _showResultDialog(true);
      } else {
        question.isCorrect = false;
        _saveWrongAnswer(question);
        _showResultDialog(false);
      }

      _answerController.clear();
    });
  }

  // 오답 저장
  void _saveWrongAnswer(Question question) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('wrongAnswers')
          .where('w_id', isEqualTo: question.wId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        final docRef =
            FirebaseFirestore.instance.collection('wrongAnswers').doc();
        await docRef.set(question.toMap());
        print('Wrong answer saved.');
      } else {
        print('This question has already been saved in wrong answers.');
      }
    } catch (e) {
      print('Error saving wrong answer: $e');
    }
  }

  // 결과 다이얼로그
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

  // 다음 문제로 넘어가기
  void _moveToNextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _showCompletionDialog();
      }
    });
  }

  // 퀴즈 완료 다이얼로그
  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('퀴즈 완료'),
          content: Text('모든 문제를 푸셨습니다!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // 메인 페이지로 돌아가기
              },
              child: Text('메인으로'),
            ),
          ],
        );
      },
    );
  }
}
