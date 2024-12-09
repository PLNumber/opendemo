import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '../../Function/class.dart';

class QuizBattlePage extends StatefulWidget {
  @override
  _QuizBattlePageState createState() => _QuizBattlePageState();
}

class _QuizBattlePageState extends State<QuizBattlePage>
    with TickerProviderStateMixin {
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
  late AnimationController _rotationController;
  bool _rotateOpponent = false;
  bool _rotateUser = false;

  late AnimationController _userHealthController;
  late AnimationController _aiHealthController;

  double _userHealthTotalFrames = 61; // Default value if not available
  double _aiHealthTotalFrames = 61; // Default value if not available

  Map<String, dynamic>? _userData;
  bool _isUserDataLoading = true;

  String _opponentAnimationPath = 'assets/animation/default.json';

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _userHealthController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _aiHealthController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fetchUserData();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _timer.cancel();
    _aiTimer?.cancel();
    _rotationController.dispose();
    _userHealthController.dispose();
    _aiHealthController.dispose();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }
      final userDoc = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data();
          _isUserDataLoading = false;
        });
      } else {
        throw Exception("User data not found");
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 데이터를 가져오는 데 실패했습니다. 다시 시도해주세요.')),
      );
      setState(() {
        _isUserDataLoading = false;
      });
    }
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
        _startTimer();
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

  void _updateHealthBar(AnimationController controller, int health, double totalFrames) {
    double targetFrame = totalFrames * (health / 100);
    controller.animateTo(targetFrame / totalFrames);
    controller.addListener(() {
      double currentFrame = totalFrames * controller.value;
      print("Current Frame: ${currentFrame.toStringAsFixed(2)}");
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
          _updateHealthBar(_aiHealthController, _aiHealth, _aiHealthTotalFrames);
          _triggerRotation(isOpponent: true);
        } else {
          _resultMessage = '오답입니다!';
          return;
        }
      } else if (!isUser && correctAnswer == question.word.toLowerCase()) {
        _userHealth = max(0, _userHealth - 10);
        _updateHealthBar(_userHealthController, _userHealth, _userHealthTotalFrames);
        _triggerRotation(isOpponent: false);
      }

      _timer.cancel();
      _aiTimer?.cancel();
      _moveToNextQuestion();
    });
  }

  void _triggerRotation({required bool isOpponent}) {
    setState(() {
      if (isOpponent) {
        _rotateOpponent = true;
      } else {
        _rotateUser = true;
      }
    });

    if (isOpponent) {
      setState(() {
        _opponentAnimationPath = 'assets/animation/angry.json';
      });
    } else {
      setState(() {
        _opponentAnimationPath = 'assets/animation/laugh.json';
      });
    }
    _rotationController.forward(from: 0).whenComplete(() {
      setState(() {
        if (isOpponent) {
          _rotateOpponent = false;
          _opponentAnimationPath = _aiHealth > 50
              ? 'assets/animation/default.json'
              : 'assets/animation/desperate.json';
        } else {
          _rotateUser = false;
          _opponentAnimationPath = _aiHealth > 50
              ? 'assets/animation/default.json'
              : 'assets/animation/desperate.json';
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

  void _showGameOverDialog() async {
    String winner = _userHealth > 0 ? "사용자" : "AI";
    String message = "$winner가 승리했습니다!";

    if (winner == "사용자" && _userData != null) {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('UserData')
              .doc(uid)
              .update({'shopPt': FieldValue.increment(100)});
          message += "\n100 상점 포인트 획득!";
        }
      } catch (e) {
        print('Error updating shopPt: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('점수를 업데이트하는 데 실패했습니다.')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("게임 종료"),
          content: Text(message),
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

  Widget _buildOpponentHealthBar() {
    return Column(
      children: [
        Text(
          "AI",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        Lottie.asset(
          'assets/animation/health_bar.json',
          controller: _aiHealthController,
          onLoaded: (composition) {
            _aiHealthController.duration = composition.duration;
            _aiHealthTotalFrames = composition.duration.inSeconds * composition.frameRate;
            print("AI Health Animation Total Frames: $_aiHealthTotalFrames");

            _aiHealthController.addListener(() {
              double currentFrame = _aiHealthTotalFrames * _aiHealthController.value;
              print("AI Health Animation Current Frame: ${currentFrame.toStringAsFixed(2)}");
            });

            _updateHealthBar(_aiHealthController, _aiHealth, _aiHealthTotalFrames);
          },
        ),
      ],
    );
  }

  Widget _buildUserCharacter() {
    if (_isUserDataLoading || _userData == null) {
      return CircularProgressIndicator();
    }

    String profileImg = _userData!['profileImg'] ?? '';

    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        double rotationValue = _rotateUser ? _rotationController.value * pi * 4 : 0;
        return Transform(
          transform: Matrix4.rotationY(rotationValue),
          alignment: Alignment.center,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: profileImg.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(profileImg),
                fit: BoxFit.cover,
              )
                  : null,
              color: profileImg.isEmpty ? Colors.green : null,
            ),
            child: profileImg.isEmpty
                ? Center(
              child: Text(
                'USER',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildOpponentCharacter() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        double rotationValue = _rotateOpponent ? _rotationController.value * pi * 4 : 0;
        return Transform(
          transform: Matrix4.rotationY(rotationValue),
          alignment: Alignment.center,
          child: Container(
            width: 100,
            height: 100,
            child: Lottie.asset(
              _opponentAnimationPath,
              repeat: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserHealthBar() {
    return Column(
      children: [
        Text(
          "내 체력",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        Lottie.asset(
          'assets/animation/health_bar.json',
          controller: _userHealthController,
          onLoaded: (composition) {
            _userHealthController.duration = composition.duration;
            _userHealthTotalFrames = composition.duration.inSeconds * composition.frameRate;
            print("User Health Animation Total Frames: $_userHealthTotalFrames");
            _userHealthController.addListener(() {
              double currentFrame = _userHealthTotalFrames * _userHealthController.value;
              print("User Health Animation Current Frame: ${currentFrame.toStringAsFixed(2)}");
            });
            _updateHealthBar(_userHealthController, _userHealth, _userHealthTotalFrames);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('퀴즈 대결'),
          centerTitle: true, // centerTitle 속성을 true로 설정
          backgroundColor: Colors.teal, // 앱바 색깔을 틸로 변경
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('퀴즈 대결'),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        body: Center(child: Text('퀴즈 데이터가 없습니다.')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("퀴즈 대결"),
        centerTitle: true, // centerTitle 속성 추가
        backgroundColor: Colors.teal, // 앱바 색깔 설정
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildOpponentCharacter(),
              SizedBox(height: 20),
              _buildOpponentHealthBar(),
              SizedBox(height: 20),
              _buildUserCharacter(),
              SizedBox(height: 20),
              _buildUserHealthBar(),
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
      ),
    );
  }
}

