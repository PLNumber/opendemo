import 'package:flutter/material.dart';


/*대전 페이지*/
class BattlePage extends StatelessWidget {
  const BattlePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("대전 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            child: Text('대전 광역시'),
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
