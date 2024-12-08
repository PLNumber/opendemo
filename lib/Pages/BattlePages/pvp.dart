import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Function/Profile/secure.dart';
import 'gameRoom.dart';

// pvp.dart
class PVPPage extends StatefulWidget {
  const PVPPage({Key? key}) : super(key: key);

  @override
  _PVPPageState createState() => _PVPPageState();
}

class _PVPPageState extends State<PVPPage> {
  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref("rooms");
  String playerName = "Player";
  String statusMessage = "상태 메시지를 입력하세요";
  String? profileImage;
  bool isCreatingRoom = false;

  @override
  void initState() {
    super.initState();
    _loadPlayerProfile();
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

  Future<void> createRoom() async {
    setState(() {
      isCreatingRoom = true;
    });

    String newRoomId = _roomsRef.push().key!;

    await _roomsRef.child(newRoomId).set({
      "players": {
        playerName: {
          "name": playerName,
          "status": "waiting",
          "lastActive": DateTime.now().millisecondsSinceEpoch,
        },
      },
      "questions": [],
      "status": "waiting",
    });

    setState(() {
      isCreatingRoom = false;
    });

    // 방 대기 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameRoomPage(roomId: newRoomId, playerId: playerName),
      ),
    );
  }

  Future<void> quickJoinRoom() async {
    try {
      DatabaseEvent event = await _roomsRef.once();
      final rooms = event.snapshot.value as Map<Object?, Object?>?;

      if (rooms != null) {
        for (var roomId in rooms.keys) {
          final roomData = rooms[roomId] as Map<Object?, Object?>;
          final players = roomData['players'] as Map<Object?, Object?>;

          // 플레이어 수가 1명인 방에 입장
          if (players.length < 2) {
            await joinRoomById(roomId.toString());
            return; // 방에 입장한 후 종료
          }
        }
      }

      // 입장 가능한 방이 없을 경우 경고 메시지
      _showNoAvailableRoomDialog();
    } catch (e) {
      print("방을 찾는 중 오류 발생: $e");
    }
  }

  Future<void> joinRoomById(String enteredRoomId) async {
    DatabaseEvent event = await _roomsRef.child(enteredRoomId).once();
    if (event.snapshot.exists) {
      // 방이 존재하면 게임 방으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameRoomPage(roomId: enteredRoomId, playerId: playerName),
        ),
      );
    }
  }

  void _showNoAvailableRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("경고"),
        content: const Text("입장 가능한 방이 없습니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("확인"),
          ),
        ],
      ),
    );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isCreatingRoom ? null : createRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                ),
                child: isCreatingRoom
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("방 만들기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: quickJoinRoom,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.orange,
                ),
                child: const Text("빠른 입장", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
