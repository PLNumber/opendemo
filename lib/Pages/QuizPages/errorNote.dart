import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotePage extends StatelessWidget {
  final Stream<QuerySnapshot> wrongAnswersStream =
  FirebaseFirestore.instance.collection('wrongAnswers').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오답노트'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: wrongAnswersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오답을 불러오는 데 오류가 발생했습니다.'));
          }
          final wrongAnswers = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: wrongAnswers.length,
            itemBuilder: (context, index) {
              final wrongAnswer = wrongAnswers[index];
              // 'def' 필드가 없을 경우 기본값 사용
              final def = wrongAnswer['def'] ?? '정의 없음';
              final word = wrongAnswer['word'] ?? '단어 없음';
              return ListTile(
                title: Text(def),  // 'def' 필드 사용
                subtitle: Text(word),  // 단어 표시
                onTap: () {
                  // 오답을 클릭했을 때 더 자세히 보기 기능 추가
                },
              );
            },
          );
        },
      ),
    );
  }
}
