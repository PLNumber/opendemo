import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'api.dart';

// Firestore에 데이터를 저장하는 함수
Future<void> saveToFirestore(String word, String definition) async {
  final firestore = FirebaseFirestore.instance;

  await firestore.collection('word_definitions').add({
    'word': word,
    'definition': definition,
    'iscorrect': false, // 초기값 설정
    'w_id': DateTime.now().millisecondsSinceEpoch, // 고유 ID 생성
  });
}

// 단어 리스트 가져오기 및 Firestore 저장 함수
Future<void> generateAndSaveWords() async {
  try {
    // 1. OpenAI API로 단어 리스트 가져오기
    final words = await fetchWordList();
    debugPrint('단어 리스트: $words');

    // 2. 단어 정의 가져오기 및 Firestore 저장 (병렬 처리)
    final dictionaryAPI = KoreanDictionaryAPI();

    List<Future<void>> saveFutures = [];

    for (String word in words) {
      saveFutures.add(
          dictionaryAPI.search(word).then((definition) async {
            debugPrint('$word: $definition');

            // Firestore에 저장
            await saveToFirestore(word, definition);
          }).catchError((e) {
            debugPrint('단어 $word 처리 중 오류: $e');
          })
      );
    }

    // 병렬로 처리 후 모두 완료될 때까지 기다림
    await Future.wait(saveFutures);

    debugPrint("모든 단어가 Firestore에 저장되었습니다.");
  } catch (e) {
    debugPrint('오류 발생: $e');
  }
}
