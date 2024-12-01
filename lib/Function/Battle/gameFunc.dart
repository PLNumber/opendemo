import 'package:firebase_database/firebase_database.dart';
import '../../Function/class.dart';

class GameFunction {
  int playerScore = 0;
  int opponentScore = 0;
  final DatabaseReference _questionsRef = FirebaseDatabase.instance.ref("shared/questions");
  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref("rooms");

  DatabaseReference get roomsRef => _roomsRef;
  DatabaseReference get questionsRef => _questionsRef;

  List<Question> questions = [];
  int currentQuestionIndex = 0;
  String? playerAnswer;
  String matchStatus = "문제를 불러오는 중입니다...";
  bool isLoading = true;

  String? myPlayerId; // 내 플레이어 ID
  String? opponentId; // 상대방 플레이어 ID
  bool isGameFinished = false; // 게임 종료 여부

  // 점수 업데이트 메서드
  void updateScore(bool isCorrect, bool isPlayer) {
    if (isCorrect) {
      if (isPlayer) {
        playerScore += 10; // 플레이어가 정답인 경우
      } else {
        opponentScore += 10; // 상대방이 정답인 경우
      }
    }
  }

  Future<void> updateScoreInDatabase(String roomId, String playerId, int scoreChange) async {
    final playerRef = _roomsRef.child(roomId).child('players').child(playerId);

    // 현재 점수를 가져오기
    final snapshot = await playerRef.once();
    if (snapshot.snapshot.exists) {
      // 안전하게 Map<String, dynamic>으로 변환
      final currentScoreMap = snapshot.snapshot.value as Map<Object?, Object?>;
      final currentScore = (currentScoreMap['score'] ?? 0) as int; // 점수 가져오기
      final newScore = currentScore + scoreChange;

      // 점수 업데이트
      await playerRef.update({'score': newScore});
    } else {
      print("플레이어 데이터가 존재하지 않습니다."); // 디버깅을 위한 로그
    }
  }

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

    // 점수 업데이트
    if (isCorrect) {
      // 맞춘 플레이어에게 10점 추가
      await updateScoreInDatabase(roomId, playerId, 10); // 정답 시 10점 추가

      // 정답을 맞춘 경우
      matchStatus = "정답입니다!";
      notifyPlayersCorrectAnswers(roomId, playerId);
      moveToNextQuestion(roomId); // 다음 문제로 이동
    } else {
      matchStatus = "틀렸습니다. 다시 시도해보세요!";
    }

    playerAnswer = null; // 답변 초기화
  }

  Future<void> handleOpponentAnswer(String roomId, String opponentId, String answer) async {
    final isCorrect = questions[currentQuestionIndex].word.trim().toLowerCase() == answer.trim().toLowerCase();

    if (isCorrect) {
      // 상대방에게 10점 추가
      await updateScoreInDatabase(roomId, opponentId, 10); // 상대방 점수 증가

      // 정답을 맞춘 경우
      matchStatus = "$opponentId가 정답을 맞췄습니다!";
      moveToNextQuestion(roomId); // 다음 문제로 이동
    }
  }



  // 정답 알리기 및 다음 문제로 이동
  void notifyPlayersCorrectAnswers(String roomId, String playerId) {
    roomsRef.child(roomId).child('answers').set({
      'correctAnswer': questions[currentQuestionIndex].word,
      'correctPlayerId': playerId, // 정답을 맞춘 플레이어 ID 저장
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 다음 문제로 이동
  void moveToNextQuestion(String roomId) {
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      notifyPlayersNewQuestion(roomId);
    } else {
      endQuiz(roomId);
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

  Future<void> addPlayerToRoom(String roomId, String playerId) async {
    myPlayerId = playerId; // 내 플레이어 ID 설정
    await _roomsRef.child(roomId).child('players').child(playerId).set({
      "name": playerId,
      "status": "waiting", // 대기 상태
      "score": 0, // 초기 점수 설정
    });

    // 상대방 ID 설정
    final playersSnapshot = await _roomsRef.child(roomId).child('players').once();
    if (playersSnapshot.snapshot.exists) {
      final players = playersSnapshot.snapshot.value as Map;
      if (players.length > 1) {
        opponentId = players.keys.firstWhere((id) => id != playerId); // 상대방 ID 찾기
      }
    }
  }

  Future<void> updatePlayerStatus(String roomId, String playerId, String status) async {
    await _roomsRef.child(roomId).child('players').child(playerId).update({
      "status": status,
    });
  }

  Future<void> leaveRoom(String roomId, String playerId) async {
    try {
      final roomRef = _roomsRef.child(roomId);
      final roomSnapshot = await roomRef.get();

      if (roomSnapshot.exists) {
        final roomData = roomSnapshot.value as Map;

        final players = roomData['players'] ?? {};
        players.remove(playerId);  // 해당 플레이어를 방에서 제거

        if (players.isEmpty) {
          await roomRef.remove();  // 방 삭제
        } else {
          await roomRef.update({'players': players});
        }
      }
    } catch (e) {
      print("방을 떠나는 중 오류 발생: $e");
    }
  }
}
