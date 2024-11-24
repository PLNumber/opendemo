import 'package:flutter/material.dart';

/* PVP 페이지 */
class PVPPage extends StatelessWidget {
  const PVPPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PVP 창"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(50),
          color: Colors.orange[600],
          width: 300,
          height: 300,
          child: const Text(
            'PVP 매치 대기 중...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}