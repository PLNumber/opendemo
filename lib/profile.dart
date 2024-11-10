import 'package:flutter/material.dart';

/*프로필 페이지*/
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("프로필 창"),
          centerTitle: true,
        ),
        body: Center(
          child: Container(
            //child: Image.asset();
            child: Text("대충 축 신 두"),

          ),
        )
    );

  }
}

