// gameroom.dart
import 'package:flutter/material.dart';
import '../../Function/Battle/gameFunc.dart';

class GameRoomPage extends StatefulWidget {
  final String roomId;
  final String playerId; // 플레이어 ID 추가

  const GameRoomPage({Key? key, required this.roomId, required this.playerId}) : super(key: key);

  @override
  _GameRoomPageState createState() => _GameRoomPageState();
}

class _GameRoomPageState extends State<GameRoomPage> {
  late GameFunctions gameFunctions;

  @override
  void initState() {
    super.initState();
    gameFunctions = GameFunctions();
    gameFunctions.loadSharedQuestions().then((_) {
      setState(() {
        // 데이터 로딩 완료 후 로딩 상태 변경
        gameFunctions.isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        gameFunctions.isLoading = false;
      });
      print("Error loading questions: $error");
    });
  }

  // 방에서 나가기 기능
  void _leaveRoom() async {
    await gameFunctions.leaveRoom(widget.roomId, widget.playerId);  // 플레이어 ID를 함께 전달
    Navigator.pop(context); // 이전 화면으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("게임 방"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _leaveRoom, // 나가기 버튼
          ),
        ],
      ),
      body: gameFunctions.isLoading
          ? const Center(child: CircularProgressIndicator())
          : gameFunctions.questions.isEmpty
          ? Center(
        child: Text(
          gameFunctions.matchStatus,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "문제 ${gameFunctions.currentQuestionIndex + 1} / ${gameFunctions.questions.length}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              gameFunctions.questions[gameFunctions.currentQuestionIndex].def,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) => gameFunctions.playerAnswer = value,
              decoration: const InputDecoration(
                labelText: "답변을 입력하세요",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  gameFunctions.submitAnswer();
                });
              },
              child: const Text("제출"),
            ),
            const SizedBox(height: 20),
            Text(
              gameFunctions.matchStatus,
              style: TextStyle(
                fontSize: 16,
                color: gameFunctions.matchStatus == "정답입니다!" ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
