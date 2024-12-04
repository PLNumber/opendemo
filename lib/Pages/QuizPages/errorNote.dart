import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Map<String, dynamic>> _wrongAnswers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWrongAnswers();
  }

  Future<void> _fetchWrongAnswers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("사용자가 로그인되어 있지 않습니다.");
      }

      final uid = user.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(uid)
          .get();

      final wrongAnswerIds =
      List<int>.from(userDoc.data()?['wrongAnswerIds'] ?? []);

      if (wrongAnswerIds.isNotEmpty) {
        final snapshot = await FirebaseFirestore.instance
            .collection('WQ')
            .where('w_id', whereIn: wrongAnswerIds)
            .get();

        setState(() {
          _wrongAnswers = snapshot.docs.map((doc) {
            return {
              'w_id': doc['w_id'],
              'def': doc['def'],
              'word': doc['word'],
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _wrongAnswers = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('오답 데이터를 불러오는 중 오류 발생: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeWrongAnswer(int wId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("사용자가 로그인되어 있지 않습니다.");
      }

      final uid = user.uid;
      final userDocRef =
      FirebaseFirestore.instance.collection('UserData').doc(uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        if (!snapshot.exists) {
          throw Exception("사용자 데이터가 존재하지 않습니다.");
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final wrongAnswerIds = List<int>.from(data['wrongAnswerIds'] ?? []);

        // 해당 wId를 리스트에서 제거
        wrongAnswerIds.remove(wId);

        transaction.update(userDocRef, {'wrongAnswerIds': wrongAnswerIds});
      });

      // 로컬 상태 업데이트
      setState(() {
        _wrongAnswers.removeWhere((item) => item['w_id'] == wId);
      });

      print('문제 ID $wId가 성공적으로 삭제되었습니다.');
    } catch (e) {
      print('오답 삭제 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('오답 노트')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_wrongAnswers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('오답 노트')),
        body: Center(
          child: Text('저장된 오답이 없습니다.', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('오답 노트')),
      body: ListView.builder(
        itemCount: _wrongAnswers.length,
        itemBuilder: (context, index) {
          final wrongAnswer = _wrongAnswers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                '문제: ${wrongAnswer['def']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('정답: ${wrongAnswer['word']}',
                  style: TextStyle(fontSize: 14, color: Colors.teal)),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeWrongAnswer(wrongAnswer['w_id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
