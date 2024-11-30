import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Function/class.dart';

class GameRoomPage extends StatefulWidget {
  final String roomId;

  const GameRoomPage({Key? key, required this.roomId}) : super(key: key);

  @override
  _GameRoomPageState createState() => _GameRoomPageState();
}

class _GameRoomPageState extends State<GameRoomPage> {
  final DatabaseReference _questionsRef = FirebaseDatabase.instance.ref("questions");

  List<Question> questions = [];
  int currentQuestionIndex = 0;
  String? playerAnswer;
  String matchStatus = "문제를 풀어보세요!";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final event = await _questionsRef.once();
      if (event.snapshot.exists) {
        final data = event.snapshot.value;

        if (data is Map) {
          // Map일 경우
          questions = _getQuestionsFromSharedData(data);
        } else if (data is List) {
          // List일 경우
          questions = _getQuestionsFromSharedList(data);
        } else {
          _updateMatchStatus("예상하지 못한 데이터 형식입니다.");
        }

        print("Loaded questions count: ${questions.length}");
      } else {
        _updateMatchStatus("질문이 없습니다.");
      }
    } catch (e) {
      _updateMatchStatus("문제를 불러오는 중 오류 발생: $e");
    } finally {
      setState(() {
        isLoading = false; // 로딩 완료
      });
    }
  }

// List<Object?>에서 Question 객체로 변환하는 메서드
  List<Question> _getQuestionsFromSharedList(List<Object?> dataList) {
    List<Question> loadedQuestions = [];
    Set<int> uniqueIds = {};

    for (var item in dataList) {
      if (item is Map<String, dynamic>) {
        Question question = Question.fromMap(item);
        if (!uniqueIds.contains(question.wId)) {
          uniqueIds.add(question.wId);
          loadedQuestions.add(question);
        }
      }
    }

    return loadedQuestions;
  }


  void _updateMatchStatus(String message) {
    setState(() {
      matchStatus = message;
    });
  }

  // Map에서 List<Question>으로 변환
  List<Question> _getQuestionsFromSharedData(Map<Object?, Object?> data) {
    List<Question> loadedQuestions = [];
    Set<int> uniqueIds = {};

    data.forEach((key, value) {
      Question question = Question.fromMap(value as Map<String, dynamic>);
      if (!uniqueIds.contains(question.wId)) {
        uniqueIds.add(question.wId);
        loadedQuestions.add(question);
      }
    });

    return loadedQuestions;
  }

  void _submitAnswer() {
    if (playerAnswer == null || playerAnswer!.isEmpty) return;

    bool isCorrect = questions[currentQuestionIndex].word == playerAnswer;
    setState(() {
      matchStatus = isCorrect ? "정답입니다!" : "틀렸습니다. 다시 시도해보세요!";
    });

    // 다음 문제로 이동
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        playerAnswer = null; // 답변 초기화
      });
    } else {
      setState(() {
        matchStatus = "모든 문제를 풀었습니다!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("게임 방"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : questions.isEmpty
          ? Center(child: Text(matchStatus))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "문제 ${currentQuestionIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              questions[currentQuestionIndex].def,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                playerAnswer = value;
              },
              decoration: InputDecoration(
                labelText: "답변을 입력하세요",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: const Text("제출"),
            ),
            const SizedBox(height: 20),
            Text(
              matchStatus,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
