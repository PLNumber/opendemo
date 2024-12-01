import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shopPage.dart'; // GridViewScreen이 포함된 파일

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 사용자 데이터 필드
  String name = "Player";
  String currentMSG = "상태 메시지가 없습니다.";
  String profileImg = "https://via.placeholder.com/150"; // 기본 이미지
  int win = 0;
  int loss = 0;

  bool isLoading = true; // 데이터 로드 상태
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData(); // 데이터 로드
  }

  Future<void> fetchUserData() async {
    try {
      // 현재 로그인된 사용자 가져오기
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("로그인된 사용자가 없습니다.");
      }

      // Firestore에서 UID로 문서 가져오기
      String uid = currentUser.uid;
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(uid)
          .get();

      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        setState(() {
          name = data['name'] ?? "Player";
          currentMSG = data['currentMSG'] ?? "상태 메시지가 없습니다.";
          profileImg = data['profileImg'] ?? "https://via.placeholder.com/150";
          win = data['win'] ?? 0;
          loss = data['loss'] ?? 0;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception("사용자 데이터를 찾을 수 없습니다.");
      }
    } catch (e) {
      print("데이터 가져오기 오류: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateName(String newName) async {
    try {
      // 현재 로그인된 사용자 가져오기
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("로그인된 사용자가 없습니다.");
      }

      String uid = currentUser.uid;

      // Firestore의 name 필드 업데이트
      await FirebaseFirestore.instance
          .collection('UserData')
          .doc(uid)
          .update({'name': newName});

      setState(() {
        name = newName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이름이 성공적으로 변경되었습니다.")),
      );
    } catch (e) {
      print("이름 업데이트 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이름 변경 중 오류가 발생했습니다.")),
      );
    }
  }

  Future<void> updateStatus(String newStatus) async {
    try {
      // 현재 로그인된 사용자 가져오기
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("로그인된 사용자가 없습니다.");
      }

      String uid = currentUser.uid;

      // Firestore의 currentMSG 필드 업데이트
      await FirebaseFirestore.instance
          .collection('UserData')
          .doc(uid)
          .update({'currentMSG': newStatus});

      setState(() {
        currentMSG = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("상태 메시지가 성공적으로 변경되었습니다.")),
      );
    } catch (e) {
      print("상태 메시지 업데이트 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("상태 메시지 변경 중 오류가 발생했습니다.")),
      );
    }
  }

  // 플로팅 버튼 클릭 시 GridViewScreen으로 네비게이션
  void _navigateToGridView() async {
    final selectedImageUrl = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShopPage()),
    );

    if (selectedImageUrl != null) {
      setState(() {
        profileImg = selectedImageUrl; // 새 프로필 이미지 업데이트
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 로딩 표시
          : SingleChildScrollView(
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
                        "$name",
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
                                updateName(_nameController.text);
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
                                updateStatus(_statusController.text);
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
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
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
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
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
      ),
      // 플로팅 액션 버튼 추가
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToGridView, // GridViewScreen으로 이동
        child: const Icon(Icons.shop),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
