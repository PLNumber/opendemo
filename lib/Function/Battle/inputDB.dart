import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class Question {
  int wId; // Firestore 필드명: w_id
  bool isCorrect;
  String word;
  String def;

  Question(this.wId, this.word, this.def, {this.isCorrect = true});

  // Firestore에서 가져온 데이터를 기반으로 Question 객체 생성
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      map['w_id'] as int? ?? 0, // 기본값 설정
      map['word'] as String? ?? '', // 기본값 설정
      map['def'] as String? ?? '정의 없음', // 기본값 설정
      isCorrect: map['isCorrect'] as bool? ?? true,
    );
  }

  // Firebase Realtime Database에 저장할 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'w_id': wId,
      'isCorrect': isCorrect,
      'word': word,
      'def': def,
    };
  }
}

Future<void> migrateFirestoreToRealtime() async {
  final firestore = FirebaseFirestore.instance;
  final realtimeDb = FirebaseDatabase.instance.ref();

  try {
    // Firestore에서 질문 데이터 가져오기
    final firestoreSnapshot = await firestore.collection('questions').get();

    // Realtime Database에 데이터 쓰기
    for (var doc in firestoreSnapshot.docs) {
      final question = Question.fromMap(doc.data());

      // Realtime Database의 경로에 쓰기
      await realtimeDb.child('questions/${question.wId}').set(question.toMap());
    }

    print('Migration completed successfully!');
  } catch (e) {
    print('Error during migration: $e');
  }
}
