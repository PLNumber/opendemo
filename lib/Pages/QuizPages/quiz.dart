import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? _currentHint;
  bool _isHintUsed = false;

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
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('퀴즈 풀기'), // 기본 텍스트 설정
          centerTitle: true, // 가운데 정렬
          backgroundColor: Colors.teal,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('퀴즈 풀기'), // 기본 텍스트 설정
          centerTitle: true, // 가운데 정렬
          backgroundColor: Colors.teal,
        ),
        body: Center(child: Text('퀴즈 데이터가 없습니다.')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('퀴즈 풀기'), // 기본 텍스트 설정
        centerTitle: true, // 가운데 정렬
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 질문 카드 디자인 수정
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.teal.shade50,
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
                      : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            // 답 입력 필드
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: '정답을 입력하세요',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
            ),
            SizedBox(height: 20),
            // 제출 및 힌트 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 힌트 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 흰색 배경
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isHintUsed
                      ? null
                      : () {
                    setState(() {
                      _isHintUsed = true;
                    });
                    _showHint(currentQuestion); // 힌트 표시
                  },
                  child: Text(
                    _isHintUsed ? _currentHint! : '힌트 보기',
                    style: TextStyle(color: Colors.black), // 검은색 글씨
                  ),
                ),
                SizedBox(width: 16),
                // 제출 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 흰색 배경
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _checkAnswer(currentQuestion),
                  child: Text(
                    '제출',
                    style: TextStyle(color: Colors.black), // 검은색 글씨
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
      _resetHint();
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
            'wrongAnswerIds': [question.wId],
          });
        } else {
          final data = snapshot.data() as Map<String, dynamic>;
          final wrongAnswerIds = List<int>.from(data['wrongAnswerIds'] ?? []);

          if (!wrongAnswerIds.contains(question.wId)) {
            wrongAnswerIds.add(question.wId);
            transaction.update(userDoc, {
              'wrongAnswerIds': wrongAnswerIds,
            });
          }
        }
      });

      print('틀린 문제 ID가 성공적으로 저장되었습니다: ${question.wId}');
    } catch (e) {
      print('오답 저장 중 오류 발생: $e');
    }
  }

  void _showHint(Question question) {
    setState(() {
      _currentHint = question.hint; // Firestore에서 힌트를 가져오도록 수정
      _isHintUsed = true;
    });
  }

  void _resetHint() {
    setState(() {
      _currentHint = null;
      _isHintUsed = false;
    });
  }

  void _showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCorrect ? '정답입니다!' : '오답입니다.', style: TextStyle(color: Colors.teal)),
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
              child: Text('다음', style: TextStyle(color: Colors.teal)),
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
          title: Text('퀴즈 완료', style: TextStyle(color: Colors.teal)),
          content: Text('모든 문제를 푸셨습니다!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('메인으로', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }
}
