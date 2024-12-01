// gamefunc.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../Function/class.dart';

class GameFunctions {
  final DatabaseReference _questionsRef = FirebaseDatabase.instance.ref("shared/questions");
  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref("rooms"); // 방 정보

  List<Question> questions = [];
  int currentQuestionIndex = 0;
  String? playerAnswer;
  String matchStatus = "문제를 불러오는 중입니다...";
  bool isLoading = true;

  Future<void> loadSharedQuestions() async {
    try {
      final event = await _questionsRef.once();
      final data = event.snapshot.value;

      if (data is Map) {
        questions = _getQuestionsFromSharedData(data);
        isLoading = false;
        matchStatus = questions.isEmpty ? "출제된 문제가 없습니다." : "문제를 풀어보세요!";
      } else {
        updateMatchStatus("문제를 불러오는 중 오류 발생: 데이터 형식 오류");
      }
    } catch (e) {
      updateMatchStatus("문제를 불러오는 중 오류 발생: $e");
    }
  }

  List<Question> _getQuestionsFromSharedData(Map<Object?, Object?> data) {
    return data.entries.map((entry) {
      return Question.fromMap(Map<String, dynamic>.from(entry.value as Map<Object?, Object?>));
    }).toList();
  }


  void updateMatchStatus(String message) {
    matchStatus = message;
    isLoading = false;
  }

  void submitAnswer() {
    if (playerAnswer == null || playerAnswer!.isEmpty) return;

    final isCorrect = questions[currentQuestionIndex].word.trim().toLowerCase() == playerAnswer!.trim().toLowerCase();

    matchStatus = isCorrect ? "정답입니다!" : "틀렸습니다. 다시 시도해보세요!";

    if (isCorrect && currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      playerAnswer = null; // 답변 초기화
    } else if (isCorrect) {
      matchStatus = "모든 문제를 풀었습니다!";
    }
  }

  // 방을 떠날 때 호출되는 함수
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
