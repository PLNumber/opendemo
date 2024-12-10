import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Function/class.dart';

class GhostPage extends StatefulWidget {
  @override
  _GhostPageState createState() => _GhostPageState();
}

class _GhostPageState extends State<GhostPage> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _isLoading = true;
  final List<int> _timeRecords = [];
  late int _startTime;

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
        _startTime = DateTime.now().millisecondsSinceEpoch;
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
            centerTitle: true,
            title: Text('퀴즈 풀기'),
            backgroundColor: Colors.teal),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text('퀴즈 풀기'),
            backgroundColor: Colors.teal),
        body: Center(child: Text('퀴즈 데이터가 없습니다.')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('고스트 생성'),
          backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 문제 현황 표시
            Text(
              '문제 진행 상황: $_correctAnswers/10',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // 질문 카드
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
              onSubmitted: (value) {
                _checkAnswer(_questions[_currentQuestionIndex]); // 사용자가 '완료' 버튼을 누르면 정답 확인
              },
            ),
            SizedBox(height: 20),
            // 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 문제 넘기기 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _skipQuestion,
                  child: Text('문제 넘기기', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(width: 16),
                // 제출 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _checkAnswer(currentQuestion),
                  child: Text('제출', style: TextStyle(color: Colors.black)),
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
    int endTime = DateTime.now().millisecondsSinceEpoch;
    int timeTaken = (endTime - _startTime) ~/ 1000;

    setState(() {
      _timeRecords.add(timeTaken);

      if (userAnswer.toLowerCase() == question.word.toLowerCase()) {
        _correctAnswers++;
        if (_correctAnswers >= 10) {
          _showCompletionDialog();
          return;
        }

        _moveToNextQuestion(); // 정답일 때만 다음 문제로 이동
      } else {
        _saveWrongAnswer(question);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오답입니다. 다시 시도해주세요.')),
        );
      }

      _answerController.clear();
    });

    _startTime = DateTime.now().millisecondsSinceEpoch;
  }

  void _skipQuestion() {
    setState(() {
      _moveToNextQuestion();
      _startTime = DateTime.now().millisecondsSinceEpoch;
    });
  }

  void _saveWrongAnswer(Question question) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("사용자가 로그인되어 있지 않습니다.");
      final uid = user.uid;

      final userDoc =
          FirebaseFirestore.instance.collection('UserData').doc(uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);

        if (!snapshot.exists) {
          transaction.set(userDoc, {
            'wrongAnswerIds': [question.wId]
          });
        } else {
          final data = snapshot.data() as Map<String, dynamic>;
          final wrongAnswerIds = List<int>.from(data['wrongAnswerIds'] ?? []);

          if (!wrongAnswerIds.contains(question.wId)) {
            wrongAnswerIds.add(question.wId);
            transaction.update(userDoc, {'wrongAnswerIds': wrongAnswerIds});
          }
        }
      });
    } catch (e) {
      print('오답 저장 중 오류 발생: $e');
    }
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

  void _showCompletionDialog() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("사용자가 로그인되어 있지 않습니다.");

      String uid = user.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(uid)
          .get();

      String userName = userDoc.get('name') ?? 'Unknown';
      String profileImage =
          userDoc.get('profileImg') ?? 'https://via.placeholder.com/150';

      await FirebaseFirestore.instance.collection('pvpGhost').add({
        'userId': uid,
        'userName': userName,
        'profileImage': profileImage,
        'timeRecords': _timeRecords,
        'completedAt': DateTime.now(),
      });

      print('기록이 성공적으로 저장되었습니다!');
    } catch (e) {
      print('기록 저장 중 오류 발생: $e');
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("사용자가 로그인되어 있지 않습니다.");
      final uid = user.uid;

      final userDoc =
          FirebaseFirestore.instance.collection('UserData').doc(uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          int shopPt = data['shopPt'] ?? 0;
          transaction.update(userDoc, {'shopPt': shopPt + 100});
        }
      });
    } catch (e) {
      print('점수 업데이트 중 오류 발생: $e');
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('퀴즈 완료', style: TextStyle(color: Colors.teal)),
          content: Text(
              '모든 문제를 완료했습니다!\n걸린 시간: ${_timeRecords.join(", ")}초\n100 상점 포인트 획득!'),
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
