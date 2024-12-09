//class.dart
class Question {
  int wId; // Firestore 필드명: w_id
  bool isCorrect;
  String word;
  String def; // 'definition'을 'def'로 변경
  String hint; // 추가된 필드: 초성 힌트

  // 생성자
  Question(this.wId, this.word, this.def, this.hint, {this.isCorrect = true});

  // Firestore에 저장할 Map 변환
  Map<String, dynamic> toMap() {
    return {
      'w_id': wId,
      'isCorrect': isCorrect,
      'word': word,
      'def': def, // 'def'로 저장
      'hint': hint, // 'hint' 필드 저장
    };
  }

  // Firestore에서 가져온 데이터를 기반으로 Question 객체 생성
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      map['w_id'] is int ? map['w_id'] as int : 0, // 정수 변환, 기본값 0
      map['word'] is String ? map['word'] as String : '', // 문자열 변환, 기본값 ''
      map['def'] is String ? map['def'] as String : '정의 없음', // 문자열 변환, 기본값 '정의 없음'
      map['hint'] is String ? map['hint'] as String : '힌트 없음', // 문자열 변환, 기본값 '힌트 없음'
      isCorrect: map['isCorrect'] is bool ? map['isCorrect'] as bool : true, // 불리언 변환, 기본값 true
    );
  }
}
