import 'package:firebase_database/firebase_database.dart';
import '../../Function/class.dart';

class GameFunction {
  int playerScore = 0;
  int opponentScore = 0;
  final DatabaseReference _questionsRef = FirebaseDatabase.instance.ref("shared/questions");

  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref("rooms");
  DatabaseReference get roomsRef => _roomsRef; // 방 정보 참조를 외부에서 접근할 수 있도록 하는 getter
  DatabaseReference get questionsRef => _questionsRef; // 방 정보 참조를 외부에서 접근할 수 있도록 하는 getter

  List<Question> questions = [];
  int currentQuestionIndex = 0;
  String? playerAnswer;
  String matchStatus = "문제를 불러오는 중입니다...";
  bool isLoading = true;

  // 점수 업데이트 메서드
  void updateScore(bool isCorrect, bool isPlayer) {
    if (isCorrect) {
      if (isPlayer) {
        playerScore += 10; // 플레이어가 정답인 경우
        opponentScore -= 10; // 상대방 점수 감소
      } else {
        opponentScore += 10; // 상대방이 정답인 경우
        playerScore -= 10; // 플레이어 점수 감소
      }
    }
  }

  Future<void> loadSharedQuestions() async {
    try {
      final event = await _questionsRef.once();
      final data = event.snapshot.value;

      // 데이터가 Map 형식인지 확인
      if (data is Map<Object?, Object?>) {
        // 안전하게 변환
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
      // entry.value가 Map<String, dynamic> 형식인지 확인
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

    // roomSnapshot의 snapshot을 통해 데이터 존재 여부 확인
    if (roomSnapshot.snapshot.value != null) {
      final data = roomSnapshot.snapshot.value;

      // 데이터가 Map<Object?, Object?> 형식일 경우 안전하게 변환
      if (data is Map<Object?, Object?>) {
        return Map<String, dynamic>.from(data);
      } else {
        throw Exception("방 데이터 형식이 잘못되었습니다: $data");
      }
    } else {
      throw Exception("방이 존재하지 않습니다.");
    }
  }



  void submitAnswer(bool isPlayer) {
    if (playerAnswer == null || playerAnswer!.isEmpty) return;

    final isCorrect = questions[currentQuestionIndex].word.trim().toLowerCase() == playerAnswer!.trim().toLowerCase();

    // 점수 업데이트
    updateScore(isCorrect, isPlayer);

    // 상태 메시지 업데이트
    matchStatus = isCorrect ? "정답입니다!" : "틀렸습니다. 다시 시도해보세요!";

    // 다음 질문으로 이동
    if (isCorrect && currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      playerAnswer = null; // 답변 초기화
    } else if (isCorrect) {
      matchStatus = "모든 문제를 풀었습니다!";
    }
  }

  Future<void> addPlayerToRoom(String roomId, String playerId) async {
    await _roomsRef.child(roomId).child('players').child(playerId).set({
      "name": playerId,
      "status": "waiting", // 대기 상태
    });
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

        // 플레이어가 방에 남아있는지 체크
        final players = roomData['players'] ?? {};
        players.remove(playerId);  // 해당 플레이어를 방에서 제거

        // 방에 남은 플레이어가 없으면 방 삭제
        if (players.isEmpty) {
          await roomRef.remove();  // 방 삭제
        } else {
          // 플레이어가 남아있다면, 방 상태 업데이트
          await roomRef.update({'players': players});
        }
      }
    } catch (e) {
      print("방을 떠나는 중 오류 발생: $e");
    }
  }
}
