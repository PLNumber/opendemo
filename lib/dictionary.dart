import 'package:flutter/material.dart';

/*사전 페이지*/
class DictPage extends StatelessWidget {
  const DictPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("사전 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: Text('사전 어쩌구'),
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

