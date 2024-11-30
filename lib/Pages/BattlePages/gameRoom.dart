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
  bool isLoading = true;  // 로딩 상태 변수 추가

  @override
  void initState() {
    super.initState();
    _loadSharedQuestions(); // 공유 질문 로드
  }

  Future<void> _loadSharedQuestions() async {
    try {
      // 리스너를 한 번만 추가
      _questionsRef.once().then((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value as Map<Object?, Object?>?;
          if (data != null && data.isNotEmpty) {
            setState(() {
              questions = _getQuestionsFromSharedData(data);
              isLoading = false;  // 데이터 로드 완료
            });
          } else {
            setState(() {
              matchStatus = "질문이 없습니다."; // 데이터가 비어 있을 때
              isLoading = false;  // 데이터 로드 완료
            });
          }
        } else {
          setState(() {
            matchStatus = "질문이 없습니다.";  // snapshot.value가 null일 때
            isLoading = false;  // 데이터 로드 완료
          });
        }
      });
    } catch (e) {
      setState(() {
        matchStatus = "문제를 불러오는 중 오류 발생: $e";
        isLoading = false;  // 데이터 로드 완료
      });
    }
  }



  List<Question> _getQuestionsFromSharedData(Map<Object?, Object?> data) {
    List<Question> loadedQuestions = [];
    Set<int> uniqueIds = {}; // 중복 체크를 위한 Set

    data.forEach((key, value) {
      Question question = Question.fromMap(value as Map<String, dynamic>);
      // 중복 여부 체크
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
          ? Center(child: CircularProgressIndicator())  // 로딩 중 표시
          : questions.isEmpty
          ? Center(child: Text(matchStatus))  // 질문이 없을 때 메시지 표시
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
