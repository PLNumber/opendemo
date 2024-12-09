import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Function/class.dart';

// gameFunc.dart
class GameFunction {
  String? roomId;

  String? myPlayerId; // 내 플레이어 ID
  String? opponentId; // 상대방 플레이어 ID

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
  bool isMovingToNextQuestion = false;

  bool isGameFinished = false; // 게임 종료 여부
  String? playerName; // 플레이어 이름 추가
  String? profileImg; // 프로필 이미지 추가
  Function? onScoreUpdated;

  // 생성자
  GameFunction({this.onScoreUpdated});

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



  /*방 시작 시*/
  Future<void> updatePlayerStatus(String roomId, String playerId, String status) async {
    await _roomsRef.child(roomId).child('players').child(playerId).update({
      "status": status,
    });
  }

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

  void updateMatchStatus(String message) {
    matchStatus = message;
    isLoading = false;
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

  Future<void> addPlayerToRoom(String roomId, String playerId) async {
    this.roomId = roomId; // 방 ID 설정
    myPlayerId = playerId; // 내 플레이어 ID 설정
    await _roomsRef.child(roomId).child('players').child(playerId).set({
      "name": playerId,
      "status": "waiting",
      "score": 0,
      "lastActive": DateTime.now().millisecondsSinceEpoch, // 타임스탬프 추가
    });

    final playersSnapshot = await _roomsRef.child(roomId).child('players').once();
    if (playersSnapshot.snapshot.exists) {
      final players = playersSnapshot.snapshot.value as Map;
      if (players.length > 1) {
        opponentId = players.keys.firstWhere((id) => id != playerId);
        _setupScoreListener(); // 리스너 설정
      }
    }
  }


  /*문제 풀시*/

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
      // 모든 질문을 다 푼 경우
      await endQuizAndUpdateScore(roomId);
    }

    isMovingToNextQuestion = false; // 이동 완료
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



/*끝날 시 , 나갈 시*/

  Future<void> endQuizAndUpdateScore(String roomId) async {
    isGameFinished = true;

    // 랭크 포인트에 최종 점수 추가
    await updateRankPoints(myPlayerId!, playerScore);

    // 방 상태 업데이트
    await roomsRef.child(roomId).child('gameStatus').set({
      'finished': true,
      'finalScores': {
        'playerScore': playerScore,
        'opponentScore': opponentScore,
      },
    });
  }

  Future<void> updateRankPoints(String playerId, int finalScore) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance.collection('UserData').doc(user.uid);
        await userDoc.update({'rankPt': FieldValue.increment(finalScore)});
        print('User points updated by $finalScore.');
      }
    } catch (e) {
      print('Error updating user points: $e');
    }
  }




/*마지막*/


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
        await roomRef.child('players').child(playerId).update({
          'status' : 'player_left',
          'lastActive' : DateTime.now().millisecondsSinceEpoch, // 현재 시간을 타임스탬프로 추가 (선택 사항)
        });

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