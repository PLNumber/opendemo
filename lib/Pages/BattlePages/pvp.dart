import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Function/Profile/secure.dart'; // Profile 정보 불러오기 함수 사용

class PVPPage extends StatefulWidget {
  const PVPPage({Key? key}) : super(key: key);

  @override
  _PVPPageState createState() => _PVPPageState();
}

class _PVPPageState extends State<PVPPage> {
  final DatabaseReference _queueRef = FirebaseDatabase.instance.ref("queue");
  String playerName = "Player"; // 기본값
  String matchStatus = "'매치 시작'버튼을 눌러 시작하세요!";
  String statusMessage = "상태 메시지를 입력하세요"; // 기본값
  String? profileImage; // 기본값
  String? opponentName;
  String? opponentImage;
  String? opponentStatus;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadPlayerProfile(); // 플레이어 프로필 데이터 불러오기
  }

  Future<void> _loadPlayerProfile() async {
    // Secure Storage에서 저장된 데이터 가져오기
    String? savedName = await loadDataSecure('playerName');
    String? savedStatus = await loadDataSecure('statusMessage');
    String? savedImage = await loadProfileImage();

    setState(() {
      playerName = savedName ?? "Player"; // 저장된 이름이 없으면 기본값 사용
      statusMessage = savedStatus ?? "상태 메시지를 입력하세요";
      profileImage = savedImage ?? 'assets/images/default.jpg'; // 기본 이미지
    });
  }

  Future<void> startMatch() async {
    setState(() {
      isSearching = true;
      matchStatus = "플레이어 찾는 중...";
    });

    // 대기열에 플레이어 추가
    String playerKey = _queueRef.push().key!;
    await _queueRef.child(playerKey).set({
      "name": playerName,
      "statusMessage": statusMessage,
      "profileImage": profileImage,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });

    // 대기열에서 다른 플레이어 찾기
    _queueRef.onChildAdded.listen((event) async {
      if (event.snapshot.key != playerKey) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          setState(() {
            opponentName = data["name"];
            opponentStatus = data["statusMessage"];
            opponentImage = data["profileImage"];
            matchStatus = "매치 성사! 상대: $opponentName";
            isSearching = false;
          });

          // 매치 성사 후 대기열에서 자신과 상대 제거
          await _queueRef.child(playerKey).remove();
          await _queueRef.child(event.snapshot.key!).remove();
        }
      }
    });
  }

  @override
  void dispose() {
    // 대기열 정리
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
            // 자신의 프로필
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profileImage != null
                      ? NetworkImage(profileImage!)
                      : const AssetImage('assets/images/default.jpg')
                  as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  playerName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  statusMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 40),

            // 매치 버튼
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

            // 매치 상태
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
            const SizedBox(height: 40),

            // 상대방 프로필 (매치 성사 시)
            if (opponentName != null) ...[
              const Divider(),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: opponentImage != null
                    ? NetworkImage(opponentImage!)
                    : const AssetImage('assets/images/default.jpg')
                as ImageProvider,
              ),
              const SizedBox(height: 10),
              Text(
                opponentName!,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                opponentStatus ?? "상태 메시지가 없습니다.",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
