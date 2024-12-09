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
  List<int> _selectedIds = []; // 선택된 문제 ID를 저장할 리스트

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

      final wrongAnswerIds = List<int>.from(userDoc.data()?['wrongAnswerIds'] ?? []);

      if (wrongAnswerIds.isNotEmpty) {
        // WQ 컬렉션에서 문제 가져오기
        final wqSnapshot = await FirebaseFirestore.instance
            .collection('WQ')
            .where('w_id', whereIn: wrongAnswerIds)
            .get();

        // CQ 컬렉션에서 문제 가져오기
        final cqSnapshot = await FirebaseFirestore.instance
            .collection('CQ')
            .where('w_id', whereIn: wrongAnswerIds)
            .get();

        // 두 컬렉션에서 가져온 문제를 합칩니다.
        final uniqueAnswers = <Map<String, dynamic>>{};

        // WQ에서 가져온 문제 추가
        for (var doc in wqSnapshot.docs) {
          uniqueAnswers.add({
            'w_id': doc['w_id'],
            'def': doc['def'],
            'word': doc['word'],
            'source': 'WQ', // 출처 추가
          });
        }

        // CQ에서 가져온 문제 추가
        for (var doc in cqSnapshot.docs) {
          uniqueAnswers.add({
            'w_id': doc['w_id'],
            'def': doc['def'],
            'word': doc['word'],
            'source': 'CQ', // 출처 추가
          });
        }

        // 오답 노트에 추가할 때, 중복 문제를 제거합니다.
        setState(() {
          _wrongAnswers = uniqueAnswers.where((answer) {
            return wrongAnswerIds.contains(answer['w_id']);
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

  Future<void> _removeSelectedAnswers() async {
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

        // 선택된 문제 IDs를 제거
        for (var id in _selectedIds) {
          wrongAnswerIds.remove(id);
        }

        transaction.update(userDocRef, {'wrongAnswerIds': wrongAnswerIds});
      });

      // 로컬 상태 업데이트
      setState(() {
        _wrongAnswers.removeWhere((item) => _selectedIds.contains(item['w_id']));
        _selectedIds.clear(); // 선택된 ID 초기화
      });

      print('선택된 문제들이 성공적으로 삭제되었습니다.');
    } catch (e) {
      print('오답 삭제 중 오류 발생: $e');
    }
  }

  Future<void> _removeAllWrongAnswers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("사용자가 로그인되어 있지 않습니다.");
      }

      final uid = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('UserData').doc(uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);
        if (!snapshot.exists) {
          throw Exception("사용자 데이터가 존재하지 않습니다.");
        }

        transaction.update(userDocRef, {'wrongAnswerIds': []}); // 모든 오답 삭제
      });

      // 로컬 상태 업데이트
      setState(() {
        _wrongAnswers.clear(); // 로컬 리스트 비우기
      });

      print('모든 오답이 성공적으로 삭제되었습니다.');
    } catch (e) {
      print('모든 오답 삭제 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('오답 노트'), backgroundColor: Colors.teal, centerTitle: true), // 앱바 색상 변경 및 텍스트 가운데 정렬
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_wrongAnswers.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('오답 노트'), backgroundColor: Colors.teal, centerTitle: true), // 앱바 색상 변경 및 텍스트 가운데 정렬
        body: Center(
          child: Text('저장된 오답이 없습니다.', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('오답 노트'),
        backgroundColor: Colors.teal, // 앱바 색상 변경
        centerTitle: true, // 텍스트 가운데 정렬
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep), // 전체 삭제 아이콘
            onPressed: () {
              _removeAllWrongAnswers();
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              if (_selectedIds.isNotEmpty) {
                _removeSelectedAnswers();
              }
            },
          ),
        ],
      ),
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
              trailing: Checkbox(
                value: _selectedIds.contains(wrongAnswer['w_id']),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds.add(wrongAnswer['w_id']);
                    } else {
                      _selectedIds.remove(wrongAnswer['w_id']);
                    }
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
