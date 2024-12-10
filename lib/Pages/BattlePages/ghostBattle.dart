import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Function/class.dart';

class PvpGhostPage extends StatefulWidget {
  @override
  _PvpGhostPageState createState() => _PvpGhostPageState();
}

class _PvpGhostPageState extends State<PvpGhostPage> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _opponentCorrectAnswers = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _isLoading = true;
  bool _showOverlay = true; // 대기 화면 상태
  List<int> _opponentTimeRecords = [];
  late int _startTime;
  String? _userName;
  String? _userProfileImg;
  String? _opponentName;
  String? _opponentProfileImg;

  @override
  void initState() {
    super.initState();
    _applyPenalty();
    _fetchQuestionsAndOpponentData();
  }

  Future<void> _applyPenalty() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("사용자가 로그인되어 있지 않습니다.");
      final uid = user.uid;

      final userDoc =
      FirebaseFirestore.instance.collection('UserData').doc(uid);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          int rankPt = data['rankPt'] ?? 0;
          int loss = data['loss'] ?? 0;
          _userName = data['name'];
          _userProfileImg = data['profileImg'];
          transaction.update(userDoc, {'rankPt': rankPt - 5});
          transaction.update(userDoc, {'loss': loss + 1});
        }
      });
    } catch (e) {
      print('패널티 적용 중 오류 발생: $e');
    }
  }

  Future<void> _fetchQuestionsAndOpponentData() async {
    try {
      final questionsSnapshot =
      await FirebaseFirestore.instance.collection('WQ').get();
      final questions = questionsSnapshot.docs
          .map((doc) => Question.fromMap(doc.data()))
          .toList();
      questions.shuffle();

      final opponentSnapshot = await FirebaseFirestore.instance
          .collection('pvpGhost')
          .orderBy('completedAt', descending: true)
          .limit(10)
          .get();

      if (opponentSnapshot.docs.isEmpty) {
        throw Exception('상대 데이터가 없습니다.');
      }

      final opponentDocs = opponentSnapshot.docs.toList();
      opponentDocs.shuffle();
      final opponentData = opponentDocs.first.data();

      final opponentTimeRecords =
      List<int>.from(opponentData['timeRecords'] ?? []);
      _opponentName = opponentData['userName'];
      _opponentProfileImg = opponentData['profileImage'];

      setState(() {
        _questions = questions;
        _opponentTimeRecords = opponentTimeRecords;
        _isLoading = false;
        _startTime = DateTime.now().millisecondsSinceEpoch;
      });
    } catch (e) {
      print('데이터 로드 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('데이터를 불러오는 데 실패했습니다. 다시 시도해주세요.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startGame() {
    setState(() {
      _showOverlay = false;
      _simulateOpponent();
    });
  }

  void _simulateOpponent() async {
    for (int i = 0; i < _opponentTimeRecords.length; i++) {
      await Future.delayed(Duration(seconds: _opponentTimeRecords[i]));

      if (_opponentCorrectAnswers < 10) {
        setState(() {
          _opponentCorrectAnswers++;
        });

        if (_opponentCorrectAnswers >= 10) {
          _finishGame(false);
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text('PvP 대결'),
            backgroundColor: Colors.teal),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text('PvP 대결'),
          backgroundColor: Colors.teal),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildProfileSection(_userName, _userProfileImg),
                      _buildProfileSection(_opponentName, _opponentProfileImg),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHealthBar(
                        label: '나',
                        current: _correctAnswers,
                        total: 10,
                        color: Colors.green,
                      ),
                      SizedBox(height: 8),
                      _buildHealthBar(
                        label: '상대',
                        current: _opponentCorrectAnswers,
                        total: 10,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: isDarkMode ? Colors.black : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "문제: ${_questions[_currentQuestionIndex].def}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          labelText: '정답을 입력하세요',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        onSubmitted: (value) {
                          _checkAnswer(); // 휴대폰 완료 버튼을 눌렀을 때 정답 체크
                        },
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _skipQuestion,
                            child: Text('문제 넘기기',
                                style: TextStyle(color: Colors.black)),
                          ),
                          SizedBox(width: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _checkAnswer,
                            child: Text('제출',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showOverlay)
            GestureDetector(
              onTap: _startGame,
              child: Container(
                color: isDarkMode ? Colors.black : Colors.white, // 반투명 배경
                height: MediaQuery.of(context).size.height, // 전체 화면 높이
                width: MediaQuery.of(context).size.width, // 전체 화면 너비
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_opponentProfileImg != null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(_opponentProfileImg!),
                        ),
                      SizedBox(height: 16),
                      Text(
                        '${_opponentName ?? "상대"}와 대결!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black, // 글씨 색상
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '터치하면 시작합니다.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[300], // 텍스트 색상
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthBar({
    required String label,
    required int current,
    required int total,
    required Color color,
  }) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 18)),
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: current / total,
            backgroundColor: Colors.grey[300],
            color: color,
            minHeight: 20,
          ),
        ),
        SizedBox(width: 8),
        Text('$current / $total', style: TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildProfileSection(String? name, String? profileImg) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: profileImg != null ? NetworkImage(profileImg) : null,
          child: profileImg == null ? Icon(Icons.person, size: 30) : null,
        ),
        SizedBox(height: 8),
        Text(name ?? '알 수 없음', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  void _checkAnswer() {
    String userAnswer = _answerController.text.trim();
    setState(() {
      if (userAnswer.toLowerCase() ==
          _questions[_currentQuestionIndex].word.toLowerCase()) {
        _correctAnswers++;
        if (_correctAnswers >= 10) {
          _finishGame(true);
        } else {
          _moveToNextQuestion();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('틀렸습니다. 다시 시도하세요!')),
        );
      }
      _answerController.clear();
    });
  }

  void _skipQuestion() {
    _moveToNextQuestion();
  }

  void _moveToNextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _finishGame(false);
      }
    });
  }

  void _finishGame(bool playerWon) async {
    if (playerWon) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception("사용자가 로그인되어 있지 않습니다.");
        final uid = user.uid;

        final userDoc =
        FirebaseFirestore.instance.collection('UserData').doc(uid);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(userDoc);
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            int rankPt = data['rankPt'] ?? 0;
            int shopPt = data['shopPt'] ?? 0;
            int loss = data['loss'] ?? 0;
            int win = data['win'] ?? 0;
            transaction.update(userDoc, {'rankPt': rankPt + 15});
            transaction.update(userDoc, {'shopPt': shopPt + 300});
            transaction.update(userDoc, {'loss': loss - 1});
            transaction.update(userDoc, {'win': win + 1});
          }
        });
      } catch (e) {
        print('점수 업데이트 중 오류 발생: $e');
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(playerWon ? '승리!' : '패배'),
          content: Text(playerWon
              ? '축하합니다! 상대를 이겼습니다.\n10 랭크포인트 획득!\n300 상점 포인트 획득!'
              : '안타깝게도 상대에게 졌습니다.\n5 랭크포인트 감소...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('메인으로', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }
}

