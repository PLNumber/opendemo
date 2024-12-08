import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shopPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  // Firestore 사용자 데이터 스트림 가져오기
  Stream<DocumentSnapshot<Map<String, dynamic>>> _getUserStream() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("로그인된 사용자가 없습니다.");
    }
    return FirebaseFirestore.instance
        .collection('UserData')
        .doc(currentUser.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('사용자 데이터를 찾을 수 없습니다.'));
          }

          final userData = snapshot.data!.data();
          final String name = userData?['name'] ?? "Player";
          final String currentMSG = userData?['currentMSG'] ?? "상태 메시지가 없습니다.";
          final String profileImg =
              userData?['profileImg'] ?? "https://via.placeholder.com/150";
          final int win = userData?['win'] ?? 0;
          final int loss = userData?['loss'] ?? 0;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 프로필 이미지
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(profileImg),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),

                  // 상태 메시지
                  Text(
                    currentMSG,
                    style: const TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // 이름 카드
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: "새 이름 입력",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.blueAccent),
                                onPressed: () {
                                  if (_nameController.text.isNotEmpty) {
                                    _updateName(_nameController.text);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 상태 메시지 카드
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            "상태 메시지",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _statusController,
                                  decoration: const InputDecoration(
                                    labelText: "새 상태 메시지 입력",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.blueAccent),
                                onPressed: () {
                                  if (_statusController.text.isNotEmpty) {
                                    _updateStatus(_statusController.text);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 승/패 정보 카드
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text("승리",
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.green)),
                              Text(
                                "$win",
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text("패배",
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.red)),
                              Text(
                                "$loss",
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToGridView,
        child: const Icon(Icons.shop),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Future<void> _updateName(String newName) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("로그인된 사용자가 없습니다.");
      await FirebaseFirestore.instance
          .collection('UserData')
          .doc(currentUser.uid)
          .update({'name': newName});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이름이 성공적으로 변경되었습니다.")),
      );
    } catch (e) {
      print("이름 업데이트 오류: $e");
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("로그인된 사용자가 없습니다.");
      await FirebaseFirestore.instance
          .collection('UserData')
          .doc(currentUser.uid)
          .update({'currentMSG': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("상태 메시지가 성공적으로 변경되었습니다.")),
      );
    } catch (e) {
      print("상태 메시지 업데이트 오류: $e");
    }
  }

  void _navigateToGridView() async {
    final selectedImageUrl = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShopPage()),
    );
    if (selectedImageUrl != null) {
      setState(() {
        // 프로필 이미지는 StreamBuilder를 통해 실시간 반영됨
      });
    }
  }
}
