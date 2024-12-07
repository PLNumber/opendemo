import 'package:flutter/material.dart';
import '../../Function/Battle/gameFunc.dart';

//gameRoom.dart
class GameRoomPage extends StatefulWidget {
  final String roomId;
  final String playerId;

  const GameRoomPage({Key? key, required this.roomId, required this.playerId})
      : super(key: key);

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
    gameFunctions = GameFunction(onScoreUpdated: () {
      setState(() {
        //UI 업데이트 로직
      });
    });
    _setupPlayerLeftListener(); // 플레이어 나가기 리스너 설정

    // 방에 플레이어 추가
    gameFunctions.addPlayerToRoom(widget.roomId, widget.playerId).then((_) {
      _setupPlayerListener();
      //_setupScoreListener(); // 점수 리스너 설정
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
            await gameFunctions.updatePlayerStatus(
                widget.roomId, playerId, "active");
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

  void _setupPlayerListener() {
    gameFunctions.roomsRef
        .child(widget.roomId)
        .child('players')
        .onChildAdded
        .listen((event) {
      final playerId = event.snapshot.key;
      if (playerId != widget.playerId) {
        setState(() {
          messages.add("$playerId가 들어왔습니다."); // 메시지 추가
          gameFunctions.opponentId = playerId; // 상대방 ID 설정
          // 플레이어가 들어오면 대기 상태 해제 체크
          _checkIfReady(); // 대기 상태를 체크하여 UI 업데이트
          _setupScoreListener(); // 상대방 ID가 설정된 후 점수 리스너 설정
        });
      }
    });
  }

  void _setupQuestionIndexListener() {
    gameFunctions.roomsRef
        .child(widget.roomId)
        .child('currentQuestionIndex')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          gameFunctions.currentQuestionIndex = event.snapshot.value as int;
        });
      }
    });
  }

  void _setupScoreListener() {
    // 내 점수 리스너
    gameFunctions.roomsRef
        .child(widget.roomId)
        .child('players')
        .child(widget.playerId)
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<Object?, Object?>;
        setState(() {
          gameFunctions.playerScore = (data['score'] ?? 0) as int;
        });
        print("내 점수: ${gameFunctions.playerScore}"); // 내 점수 출력
      }
    });

    // 상대방 점수 리스너
    if (gameFunctions.opponentId != null) {
      gameFunctions.roomsRef
          .child(widget.roomId)
          .child('players')
          .child(gameFunctions.opponentId!)
          .onValue
          .listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<Object?, Object?>;
          setState(() {
            gameFunctions.opponentScore = (data['score'] ?? 0) as int;
          });
          print("상대 점수 업데이트: ${gameFunctions.opponentScore}"); // 상대 점수 출력
        }
      });
    }
  }

  // 방 나가기 메서드
  Future<void> _leaveRoom() async {
    // 나가기 전에 경고 메시지 표시
    bool? confirmExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("경고"),
          content: const Text("정말 방을 나가시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // 취소
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // 확인
              child: const Text("확인"),
            ),
          ],
        );
      },
    );

    if (confirmExit == true) {
      try {
        await gameFunctions.leaveRoom(widget.roomId, widget.playerId);
        // 상대방에게 나갔다는 메시지 전송
        _notifyOpponentPlayerLeft(widget.roomId, widget.playerId);
        Navigator.pop(context); // 이전 화면으로 돌아가기
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("방 나가는 중 오류 발생: $e")));
      }
    }
  }

  // 상대방에게 플레이어 나갔다는 알림 전송
  void _notifyOpponentPlayerLeft(String roomId, String playerId) {
    gameFunctions.roomsRef.child(roomId).child('messages').push().set({
      'type': 'player_left',
      'playerId': playerId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 상대방의 메시지를 수신하여 UI 업데이트
  void _setupPlayerLeftListener() {
    gameFunctions.roomsRef
        .child(widget.roomId)
        .child('messages')
        .onChildAdded
        .listen((event) {
      final messageData = event.snapshot.value as Map;
      if (messageData['type'] == 'player_left') {
        final leftPlayerId = messageData['playerId'];
        setState(() {
          messages.add("$leftPlayerId가 방을 나갔습니다."); // 메시지 추가
          // 상대방이 나가면 자신도 방을 강제로 나감
          if (leftPlayerId != widget.playerId) {
            messages.add("상대가 나갔습니다."); // 상대가 나갔다는 메시지 추가
            _forceLeaveRoom(); // 자신도 강제로 방을 나감
          }
        });
      }
    });
  }

// 방을 강제로 나가는 메서드
  void _forceLeaveRoom() async {
    // 경고 메시지를 확인하기 위한 다이얼로그 표시
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("상대방이 나갔습니다"),
          content: const Text("방을 나갑니다."),
          actions: [
            TextButton(
              onPressed: () {
                // 확인 버튼 클릭 시 방 나가기
                _notifyOpponentPlayerLeft(widget.roomId, widget.playerId); // 상대에게 나갔다는 메시지 전송
                Navigator.pop(context); // 이전 화면으로 돌아가기
                Navigator.pop(context); // 방 나가기
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }


  // 답변 제출 처리
  void _submitAnswer() async {
    if (gameFunctions.playerAnswer == null ||
        gameFunctions.playerAnswer!.isEmpty) {
      return; // 답변이 비어있으면 아무것도 하지 않음
    }

    try {
      // 플레이어의 답변 제출
      await gameFunctions.submitAnswer(
          widget.roomId, widget.playerId, gameFunctions.playerAnswer!);

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
    print(
        "내 점수22: ${gameFunctions.playerScore}, 상대 점수22: ${gameFunctions.opponentScore}"); // UI 갱신 후 점수 출력
    return PopScope(
      canPop: false, // 시스템 뒤로가기를 비활성화
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        // 시스템이 이미 Pop을 처리한 경우 종료
        if (didPop) return;

        // 방 나가기 메서드 호출
        await _leaveRoom();
      },
      child: Scaffold(
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
                            ...messages.map((msg) =>
                                Text(msg, style: TextStyle(color: Colors.blue))),
                            const SizedBox(height: 20),
                            Text(
                              "문제 ${gameFunctions.currentQuestionIndex + 1} / ${gameFunctions.questions.length}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              gameFunctions.questions.isNotEmpty
                                  ? gameFunctions
                                      .questions[
                                          gameFunctions.currentQuestionIndex]
                                      .def
                                  : '질문이 없습니다.',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              onChanged: (value) =>
                                  gameFunctions.playerAnswer = value,
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
                                color:
                                    gameFunctions.matchStatus.contains("정답입니다!")
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "내 점수: ${gameFunctions.playerScore}  |  상대 점수: ${gameFunctions.opponentScore}",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
      ),
    );
  }

}
