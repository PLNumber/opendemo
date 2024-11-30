import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PVPPage extends StatefulWidget {
  const PVPPage({Key? key}) : super(key: key);

  @override
  _PVPPageState createState() => _PVPPageState();
}

class _PVPPageState extends State<PVPPage> {
  final DatabaseReference _queueRef = FirebaseDatabase.instance.ref("queue");
  String playerName = "Player";
  String matchStatus = "매치 대기 중...";
  String? opponentName;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadPlayerName(); // 플레이어 이름 불러오기
  }

  Future<void> _loadPlayerName() async {
    // 플레이어 이름을 불러오는 로직 (여기서는 예제로 사용)
    setState(() {
      playerName = "Player_${DateTime.now().millisecondsSinceEpoch % 1000}";
    });
  }

  Future<void> startMatch() async {
    setState(() {
      isSearching = true;
      matchStatus = "플레이어 찾는 중...";
    });

    // 대기열에 플레이어 추가
    String playerKey = _queueRef.push().key!;
    await _queueRef.child(playerKey).set({"name": playerName, "timestamp": DateTime.now().millisecondsSinceEpoch});

    // 대기열에서 다른 플레이어 찾기
    _queueRef.onChildAdded.listen((event) async {
      if (event.snapshot.key != playerKey) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          setState(() {
            opponentName = data["name"];
            matchStatus = "매치 성사! 상대: $opponentName";
            isSearching = false;
          });

          // 매치가 성사되면 대기열에서 삭제
          await _queueRef.child(playerKey).remove();
          await _queueRef.child(event.snapshot.key!).remove();
        }
      }
    });
  }

  @override
  void dispose() {
    // 화면 닫힐 때 대기열에서 제거
    _queueRef.onDisconnect().remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PVP 창"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              playerName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSearching ? null : startMatch,
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
    );
  }
}
