import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(//로그아웃하는거
        actions: [
          IconButton(
              onPressed: signUserOut,
              icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        //child: Text('메인홈페이지로 연결'),
        child: Text(
            user.email!,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
