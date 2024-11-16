import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../Function/create_collection.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('문해력 단어 생성')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await generateAndSaveWords();
          },
          child: Text('단어 가져오기 및 저장'),
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


