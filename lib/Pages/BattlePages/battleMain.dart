import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../Function/Profile/secure.dart';
import '../BattlePages/pve.dart';
import 'ghost.dart';
import 'ghostBattle.dart';

class BattlePage extends StatefulWidget {
  const BattlePage({Key? key}) : super(key: key);

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  String profileImg = "https://via.placeholder.com/150"; // 기본 이미지
  int rankPt = 0; // 기본 점수
  bool isLoading = true; // 데이터 로드 상태
  List<Map<String, dynamic>> topRanks = []; // 순위 데이터

  bool isPvpSelected = false; // PVP 버튼 상태
  final DatabaseReference _roomsRef = FirebaseDatabase.instance.ref("rooms");
  String playerName = "Player";
  String statusMessage = "상태 메시지를 입력하세요";
  String? profileImage;
  bool isCreatingRoom = false;

  @override
  void initState() {
    super.initState();
    fetchBattleData(); // 사용자 데이터 로드
    fetchRankingData(); // 순위표 데이터 로드
    _loadPlayerProfile();
  }

  Future<void> fetchBattleData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("로그인된 사용자가 없습니다.");
      }

      String uid = currentUser.uid;
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(uid)
          .get();

      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        setState(() {
          profileImg = data['profileImg'] ?? "https://via.placeholder.com/150";
          rankPt = data['rankPt'] ?? 0;
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

  Future<void> fetchRankingData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('UserData')
          .orderBy('rankPt', descending: true)
          .limit(3)
          .get();

      List<Map<String, dynamic>> ranks = snapshot.docs.map((doc) {
        return {
          'name': doc['name'] ?? 'Unknown',
          'rankPt': doc['rankPt'] ?? 0,
        };
      }).toList();

      setState(() {
        topRanks = ranks;
      });
    } catch (e) {
      print("랭킹 데이터 가져오기 오류: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark; // 다크 모드 확인

    return Scaffold(
      appBar: AppBar(
        title: const Text("대전"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "리더보드",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            ...topRanks
                                .asMap()
                                .map((index, rank) {
                                  int rankIndex = index + 1;
                                  return MapEntry(
                                    index,
                                    ListTile(
                                      leading: Icon(
                                        Icons.emoji_events,
                                        color: rankIndex == 1
                                            ? Colors.amber
                                            : rankIndex == 2
                                                ? Colors.grey
                                                : rankIndex == 3
                                                    ? Colors.brown
                                                    : Colors.black,
                                      ),
                                      title: Text(
                                        rank['name'],
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      trailing: Text(
                                        "${rank['rankPt']} 점",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                })
                                .values
                                .toList(),
                            const SizedBox(height: 20),
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('UserData')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text('사용자 데이터를 불러올 수 없습니다.');
                                }

                                final userData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                final int updatedRankPt =
                                    userData['rankPt'] ?? 0;
                                final String updatedProfileImg =
                                    userData['profileImg'] ??
                                        "https://via.placeholder.com/150";

                                return Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundImage:
                                          NetworkImage(updatedProfileImg),
                                      backgroundColor: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      "내 랭킹 점수: $updatedRankPt",
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Stack(
                        children: [
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1,
                            children: isPvpSelected
                                ? [
                                    _buildElevatedButton(
                                      context,
                                      Icons.connect_without_contact,
                                      "대전하기",
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PvpGhostPage(),
                                          ),
                                        );
                                      },
                                      isDarkMode,
                                    ),
                                    _buildElevatedButton(
                                      context,
                                      Icons.person_add,
                                      "고스트 생성",
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => GhostPage(),
                                          ),
                                        );
                                      },
                                      isDarkMode,
                                    ),
                                  ]
                                : [
                                    _buildElevatedButton(
                                      context,
                                      Icons.people,
                                      "PVP 대전",
                                      () {
                                        setState(() {
                                          isPvpSelected = true;
                                        });
                                      },
                                      isDarkMode,
                                    ),
                                    _buildElevatedButton(
                                      context,
                                      Icons.computer,
                                      "PVE 대전",
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                QuizBattlePage(),
                                          ),
                                        );
                                      },
                                      isDarkMode,
                                    ),
                                  ],
                          ),
                          if (isPvpSelected)
                            Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.end, // 세로 정렬을 끝으로
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  // 가로 중앙 정렬
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white, // 배경색
                                        foregroundColor:
                                            Colors.teal, // 텍스트 및 아이콘 색상
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // 둥근 모서리
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isPvpSelected = false;
                                        });
                                      },
                                      child: const Icon(Icons.arrow_back,
                                          size: 24),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20), // 버튼 간격 추가
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // 버튼을 생성하는 메서드
  Widget _buildElevatedButton(BuildContext context, IconData icon, String title,
      VoidCallback onPressed, bool isDarkMode) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        // 다크 모드일 때 배경색
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        // 다크 모드일 때 텍스트 색상
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // 둥근 모서리
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: isDarkMode ? Colors.white : Colors.teal),
          // 아이콘 색상 설정
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black, // 다크 모드일 때 글씨 색상
            ),
          ),
        ],
      ),
    );
  }
}
