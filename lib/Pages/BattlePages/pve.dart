import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Function/class.dart';

class QuizBattlePage extends StatefulWidget {
  @override
  _QuizBattlePageState createState() => _QuizBattlePageState();
}

class _QuizBattlePageState extends State<QuizBattlePage> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _userHealth = 100;
  int _aiHealth = 100;
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  bool _isLoading = true;
  int _timeLeft = 10;
  late Timer _timer;
  Timer? _aiTimer;
  String? _resultMessage;

  double _userRotationAngle = 0.0;  // 사용자 회전 각도
  double _aiRotationAngle = 0.0;    // 상대 회전 각도
  double rotationSpeed = 0.3;        // 회전 속도 (빠르게 설정)

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('WQ').get();
      final questions = snapshot.docs
          .map((doc) => Question.fromMap(doc.data()))
          .toList();
      setState(() {
        _questions = questions;
        _isLoading = false;
        _startTimer();
      });
    } catch (e) {
      print('Error fetching questions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('문제를 불러오는 데 실패했습니다. 다시 시도해주세요.')));
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _startTimer() {
    _timeLeft = 10;
    _resultMessage = null;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        _checkAnswer('');
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
    _simulateAiAnswer();
  }

  void _simulateAiAnswer() {
    _aiTimer?.cancel();
    int aiDelay = Random().nextInt(5) + 3;
    _aiTimer = Timer(Duration(seconds: aiDelay), () {
      if (_timeLeft > 0) {
        _checkAnswer(_questions[_currentQuestionIndex].word, isUser: false);
      }
    });
  }

  void _checkAnswer(String userAnswer, {bool isUser = true}) {
    if (isUser && userAnswer.trim().isEmpty) {
      return;
    }

    final question = _questions[_currentQuestionIndex];
    String correctAnswer = question.word.toLowerCase();

    setState(() {
      if (isUser) {
        if (userAnswer.toLowerCase() == correctAnswer) {
          _aiHealth = max(0, _aiHealth - 10);
          _resultMessage = '정답입니다!';
          _rotateOpponent();
        } else {
          _resultMessage = '오답입니다!';
        }
      } else if (!isUser && correctAnswer == question.word.toLowerCase()) {
        _userHealth = max(0, _userHealth - 10);
        _rotateUser();
      }

      _timer.cancel();
      _aiTimer?.cancel();
      _moveToNextQuestion();
    });
  }

  void _rotateOpponent() {
    double rotation = 2 * pi * 3;  // 3바퀴 회전
    Timer.periodic(Duration(milliseconds: 16), (timer) {  // 60Hz로 타이머 주기 설정
      setState(() {
        _aiRotationAngle += rotationSpeed;  // 회전 속도에 맞춰 회전 각도 업데이트
        if (_aiRotationAngle >=  pi * 4) {
          _aiRotationAngle = 0.0;  // 3바퀴 회전 후 초기화
          timer.cancel();
        }
      });
    });
  }

  void _rotateUser() {
    double rotation = 2 * pi * 3;  // 3바퀴 회전
    Timer.periodic(Duration(milliseconds: 16), (timer) {  // 60Hz로 타이머 주기 설정
      setState(() {
        _userRotationAngle += rotationSpeed;  // 회전 속도에 맞춰 회전 각도 업데이트
        if (_userRotationAngle >= pi * 4) {
          _userRotationAngle = 0.0;  // 3바퀴 회전 후 초기화
          timer.cancel();
        }
      });
    });
  }

  void _moveToNextQuestion() {
    if (_userHealth <= 0 || _aiHealth <= 0) {
      _showGameOverDialog();
      return;
    }

    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _answerController.clear();
        _startTimer();
        _focusOnAnswerField();
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _focusOnAnswerField() {
    Future.delayed(Duration(milliseconds: 100), () {
      _answerFocusNode.requestFocus();
    });
  }

  void _showGameOverDialog() {
    String winner = _userHealth > 0 ? "사용자" : "AI";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("게임 종료"),
          content: Text("$winner가 승리했습니다!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("메인으로"),
            ),
          ],
        );
      },
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("퀴즈 완료"),
          content: Text("모든 문제를 푸셨습니다!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("메인으로"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _aiTimer?.cancel();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Widget _buildOpponentUI() {
    return Column(
      children: [
        Text(
          "상대 체력 (${_aiHealth}/100)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        LinearProgressIndicator(
          value: _aiHealth / 100,
          color: Colors.green,
          backgroundColor: Colors.red,
          minHeight: 20,
        ),
        SizedBox(height: 10),
        Transform(
          transform: Matrix4.rotationY(_aiRotationAngle),  // 상대 회전
          alignment: Alignment.center,
          child: Container(
            width: 100,
            height: 100,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildUserHealthBar() {
    return Column(
      children: [
        Text(
          "내 체력 (${_userHealth}/100)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: _userHealth / 100,
          color: Colors.green,
          backgroundColor: Colors.red,
          minHeight: 20,
        ),
      ],
    );
  }

  Widget _buildUserCharacter() {
    return Transform(
      transform: Matrix4.rotationY(_userRotationAngle),  // 사용자 회전
      alignment: Alignment.center,
      child: Container(
        width: 100,
        height: 100,
        color: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 대결')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 대결')),
        body: Center(child: Text('퀴즈 데이터가 없습니다.')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text("퀴즈 대결")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOpponentUI(),
            SizedBox(height: 20),
            _buildUserHealthBar(),
            SizedBox(height: 20),
            _buildUserCharacter(),
            SizedBox(height: 40),
            Text(
              "문제: ${currentQuestion.def}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              focusNode: _answerFocusNode,
              decoration: InputDecoration(
                labelText: '정답을 입력하세요',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _checkAnswer(value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _checkAnswer(_answerController.text);
              },
              child: Text('제출'),
            ),
          ],
        ),
      ),
    );
  }
}