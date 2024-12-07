import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../BattlePages/pve.dart';
import '../BattlePages/pvp.dart';

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

  @override
  void initState() {
    super.initState();
    fetchBattleData(); // 사용자 데이터 로드
    fetchRankingData(); // 순위표 데이터 로드
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

  // 트로피 색깔을 금, 은, 동으로 변경하는 함수
  Color getTrophyColor(int rank) {
    if (rank == 1) {
      return Colors.amber; // 금색
    } else if (rank == 2) {
      return Colors.grey; // 은색
    } else if (rank == 3) {
      return Colors.brown; // 동색
    } else {
      return Colors.black; // 기본 색
    }
  }

  void _navigateToPVPPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PVPPage()),
    );
  }

  void _navigateToQuizBattlePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizBattlePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Battle Page"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 통합 카드: 리더보드 + 프로필 + 랭킹 점수
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
                      // 순위표
                      Text(
                        "랭킹 순위표",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      // 순위 데이터를 카드 안에 배치
                      ...topRanks.asMap().map((index, rank) {
                        // index로 순위를 확인
                        int rankIndex = index + 1; // 순위는 1부터 시작
                        return MapEntry(
                          index,
                          ListTile(
                            leading: Icon(
                              Icons.emoji_events,
                              color: getTrophyColor(rankIndex),
                            ),
                            title: Text(
                              rank['name'],
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: Text(
                              "${rank['rankPt']} 점",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }).values.toList(),
                      const SizedBox(height: 20),

                      // 프로필 이미지 (중앙 정렬)
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(profileImg),
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 20),

                      // 내 랭킹 점수 (중앙 정렬)
                      Text(
                        "내 랭킹 점수: $rankPt",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // 버튼을 GridView로 배치
              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1,
                children: [
                  // PVP 버튼
                  ElevatedButton(
                    onPressed: _navigateToPVPPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 40, color: Colors.blue),
                        const SizedBox(height: 10),
                        Text(
                          "PVP 배틀",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // 퀴즈 배틀 버튼
                  ElevatedButton(
                    onPressed: _navigateToQuizBattlePage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz, size: 40, color: Colors.green),
                        const SizedBox(height: 10),
                        Text(
                          "퀴즈 배틀",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
