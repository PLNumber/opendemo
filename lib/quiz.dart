import 'package:flutter/material.dart';

/*퀴즈 페이지*/
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


/*퀴즈 페이지*/
class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문제 풀기'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 1000,
          height: 1000,
          color: Colors.blue,
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


