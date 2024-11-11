import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

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
  final TextEditingController _controller = TextEditingController();
  String _definition = ''; // 단어의 뜻을 저장할 변수
  bool _isLoading = false;  // 로딩 상태 표시 변수

  // API 호출 함수
  Future<void> fetchWordDefinition(String word) async {
    final String apiKey = 'YOUR_API_KEY';  // 발급받은 API 키 입력
    final String baseUrl = 'https://krdict.korean.go.kr/api/search';

    setState(() {
      _isLoading = true; // API 요청 전에 로딩 상태를 표시
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?key=$apiKey&q=$word'),
      );

      if (response.statusCode == 200) {
        var document = XmlDocument.parse(response.body);

        // XML에서 item과 sense를 찾아서 정의 추출
        var item = document.findAllElements('item').first;
        var senses = item.findElements('sense');
        if (senses.isNotEmpty) {
          var definitions = senses.map((sense) => sense.findElements('definition').map((def) => def.text).join(', ')).join('\n');
          setState(() {
            _definition = definitions.isNotEmpty ? definitions : '정의가 없습니다.';
          });
        } else {
          setState(() {
            _definition = '해당 단어에 대한 정의를 찾을 수 없습니다.';
          });
        }
      } else {
        setState(() {
          _definition = 'API 호출 실패: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _definition = '에러 발생: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // 로딩 상태 종료
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('단어 뜻 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '단어 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  fetchWordDefinition(_controller.text);
                }
              },
              child: Text('뜻 찾기'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // 로딩 중 표시
                : Text(
              _definition,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}





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


