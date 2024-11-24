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
