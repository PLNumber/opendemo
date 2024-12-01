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
      _setupPlayerListener();
      _setupScoreListener(); // 점수 리스너 설정
      _setupQuestionIndexListener();
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
      print("Error loading questions: $error");
      setState(() {
        gameFunctions.isLoading = false; // 로딩 상태 해제
      });
    }
  }

  Future<void> _checkIfReady() async {
    try {
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
    } catch (error) {
      print("Error checking if ready: $error");
      setState(() {
        gameFunctions.isLoading = false; // 오류 발생 시 로딩 상태 해제
      });
    }
  }

  // 플레이어 추가 리스너 설정
  void _setupPlayerListener() {
    gameFunctions.roomsRef.child(widget.roomId).child('players').onChildAdded.listen((event) {
      final playerId = event.snapshot.key;
      if (playerId != widget.playerId) {
        setState(() {
          messages.add("$playerId가 들어왔습니다."); // 메시지 추가
          // 플레이어가 들어오면 대기 상태 해제 체크
          _checkIfReady(); // 대기 상태를 체크하여 UI 업데이트
        });
      }
    });
  }

  void _setupQuestionIndexListener() {
    gameFunctions.roomsRef.child(widget.roomId).child('currentQuestionIndex').onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          gameFunctions.currentQuestionIndex = event.snapshot.value as int;
        });
      }
    });
  }



  void _setupScoreListener() {
    // 내 점수 리스너
    gameFunctions.roomsRef.child(widget.roomId).child('players').child(widget.playerId).onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<Object?, Object?>;
        setState(() {
          gameFunctions.playerScore = (data['score'] ?? 0) as int;
        });
      }
    });

    // 상대방 점수 리스너
    if (gameFunctions.opponentId != null) {
      gameFunctions.roomsRef.child(widget.roomId).child('players').child(gameFunctions.opponentId!).onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<Object?, Object?>;
          setState(() {
            gameFunctions.opponentScore = (data['score'] ?? 0) as int;
          });
        }
      });
    }

    // 정답 알림 리스너 추가
    gameFunctions.roomsRef.child(widget.roomId).child('answers').onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<Object?, Object?>;
        if (data['correctPlayerId'] != null) {
          // 정답을 맞춘 플레이어에 대한 처리
          setState(() {
            gameFunctions.matchStatus = "${data['correctPlayerId']}가 정답을 맞췄습니다!";
          });

          // 다음 문제로 이동
          gameFunctions.moveToNextQuestion(widget.roomId);
        }
      }
    });
  }

// 방 나가기 기능에서 에러 핸들링 추가
  void _leaveRoom() async {
    try {
      await gameFunctions.leaveRoom(widget.roomId, widget.playerId);
      Navigator.pop(context); // 이전 화면으로 돌아가기
    } catch (e) {
      // 에러 메시지를 사용자에게 표시
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("방 나가는 중 오류 발생: $e"))
      );
    }
  }


  // 답변 제출 처리
  void _submitAnswer() async {
    if (gameFunctions.playerAnswer == null || gameFunctions.playerAnswer!.isEmpty) {
      return; // 답변이 비어있으면 아무것도 하지 않음
    }

    try {
      // 플레이어의 답변 제출
      await gameFunctions.submitAnswer(widget.roomId, widget.playerId, gameFunctions.playerAnswer!);

      // UI 업데이트
      setState(() {
        gameFunctions.playerAnswer = null; // 답변 초기화
      });
    } catch (e) {
      print("답변 제출 중 오류 발생: $e"); // 오류 핸들링
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("게임 방"),
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app), // 나가기 아이콘으로 변경
          onPressed: _leaveRoom, // 방 나가기 메서드 호출
        ),
      ),
      body: gameFunctions.isLoading
          ? const Center(child: CircularProgressIndicator())
          : isWaiting
          ? Center(child: Text("상대방을 기다리는 중..."))
          : (gameFunctions.questions.isEmpty
          ? Center(child: Text("질문이 없습니다."))
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
              gameFunctions.questions.isNotEmpty
                  ? gameFunctions.questions[gameFunctions.currentQuestionIndex].def
                  : '질문이 없습니다.',
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
              onPressed: _submitAnswer, // 제출 메서드 호출
              child: const Text("제출"),
            ),
            const SizedBox(height: 20),
            Text(
              gameFunctions.matchStatus,
              style: TextStyle(
                fontSize: 16,
                color: gameFunctions.matchStatus.contains("정답입니다!") ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "내 점수: ${gameFunctions.playerScore}  |  상대 점수: ${gameFunctions.opponentScore}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )),
    );
  }
}
