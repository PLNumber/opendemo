import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Function/class.dart';

/*퀴즈 메인 페이지*/
class QuizMainPage extends StatelessWidget {
  const QuizMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("문제 메인창"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(175,175),
                    backgroundColor: Colors.greenAccent,
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)
                    )
                ),
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => QuizPage())
                  );
                },
                child: Text("퀴즈 풀기")
            ),
            SizedBox(height: 50,),

            /*오답노트*/
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(175,175),
                    backgroundColor: Colors.greenAccent,
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)
                    )
                ),
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => NotePage())
                  );
                },
                child: Text("오답 노트")
            )
          ],
        ),
      )
    );

  }
}


class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions(); // Firestore 데이터 가져오기
  }

  Future<void> _fetchQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('WQ').get();
      final questions = snapshot.docs
          .map((doc) => Question.fromMap(doc.data())) // 데이터 모델에 맞게 변환
          .toList();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching questions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('문제를 불러오는 데 실패했습니다. 다시 시도해주세요.')),
      );
      setState(() {
        _isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 풀기')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('퀴즈 풀기')),
        body: Center(child: Text('퀴즈 데이터가 없습니다.')),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('퀴즈 풀기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "문제: ${currentQuestion.def}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                labelText: '정답을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _checkAnswer(currentQuestion),
              child: Text('제출'),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswer(Question question) {
    String userAnswer = _answerController.text.trim();

    setState(() {
      if (userAnswer.toLowerCase() == question.word.toLowerCase()) {
        _showResultDialog(true);
      } else {
        question.isCorrect = false;
        _saveWrongAnswer(question); // 오답 저장
        _showResultDialog(false);
      }
      _answerController.clear();
    });
  }

  void _saveWrongAnswer(Question question) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('wrongAnswers').doc();
      await docRef.set(question.toMap()); // Firestore에 데이터를 저장
      print('Wrong answer saved.');
    } catch (e) {
      print('Error saving wrong answer: $e');
    }
  }


  void _showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCorrect ? '정답입니다!' : '오답입니다.'),
          content: Text(
            isCorrect
                ? '잘했습니다! 다음 문제로 넘어갑니다.'
                : '정답은 "${_questions[_currentQuestionIndex].word}"입니다.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _moveToNextQuestion();
              },
              child: Text('다음'),
            ),
          ],
        );
      },
    );
  }

  void _moveToNextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('퀴즈 완료'),
          content: Text('모든 문제를 푸셨습니다!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('메인으로'),
            ),
          ],
        );
      },
    );
  }
}



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
