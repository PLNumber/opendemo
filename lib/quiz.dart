import 'package:flutter/material.dart';

/*퀴즈 페이지*/
class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("문제 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
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
                        context, MaterialPageRoute(builder: (context) => )
                    );
                  },
                  child: Text("퀴즈 풀기")
              )
            ],
          ),
        )
    );

  }
}

