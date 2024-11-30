import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class Question {
  int wId; // Firestore 필드명: w_id
  bool isCorrect;
  String word;
  String def; // 'definition'을 'def'로 변경

  Question(this.wId, this.word, this.def, {this.isCorrect = true});

  // Firestore에 저장할 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'w_id': wId,
      'isCorrect': isCorrect,
      'word': word,
      'def': def, // 'def'로 저장
    };
  }

  // Firestore에서 가져온 데이터를 기반으로 Question 객체 생성
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      map['w_id'] as int? ?? 0, // 기본값 설정
      map['word'] as String? ?? '', // 기본값 설정
      map['def'] as String? ?? '정의 없음', // 'def' 필드 사용, 기본값 추가
      isCorrect: map['isCorrect'] as bool? ?? true,
    );
  }
}

// Firestore에서 질문 데이터를 가져오는 함수
Future<List<Question>> fetchWQFromFirestore() async {
  List<Question> questions = [];
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('WQ').get();

  for (var doc in snapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    questions.add(Question.fromMap(data));
  }

  return questions;
}

// Realtime Database에 질문 데이터를 저장하는 함수
Future<void> saveQuestionsToRealtimeDatabase(List<Question> questions) async {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("questions");
  List<Future<void>> futures = [];

  for (var question in questions) {
    String questionKey = ref.push().key!;
    futures.add(ref.child(questionKey).set(question.toMap())); // Realtime Database에 저장
  }

  await Future.wait(futures);
}

Future<void> migrateQuestionsToRealtimeDatabase() async {
  try {
    List<Question> questions = await fetchWQFromFirestore(); // Firestore에서 데이터 가져오기

    for (var question in questions) {
      final DatabaseReference questionRef = FirebaseDatabase.instance.ref("questions/${question.wId}");

      // 질문이 이미 존재하는지 확인
      final existingQuestionSnapshot = await questionRef.once();

      if (existingQuestionSnapshot.snapshot.value == null) {
        // 질문이 존재하지 않을 경우에만 추가
        await questionRef.set({
          "def": question.def,
          "word": question.word,
          "isCorrect": question.isCorrect,
          "w_id": question.wId,
        });
      } else {
        print("질문 '${question.def}'는 이미 존재합니다.");
      }
    }

    print("질문이 성공적으로 Realtime Database에 저장되었습니다!");
  } catch (e) {
    print("데이터 마이그레이션 실패: $e");
  }
}
