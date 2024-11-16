import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Literacy Quiz Battle',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: ProfilePage(),
    );
  }
}

/*프로필 페이지*/
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int win = 0;
  int lose = 0;
  int level = 1; // 사용자의 레벨
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  String playerName = "Player";
  String statusMessage = "상태 메시지를 입력하세요"; // 상태 메시지 초기값

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  void _updateName() {
    setState(() {
      playerName = _nameController.text;
      _nameController.clear();
      _showSnackBar(context, "이름이 변경되었습니다!");
    });
  }

  void _updateStatus() {
    setState(() {
      statusMessage = _statusController.text.isNotEmpty
          ? _statusController.text
          : "상태 메시지를 입력하세요"; // 상태 메시지 초기값으로 설정
      _statusController.clear();
      _showSnackBar(context, "상태 메시지가 변경되었습니다!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView( // 스크롤 기능 추가
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /* 힌트 아이콘 */
              GestureDetector(
                onTap: () {
                  _showSnackBar(context, "상점은 프로필 사진을 길게 누르세요!");
                },
                child: Icon(Icons.info_outline, size: 30, color: Colors.pinkAccent),
              ),
              const SizedBox(height: 20),

              /* 프로필 사진 */
              GestureDetector(
                onLongPress: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const ShopPage()));
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: const AssetImage('assets/profile.jpg'),
                ),
              ),
              const SizedBox(height: 20),

              /* 상태 메시지 표시 */
              Text(
                statusMessage,
                style: const TextStyle(fontSize: 22, color: Colors.black54), // 글씨 크기 증가
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              /* 이름 변경 카드 */
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
                            width: 150,  // 너비 줄이기
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

/* 상점 페이지 */
class ShopPage extends StatelessWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("상점"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 7,
        itemBuilder: (context, index) {
          final colors = [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.indigo,
            Colors.purple
          ];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("아이템 ${index + 1} 선택됨")),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: colors[index],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  "아이템 ${index + 1}",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
