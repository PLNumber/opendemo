import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Function/class.dart';

// gameFunc.dart
class GameFunction {
  String? roomId;

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
  String? playerName; // 플레이어 이름 추가
  String? profileImg; // 프로필 이미지 추가
  Function? onScoreUpdated;

  // 생성자
  GameFunction({this.onScoreUpdated});



  // 사용자 데이터 로드 메서드
  Future<void> loadUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("로그인된 사용자가 없습니다.");
      }

      myPlayerId = currentUser.uid; // 사용자 ID 설정

      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(myPlayerId) // UID로 Firestore에서 사용자 데이터 가져오기
          .get();

      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        playerName = data['name'] ?? "Player";
        profileImg = data['profileImg'] ?? "https://via.placeholder.com/150";
      } else {
        throw Exception("사용자 데이터를 찾을 수 없습니다.");
      }
    } catch (e) {
      print("사용자 데이터 로드 오류: $e");
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
    print("내 점수: $playerScore, 상대 점수: $opponentScore");
  }

  Future<void> updateScoreInDatabase(String roomId, String playerId, int scoreChange) async {
    final playerRef = _roomsRef.child(roomId).child('players').child(playerId);

    final snapshot = await playerRef.once();
    if (snapshot.snapshot.exists) {
      final currentScoreMap = snapshot.snapshot.value as Map<Object?, Object?>;
      final currentScore = (currentScoreMap['score'] ?? 0) as int;
      final newScore = currentScore + scoreChange;

      await playerRef.update({'score': newScore});

      // 콜백 호출하여 UI 업데이트
      if (onScoreUpdated != null) {
        onScoreUpdated!();
      }
    }
  }

  Future<void> loadSharedQuestions(String roomId) async {
    try {
      final event = await _questionsRef.once();
      final data = event.snapshot.value;

      if (data is Map<Object?, Object?>) {
        final questionsData = Map<String, dynamic>.from(data);
        List<Question> allQuestions = _getQuestionsFromSharedData(questionsData);

        // 5개만 가져오기
        questions = allQuestions.length >= 5
            ? allQuestions.sublist(0, 5) // 상위 5개 질문을 가져오기
            : allQuestions; // 5개 미만이면 모두 사용

        // 방에 질문 저장
        await _roomsRef.child(roomId).child('questions').set(questions.map((q) => q.toMap()).toList());

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

    if (isCorrect) {
      await updateScoreInDatabase(roomId, playerId, 10); // 점수 업데이트
      matchStatus = "정답입니다!";
      notifyPlayersCorrectAnswers(roomId, playerId);
    } else {
      matchStatus = "틀렸습니다. 다시 시도해보세요!";
    }

    playerAnswer = null; // 답변 초기화

    // 다음 문제로 이동
    await moveToNextQuestion(roomId);
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

  bool isMovingToNextQuestion = false;

  Future<void> moveToNextQuestion(String roomId) async {
    if (currentQuestionIndex >= questions.length - 1) {
      // 모든 문제를 풀었으면 퀴즈 종료
      endQuiz(roomId);
      return;
    }

    currentQuestionIndex++; // 인덱스 증가

    // 방의 현재 질문 인덱스 업데이트
    await roomsRef.child(roomId).child('currentQuestionIndex').set(currentQuestionIndex);
    notifyPlayersNewQuestion(roomId);
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
  void endQuiz(String roomId) async {
    isGameFinished = true;
    roomsRef.child(roomId).child('gameStatus').set({
      'finished': true,
      'finalScores': {
        'playerScore': playerScore,
        'opponentScore': opponentScore,
      },
    });

    // 퀴즈 종료 알림
    notifyPlayersQuizFinished(roomId);

    // 방을 나가는 로직 추가
    await leaveRoom(roomId, myPlayerId!); // 현재 플레이어 ID로 방을 나감
  }


  // 퀴즈 종료 알림을 위한 메서드
  void notifyPlayersQuizFinished(String roomId) {
    roomsRef.child(roomId).child('quizFinished').set({
      'message': '퀴즈가 종료되었습니다!',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> addPlayerToRoom(String roomId, String playerId) async {
    this.roomId = roomId; // 방 ID 설정
    myPlayerId = playerId; // 내 플레이어 ID 설정

    // 방에 플레이어 추가
    await _roomsRef.child(roomId).child('players').child(playerId).set({
      "name": playerId,
      "status": "waiting",
      "score": 0,
      "lastActive": DateTime.now().millisecondsSinceEpoch,
    });

    // 방의 질문 로드
    final questionsSnapshot = await _roomsRef.child(roomId).child('questions').once();
    if (questionsSnapshot.snapshot.exists) {
      final questionsList = questionsSnapshot.snapshot.value as List;
      questions = questionsList.map((q) => Question.fromMap(Map<String, dynamic>.from(q))).toList();
    } else {
      // 질문이 없으면 새로 로드
      await loadSharedQuestions(roomId);
    }

    final playersSnapshot = await _roomsRef.child(roomId).child('players').once();
    if (playersSnapshot.snapshot.exists) {
      final players = playersSnapshot.snapshot.value as Map;
      if (players.length > 1) {
        opponentId = players.keys.firstWhere((id) => id != playerId);
        _setupScoreListener(); // 리스너 설정
      }
    }
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

  // 플레이어의 마지막 활동 시간 업데이트 메서드
  Future<void> updateLastActive(String roomId, String playerId) async {
    await _roomsRef.child(roomId).child('players').child(playerId).update({
      'lastActive': DateTime.now().millisecondsSinceEpoch, // 현재 시간을 타임스탬프로 업데이트
    });
  }

  Future<void> leaveRoom(String roomId, String playerId) async {
    try {
      final roomRef = roomsRef.child(roomId);
      final roomSnapshot = await roomRef.get();

      if (roomSnapshot.exists) {
        // 플레이어를 방에서 제거
        await roomRef.child('players').child(playerId).remove();

        // 메시지 삭제
        await roomRef.child('messages').remove();

        // 방이 비어있으면 방 삭제
        final playersSnapshot = await roomRef.child('players').once();
        if (playersSnapshot.snapshot.value == null ||
            (playersSnapshot.snapshot.value as Map).isEmpty) {
          await roomRef.remove();
          print("방이 비어있어 삭제되었습니다.");
        } else {
          print("플레이어가 남아있어 방은 유지됩니다.");
        }
      }
    } catch (e) {
      print("방을 떠나는 중 오류 발생: $e");
    }
  }
}