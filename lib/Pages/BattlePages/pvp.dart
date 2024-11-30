import 'package:flutter/material.dart';

class PVPPage extends StatefulWidget {
  const PVPPage({Key? key}) : super(key: key);

  @override
  _PVPPageState createState() => _PVPPageState();
}

class _PVPPageState extends State<PVPPage> {
  String playerName = "";
  String matchStatus = "매치 대기 중...";
  bool isSearching = false;

  void startMatch() {
    setState(() {
      isSearching = true;
      matchStatus = "플레이어 찾는 중...";
    });

    // 2초 뒤에 매치 성사 시뮬레이션
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        matchStatus = "매치 성사! 상대와 게임을 시작합니다.";
        isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PVP 창"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    playerName = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: "플레이어 이름 입력",
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: playerName.isNotEmpty && !isSearching
                    ? startMatch
                    : null, // 이름이 없거나 검색 중이면 비활성화
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text(
                  isSearching ? "매치 대기 중..." : "매치 시작",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  matchStatus,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
