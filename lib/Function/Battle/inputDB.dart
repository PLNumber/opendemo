import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../class.dart';

Future<List<Question>> fetchWQFromFirestore() async {
  List<Question> questions = [];

  // Firestore에서 'WQ' 컬렉션의 모든 문서를 가져옴
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('WQ').get();

  for (var doc in snapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // Question 객체로 변환
    questions.add(Question.fromMap(data));
  }

  print("로드된 질문 수: ${questions.length}"); // 로드된 질문 수 출력
  return questions;
}


Future<void> saveQuestionsToRealtimeDatabase(String roomId, List<Question> questions) async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("rooms/$roomId/questions");
  List<Future<void>> futures = [];

  for (var question in questions) {
    String questionKey = ref.push().key!;
    futures.add(ref.child(questionKey).set(question.toMap())); // Realtime Database에 저장
  }

  // 모든 저장 작업이 완료될 때까지 대기
  await Future.wait(futures);
  print("질문이 방에 성공적으로 저장되었습니다: $roomId");
}

// 전체 흐름
Future<void> migrateWQToRealtimeDatabase(String roomId) async {
  try {
    List<Question> questions = await fetchWQFromFirestore(); // Firestore에서 데이터 가져오기
    if (questions.isNotEmpty) {
      await saveQuestionsToRealtimeDatabase(roomId, questions); // 방 ID 전달
      print("질문이 성공적으로 Realtime Database에 저장되었습니다!");
    } else {
      print("저장할 질문이 없습니다.");
    }
  } catch (e) {
    print("데이터 마이그레이션 실패: $e");
  }
}
