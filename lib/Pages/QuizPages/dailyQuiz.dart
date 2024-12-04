import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Function/class.dart';

class SingleQuizPage extends StatefulWidget {
  @override
  _SingleQuizPageState createState() => _SingleQuizPageState();
}

class _SingleQuizPageState extends State<SingleQuizPage> {
  Question? _question;
  final TextEditingController _answerController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomQuestion();
  }

  Future<void> _fetchRandomQuestion() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('WQ').get();
      if (snapshot.docs.isNotEmpty) {
        final randomDoc = snapshot.docs..shuffle(); // 랜덤 섞기
        setState(() {
          _question = Question.fromMap(randomDoc.first.data());
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('퀴즈 데이터가 없습니다.')),
        );
      }
    } catch (e) {
      print('Error fetching question: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문제를 불러오는 데 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  Future<void> _updateUserPoints(int points) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('UserData').doc(user.uid);
        await userDoc.update({'shopPt': FieldValue.increment(points)});
        print('User points updated by $points.');
      }
    } catch (e) {
      print('Error updating user points: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('포인트를 업데이트하는 데 실패했습니다.')),
      );
    }
  }

  void _checkAnswer() {
    if (_question == null) return;

    final userAnswer = _answerController.text.trim();
    final isCorrect = userAnswer.toLowerCase() == _question!.word.toLowerCase();

    if (isCorrect) {
      _updateUserPoints(300); // 정답 시 포인트 추가
    }

    _showResultDialog(isCorrect);
  }

  void _showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCorrect ? '정답입니다!' : '오답입니다.'),
          content: Text(
            isCorrect
                ? '잘했습니다! 포인트가 300 추가되었습니다.'
                : '정답은 "${_question?.word}"입니다.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // 메인 화면으로 이동
              },
              child: Text('메인으로'),
            ),
          ],
        );
      },
    );
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

    if (_question == null) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 풀기')),
        body: Center(child: Text('퀴즈 데이터가 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('퀴즈 풀기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "문제: ${_question!.def}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: '정답을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: Text('제출'),
            ),
          ],
        ),
      ),
    );
  }
}
