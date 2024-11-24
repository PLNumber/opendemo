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
              final def = wrongAnswer['def'] ?? '정의 없음';
              final word = wrongAnswer['word'] ?? '단어 없음';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(def, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(word),
                  onTap: () {
                    // 오답을 클릭했을 때 더 자세히 보기
                    _showDetailDialog(context, word, def);
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteWrongAnswer(wrongAnswer.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetailDialog(BuildContext context, String word, String def) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('상세 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('단어: $word'),
              SizedBox(height: 10),
              Text('정의: $def'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void _deleteWrongAnswer(String id) {
    FirebaseFirestore.instance.collection('wrongAnswers').doc(id).delete().then((_) {
      print("오답 항목이 삭제되었습니다.");
    }).catchError((error) {
      print("오답 항목 삭제 실패: $error");
    });
  }
}
