import 'package:flutter/material.dart';
import 'quiz.dart';
import 'errorNote.dart';

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


