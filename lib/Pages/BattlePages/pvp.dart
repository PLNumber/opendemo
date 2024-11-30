import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Function/class.dart';
import '../../Function/Profile/secure.dart';
import 'gameRoom.dart';

class PVPPage extends StatefulWidget {
  const PVPPage({Key? key}) : super(key: key);

  @override
  _PVPPageState createState() => _PVPPageState();
}

class _PVPPageState extends State<PVPPage> {
  final DatabaseReference _queueRef = FirebaseDatabase.instance.ref("queue");
  String playerName = "Player";
  String matchStatus = "'매치 시작' 버튼을 눌러 시작하세요!";
  String statusMessage = "상태 메시지를 입력하세요";
  String? profileImage;
  bool isSearching = false;
  bool opponentDisconnected = false;

  @override
  void initState() {
    super.initState();
    _loadPlayerProfile();
    handleDisconnect();
  }

  Future<void> _loadPlayerProfile() async {
    String? savedName = await loadDataSecure('playerName');
    String? savedStatus = await loadDataSecure('statusMessage');
    String? savedImage = await loadProfileImage();

    setState(() {
      playerName = savedName ?? "Player";
      statusMessage = savedStatus ?? "상태 메시지를 입력하세요";
      profileImage = savedImage ?? 'assets/images/default.jpg';
    });
  }

  Future<void> startMatch() async {
    setState(() {
      isSearching = true;
      matchStatus = "플레이어 찾는 중...";
    });

    String playerKey = _queueRef.push().key!;

    try {
      // 대기열에 플레이어 추가
      await _queueRef.child(playerKey).set({
        "name": playerName,
        "statusMessage": statusMessage,
        "profileImage": profileImage,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });

      _queueRef.child(playerKey).onDisconnect().remove();

      // 상대방 찾기
      _queueRef.onChildAdded.listen((event) async {
        if (event.snapshot.key != playerKey) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data != null) {
            String opponentKey = event.snapshot.key!;
            await createGameRoom(playerKey, opponentKey); // 방 생성

            if (mounted) { // 추가된 체크
              setState(() {
                matchStatus = "매치 성사! 상대: ${data["name"]}";
                isSearching = false;
              });
            }

            // 대기열에서 자신과 상대 제거
            await _queueRef.child(playerKey).remove();
            await _queueRef.child(opponentKey).remove();
          }
        }
      });

      _queueRef.child(playerKey).onDisconnect().set({
        "status": "disconnected",
      });

    } catch (e) {
      if (mounted) { // 추가된 체크
        setState(() {
          matchStatus = "오류 발생: $e";
          isSearching = false;
        });
      }
    }
  }

  Future<void> createGameRoom(String playerKey, String opponentKey) async {
    final DatabaseReference roomRef = FirebaseDatabase.instance.ref("rooms").push();
    String roomId = roomRef.key!;

    // 방 정보 저장
    await roomRef.set({
      "players": {
        playerKey: {
          "name": playerName,
          "status": "active",
        },
        opponentKey: {
          "name": "상대방 이름", // 상대방 이름은 나중에 업데이트
          "status": "active",
        },
      },
      "questions": [], // 문제 목록을 추가할 수 있는 공간
      "status": "active",
    });

    // 방 ID를 플레이어에게 전달하여 방으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameRoomPage(roomId: roomId),
      ),
    );
  }

  void handleDisconnect() {
    _queueRef.onChildRemoved.listen((event) {
      if (event.snapshot.key != null && !opponentDisconnected) {
        if (mounted) { // 추가된 체크
          setState(() {
            matchStatus = "상대방이 매칭을 취소했습니다.";
            isSearching = false;
            opponentDisconnected = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
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
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profileImage != null
                      ? NetworkImage(profileImage!)
                      : const AssetImage('assets/images/default.jpg') as ImageProvider,
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
