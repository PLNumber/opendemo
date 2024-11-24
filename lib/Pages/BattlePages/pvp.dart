// pvp.dart
import 'package:flutter/material.dart';
import '../../Function/Battle/fight.dart'; // fight.dart에서 기능을 가져옵니다.
import '../../Function/api.dart'; // API 관련 클래스를 가져옵니다.
import '../../Function/class.dart'; // Question 클래스를 가져옵니다.

class PVPPage extends StatefulWidget {
  @override
  _PVPPageState createState() => _PVPPageState();
}

class _PVPPageState extends State<PVPPage> {
  int player1Score = 0;
  int player2Score = 0;
  List<Question> questions = []; // Question 객체 리스트

  @override
  void initState() {
    super.initState();
    _loadQuestions(); // 질문 로드
  }

  Future<void> _loadQuestions() async {
    try {
      // OpenAI API로부터 단어 리스트 가져오기
      List<String> words = await fetchWordList();
      List<Question> loadedQuestions = [];

      // 각 단어에 대해 정의를 가져오기
      final api = KoreanDictionaryAPI();
      for (var word in words) {
        String definition = await api.search(word);
        // Question 객체 생성
        loadedQuestions.add(Question(0, word, definition)); // wId는 0으로 설정 (나중에 수정 가능)
      }

      setState(() {
        questions = loadedQuestions; // Question 리스트 업데이트
      });
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  void _startFight() {
    startFight(context, questions, (score1, score2) {
      setState(() {
        player1Score = score1;
        player2Score = score2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PVP 문해력 퀴즈')),
      body: questions.isEmpty // 질문이 로드되기 전
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('플레이어 1 점수: $player1Score'),
          Text('플레이어 2 점수: $player2Score'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startFight,
            child: Text('게임 시작'),
          ),
        ],
      ),
    );
  }
}
