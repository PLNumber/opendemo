import 'package:flutter/material.dart';
import '../../Function/Battle/gameFunc.dart';

class GameRoomPage extends StatefulWidget {
  final String roomId;
  final String playerId;

  const GameRoomPage({Key? key, required this.roomId, required this.playerId}) : super(key: key);

  @override
  _GameRoomPageState createState() => _GameRoomPageState();
}

class _GameRoomPageState extends State<GameRoomPage> {
  late GameFunction gameFunctions;
  bool isWaiting = true; // 대기 상태 관리
  List<String> messages = []; // 메시지 리스트

  @override
  void initState() {
    super.initState();
    gameFunctions = GameFunction();

    // 방에 플레이어 추가
    gameFunctions.addPlayerToRoom(widget.roomId, widget.playerId).then((_) {
      // 플레이어 추가 리스너 설정
      _setupPlayerListener();
      // 질문 로드 및 대기 상태 확인
      loadQuestionsAndCheckReady();
    }).catchError((error) {
      print("Error adding player to room: $error");
    });
  }

  Future<void> loadQuestionsAndCheckReady() async {
    try {
      await gameFunctions.loadSharedQuestions();
      await _checkIfReady();
    } catch (error) {
      print("Error loading questions44: $error");
      setState(() {
        gameFunctions.isLoading = false;
      });
    }
  }

  Future<void> _checkIfReady() async {
    final roomData = await gameFunctions.getRoomData(widget.roomId);

    if (roomData['players'] != null) {
      int playerCount = roomData['players'].length;

      if (playerCount > 1) {
        setState(() {
          isWaiting = false; // 대기 상태 해제
        });

        // 각 플레이어의 상태를 active로 변경
        for (var playerId in roomData['players'].keys) {
          await gameFunctions.updatePlayerStatus(widget.roomId, playerId, "active");
        }
      }
    }
  }

  // 플레이어 추가 리스너 설정
  void _setupPlayerListener() {
    gameFunctions.roomsRef.child(widget.roomId).child('players').onChildAdded.listen((event) {
      final playerId = event.snapshot.key;
      if (playerId != widget.playerId) {
        setState(() {
          messages.add("$playerId가 들어왔습니다."); // 메시지 추가
        });
      }
    });
  }

  // 방에서 나가기 기능
  void _leaveRoom() async {
    await gameFunctions.leaveRoom(widget.roomId, widget.playerId);
    Navigator.pop(context); // 이전 화면으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("게임 방"),
        leading:  IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _leaveRoom,
          ),
      ),
      body: gameFunctions.isLoading
          ? const Center(child: CircularProgressIndicator())
          : isWaiting
          ? Center(child: Text("상대방을 기다리는 중..."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 들어온 플레이어 메시지 표시
            ...messages.map((msg) => Text(msg, style: TextStyle(color: Colors.blue))),
            const SizedBox(height: 20),
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
                  gameFunctions.submitAnswer(true); // 플레이어의 답변 제출
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
            const SizedBox(height: 20),
            Text(
              "내 점수: ${gameFunctions.playerScore}  |  상대 점수: ${gameFunctions.opponentScore}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
