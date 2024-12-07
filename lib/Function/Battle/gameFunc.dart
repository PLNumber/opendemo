import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import '../../Function/class.dart';

//gameFunc.dart
class GameFunction {
  String? roomId;
  int playerScore = 0;
  int opponentScore = 0;
  final DatabaseReference _questionsRef = FirebaseDatabase.instance.ref("shared/questions");
  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref("rooms");
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  String? playerAnswer;
  String matchStatus = "문제를 불러오는 중입니다...";
  bool isLoading = true;
  String? myPlayerId; // 내 플레이어 ID
  String? opponentId; // 상대방 플레이어 ID
  bool isGameFinished = false; // 게임 종료 여부
  Function? onScoreUpdated;
  Timer? _opponentCheckTimer;
  bool isMovingToNextQuestion = false;

  DatabaseReference get roomsRef => _roomsRef;
  DatabaseReference get questionsRef => _questionsRef;

  // 생성자
  GameFunction({this.onScoreUpdated});

  Future<void> loadSharedQuestions() async {
    try {
      final event = await _questionsRef.once();
      final data = event.snapshot.value;

      if (data is Map<Object?, Object?>) {
        final questionsData = Map<String, dynamic>.from(data);
        questions = _getQuestionsFromSharedData(questionsData);
        isLoading = false;
        matchStatus = questions.isEmpty ? "출제된 문제가 없습니다." : "문제를 풀어보세요!";
      } else {
        updateMatchStatus("문제를 불러오는 중 오류 발생: 데이터 형식 오류");
      }
    } catch (e) {
      updateMatchStatus("문제를 불러오는 중 오류 발생: $e");
    }
  }

  Future<void> addPlayerToRoom(String roomId, String playerId) async {
    this.roomId = roomId; // 방 ID 설정
    myPlayerId = playerId; // 내 플레이어 ID 설정

    // 플레이어 정보를 데이터베이스에 추가
    await _roomsRef.child(roomId).child('players').child(playerId).set({
      "name": playerId,
      "status": "waiting",
      "score": 0,
      "lastSeen": DateTime.now().millisecondsSinceEpoch, // lastSeen 추가
    });

    // 방의 플레이어 목록을 가져오기
    final playersSnapshot = await _roomsRef.child(roomId).child('players').once();
    if (playersSnapshot.snapshot.exists) {
      final players = playersSnapshot.snapshot.value as Map;
      if (players.length > 1) {
        opponentId = players.keys.firstWhere((id) => id != playerId);
        _setupScoreListener(); // 리스너 설정
        startOpponentCheck(roomId); // 상대방 체크 시작
      }
    }
  }

  // 상대방이 나간 후 방 삭제 처리 (leaveRoom 메서드 수정)
  Future<void> leaveRoom(String roomId, String playerId) async {
    try {
      final roomRef = roomsRef.child(roomId);
      final roomSnapshot = await roomRef.get();

      if (roomSnapshot.exists) {
        // 해당 플레이어를 방에서 제거
        await roomRef.child('players').child(playerId).remove();

        // 메시지 삭제
        await roomRef.child('messages').once().then((snapshot) {
          if (snapshot.snapshot.exists) {
            final messages = snapshot.snapshot.value as Map;
            messages.forEach((key, value) {
              roomRef.child('messages').child(key).remove(); // 모든 메시지 삭제
            });
          }
        });

        // 방 삭제
        await roomRef.remove();
        print("플레이어가 나갔으므로 방과 메시지가 삭제되었습니다.");
      }
    } catch (e) {
      print("방을 떠나는 중 오류 발생: $e");
    }
  }

  // 점수 업데이트 메서드
  void updateScore(bool isCorrect, bool isPlayer) {
    if (isCorrect) {
      if (isPlayer) {
        playerScore += 10; // 플레이어가 정답인 경우
      } else {
        opponentScore += 10; // 상대방이 정답인 경우
      }
    }
    print("내 점수33: ${playerScore}, 상대 점수33: ${opponentScore}");

  }

  void moveToNextQuestion(String roomId) async {
    if (isMovingToNextQuestion) return; // 이미 이동 중이면 무시
    isMovingToNextQuestion = true;

    final currentIndexSnapshot = await roomsRef.child(roomId).child('currentQuestionIndex').once();
    int currentIndex = (currentIndexSnapshot.snapshot.value ?? 0) as int;

    if (currentIndex < questions.length - 1) {
      currentIndex++; // 인덱스 증가
      await roomsRef.child(roomId).child('currentQuestionIndex').set(currentIndex);
      notifyPlayersNewQuestion(roomId);
    } else {
      endQuiz(roomId); // 더 이상 질문이 없으면 퀴즈 종료
    }

    isMovingToNextQuestion = false; // 이동 완료
  }

