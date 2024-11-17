import 'package:flutter/material.dart';
import 'shopPage.dart';
import '../../Function/Profile/secure.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int win = 0;
  int lose = 0;
  int level = 1;
  String playerName = "Player";
  String statusMessage = "상태 메시지를 입력하세요";
  String? _profileImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // 데이터를 비동기적으로 불러옵니다.
  }

  Future<void> _loadProfileData() async {
    // 비동기적으로 데이터 불러오기
    String? savedName = await loadDataSecure('playerName');
    String? savedStatus = await loadDataSecure('statusMessage');
    String? savedImage = await loadProfileImage();

    setState(() {
      playerName = savedName ?? "Player";
      statusMessage = savedStatus ?? "상태 메시지를 입력하세요";
      _profileImage = savedImage ?? 'assets/images/ronaldo.jpg'; // 기본 이미지
    });
  }

  void _updateName() {
    setState(() {
      playerName = _nameController.text;
      _nameController.clear();
      saveDataSecure('playerName', playerName); // 이름 저장
    });
  }

  void _updateStatus() {
    setState(() {
      statusMessage = _statusController.text.isNotEmpty
          ? _statusController.text
          : "상태 메시지를 입력하세요";
      _statusController.clear();
      saveDataSecure('statusMessage', statusMessage); // 상태 메시지 저장
    });
  }

  void _changeProfileImage() {
    String newImagePath = 'assets/images/ronaldo.jpg';
    saveProfileImage(newImagePath);  // 새로운 이미지 저장
    setState(() {
      _profileImage = newImagePath;  // 화면에서 프로필 이미지 변경
    });
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
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _changeProfileImage,
                onLongPress: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const ShopPage()));
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null
                      ? AssetImage(_profileImage!)
                      : const AssetImage('assets/images/ronaldo.jpg'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                statusMessage,
                style: const TextStyle(fontSize: 22, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(playerName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 150,
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '이름 변경',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.blueAccent),
                            onPressed: _updateName,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),


              /* 전적 카드 */
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: [
                          const Text("승리", style: TextStyle(fontSize: 24, color: Colors.green)),
                          Text('$win', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          const Text("패배", style: TextStyle(fontSize: 24, color: Colors.redAccent)),
                          Text('$lose', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /* 레벨 카드 */
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("레벨", style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 20),
                      Text('$level', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /* 상태 메시지 카드 */
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text("상태 메시지", style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 150, // 너비 줄이기
                            child: TextField(
                              controller: _statusController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '상태 메시지 입력',
                              ),
                              onSubmitted: (_) => _updateStatus(), // Enter 키로 상태 메시지 저장
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.blueAccent),
                            onPressed: _updateStatus,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

