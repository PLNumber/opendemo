//imputDB.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../class.dart';

Future<List<Question>> fetchWQFromFirestore() async {
  List<Question> questions = [];

  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('WQ').get();

    for (var doc in snapshot.docs) {
      try {
        // Firebase에서 가져온 데이터를 Map<String, dynamic>으로 안전하게 변환
        Map<String, dynamic> data = Map<String, dynamic>.from(doc.data() as Map<Object?, Object?>);
        questions.add(Question.fromMap(data.cast<String, dynamic>()));
      } catch (e) {
        print("문서를 변환하는 중 오류 발생 (ID: ${doc.id}): $e");
      }
    }
  } catch (e) {
    print("Firestore에서 데이터를 가져오는 중 오류 발생: $e");
  }

  print("로드된 질문 수: ${questions.length}");
  return questions;
}



Future<void> saveQuestionsToSharedDatabase(List<Question> questions) async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("shared/questions");
  List<Future<void>> futures = [];

  for (var question in questions) {
    try {
      String questionKey = ref.push().key!;
      print("Saving question with key: $questionKey");  // 디버그용 출력
      futures.add(ref.child(questionKey).set(question.toMap()));
    } catch (e) {
      print("질문 저장 실패 (질문 내용: ${question.toMap()}): $e");
    }
  }

  try {
    await Future.wait(futures);
    print("질문 데이터가 성공적으로 저장되었습니다.");
  } catch (e) {
    print("일부 질문 저장 실패: $e");
  }
}

Future<bool> isMigrationCompleted() async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("shared/migrationCompleted");
  final snapshot = await ref.get();

  return snapshot.exists && snapshot.value == true;
}

Future<void> migrateWQToSharedDatabase() async {
  try {
    // 마이그레이션이 이미 완료되었으면 실행하지 않음
    bool migrationCompleted = await isMigrationCompleted();
    if (migrationCompleted) {
      print("마이그레이션이 이미 완료되었습니다.");
      return;
    }

    // Firestore에서 질문 데이터를 가져와 Realtime Database로 마이그레이션
    List<Question> questions = await fetchWQFromFirestore();
    if (questions.isEmpty) {
      print("질문 데이터가 없습니다.");
      return;
    }

    await saveQuestionsToSharedDatabase(questions);
    print("질문 데이터가 성공적으로 마이그레이션되었습니다.");

    // 마이그레이션 완료 플래그를 Realtime Database에 설정
    final DatabaseReference ref = FirebaseDatabase.instance.ref("shared/migrationCompleted");
    await ref.set(true); // 마이그레이션 완료 플래그 저장

  } catch (e) {
    print("마이그레이션 중 오류 발생: $e");
  }
}