  void startOpponentCheck(String roomId) {
    _opponentCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      final opponentRef = roomsRef.child(roomId).child('players').child(opponentId!);
      final snapshot = await opponentRef.once();

      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<Object?, Object?>;
        final lastSeen = (data['lastSeen'] ?? 0) as int;
        final currentTime = DateTime.now().millisecondsSinceEpoch;

        // lastSeen이 5초 이상 업데이트되지 않았다면 상대가 나간 것으로 처리
        if (currentTime - lastSeen > 5000) {
          print("상대방이 나간 것으로 간주합니다.");
          // 상대방이 나간 경우에만 방 삭제 로직을 호출
          if (!isGameFinished) {
            notifyOpponentPlayerLeft(roomId, opponentId!); // 메시지 전송
            await leaveRoom(roomId, opponentId!); // 방 삭제
          }
        }
      }
    });
  }





  // 상대방에게 플레이어 나갔다는 알림 전송
  void notifyOpponentPlayerLeft(String roomId, String playerId) {
    roomsRef.child(roomId).child('messages').push().set({
      'type': 'player_left',
      'playerId': playerId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }


  Future<void> updateScoreInDatabase(String roomId, String playerId, int scoreChange) async {
    final playerRef = _roomsRef.child(roomId).child('players').child(playerId);

    final snapshot = await playerRef.once();
    if (snapshot.snapshot.exists) {
      final currentScoreMap = snapshot.snapshot.value as Map<Object?, Object?>;
      final currentScore = (currentScoreMap['score'] ?? 0) as int;
      final newScore = currentScore + scoreChange;

      await playerRef.update({
        'score': newScore,
        'lastSeen': DateTime.now().millisecondsSinceEpoch, // 점수 업데이트 시 lastSeen도 업데이트
      });

      // 콜백 호출하여 UI 업데이트
      if (onScoreUpdated != null) {
        onScoreUpdated!();
      }
    }
  }


  List<Question> _getQuestionsFromSharedData(Map<String, dynamic> data) {
    return data.entries.map((entry) {
      if (entry.value is Map<Object?, Object?>) {
        return Question.fromMap(Map<String, dynamic>.from(entry.value));
      } else {
        throw Exception("질문 데이터 형식이 잘못되었습니다: ${entry.value}");
      }
    }).toList();
  }

  void updateMatchStatus(String message) {
    matchStatus = message;
    isLoading = false;
  }

  Future<Map<String, dynamic>> getRoomData(String roomId) async {
    final roomSnapshot = await _roomsRef.child(roomId).once();

    if (roomSnapshot.snapshot.value != null) {
      final data = roomSnapshot.snapshot.value;

      if (data is Map<Object?, Object?>) {
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception("방 데이터 형식이 잘못되었습니다: $data");
      }
    } else {
      throw Exception("방이 존재하지 않습니다.");
    }
  }

  Future<void> submitAnswer(String roomId, String playerId, String answer) async {
    if (playerAnswer == null || playerAnswer!.isEmpty) return;

    final isCorrect = questions[currentQuestionIndex].word.trim().toLowerCase() == answer.trim().toLowerCase();

    if (isCorrect) {
      await updateScoreInDatabase(roomId, playerId, 10); // 점수 업데이트
      matchStatus = "정답입니다!";
      notifyPlayersCorrectAnswers(roomId, playerId);
    } else {
      matchStatus = "틀렸습니다. 다시 시도해보세요!";
    }

    playerAnswer = null; // 답변 초기화
  }

  Future<void> handleOpponentAnswer(String roomId, String opponentId, String answer) async {
    final isCorrect = questions[currentQuestionIndex].word.trim().toLowerCase() == answer.trim().toLowerCase();

    if (isCorrect) {
      await updateScoreInDatabase(roomId, opponentId, 10); // 상대방 점수 증가
      print("상대 점수 업데이트 호출됨: $opponentId"); // 로그 추가
      matchStatus = "$opponentId가 정답을 맞췄습니다!";
      moveToNextQuestion(roomId); // 다음 문제로 이동
    }
  }

  // 플레이어에게 새로운 문제 알리기
  void notifyPlayersNewQuestion(String roomId) {
    final question = questions[currentQuestionIndex];
    roomsRef.child(roomId).child('currentQuestion').set({
      'question': question.def,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 정답 알리기 및 다음 문제로 이동
  void notifyPlayersCorrectAnswers(String roomId, String playerId) {
    roomsRef.child(roomId).child('answers').set({
      'correctAnswer': questions[currentQuestionIndex].word,
      'correctPlayerId': playerId, // 정답을 맞춘 플레이어 ID 저장
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    moveToNextQuestion(roomId); // 다음 문제로 이동
  }

  // 퀴즈 종료 처리
  void endQuiz(String roomId) {
    isGameFinished = true;
    roomsRef.child(roomId).child('gameStatus').set({
      'finished': true,
      'finalScores': {
        'playerScore': playerScore,
        'opponentScore': opponentScore,
      },
    });
  }

  void _setupScoreListener() {
    if (opponentId != null) {
      roomsRef.child(roomId!).child('players').child(opponentId!).onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<Object?, Object?>;
          opponentScore = (data['score'] ?? 0) as int;
          print("상대 점수 업데이트: $opponentScore");
        }
      });
    }
  }

  Future<void> updatePlayerStatus(String roomId, String playerId, String status) async {
    await _roomsRef.child(roomId).child('players').child(playerId).update({
      "status": status,
    });
  }

}
