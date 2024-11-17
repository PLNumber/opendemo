import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  int wordId;
  bool isCorrect;
  String word;
  String definition;

  Question(this.wordId, this.word, this.definition, {this.isCorrect = true});

  // 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'wordId': wordId,
      'isCorrect': isCorrect,
      'word': word,
      'definition': definition,
    };
  }

  // Firestore에서 가져온 Map을 객체로 변환
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      map['wordId'] as int,
      map['word'] as String,
      map['definition'] as String,
      isCorrect: map['isCorrect'] as bool? ?? true,
    );
  }
}
