import 'package:flutter/material.dart';


/*옵션 페이지*/
class OptionPage extends StatelessWidget {
  const OptionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("옵션 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: Text('설정 어쩌구'),
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

