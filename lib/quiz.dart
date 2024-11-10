import 'package:flutter/material.dart';

/*퀴즈 페이지*/
class QuizPage extends StatelessWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("퀴즈 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: Text('퀴즈 어쩌구'),
            alignment: Alignment.center,
            padding: EdgeInsets.all(50),
            color: Colors.orange[600],
            width: 400,
            height: 400,
          ),
        )
    );

  }
}

