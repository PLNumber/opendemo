import 'package:flutter/material.dart';
import 'api.dart';

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
  _QuizPage createState() => _QuizPage();
}

class _QuizPage extends State<QuizPage> {
  final _dictionaryService = KoreanDictionaryService();
  final _openAIService = OpenAIService();
  final TextEditingController _controller = TextEditingController();
  String _quizQuestion = '';

  Future<void> _createQuiz() async {
    final word = _controller.text;
    try {
      final wordInfo = await _dictionaryService.searchWord(word);
      final definition = wordInfo['some_definition_key'];

      final quiz = await _openAIService.generateQuestion(word, definition);
      setState(() {
        _quizQuestion = quiz;
      });
    } catch(e) {
      setState(() {
        _quizQuestion = '문제 생성 오류 : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('국어 문제 생성기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: '단어를 입력하세요'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createQuiz,
              child: Text('문제 생성'),
            ),
            SizedBox(height: 16),
            Text(_quizQuestion),
          ],
        ),
      ),
    );
  }
}

// /*퀴즈 페이지*/
// class QuizPage extends StatelessWidget {
//   const QuizPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('문제 풀기'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Container(
//           width: 1000,
//           height: 1000,
//           color: Colors.blue,
//         ),
//       ),
//     );
//   }
// }
//

/*오답노트 페이지*/
class NotePage extends StatelessWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오답노트'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("예시1"),
            onTap: (){},
          ),
          ListTile(
            title: Text("예시2"),
            onTap: (){},
          ),
          ListTile(
            title: Text("예시3"),
            onTap: (){},
          ),
          ListTile(
            title: Text("예시4"),
            onTap: (){},
          ),
        ],
      ),
    );
  }
}


