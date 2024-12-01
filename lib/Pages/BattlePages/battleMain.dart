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

  @override
  void initState() {
    super.initState();
    fetchBattleData(); // 데이터 로드
  }

  Future<void> fetchBattleData() async {
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

  // PVPPage로 네비게이션
  void _navigateToPVPPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PVPPage()),
    );
  }

  // QuizBattlePage로 네비게이션
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
          ? const Center(child: CircularProgressIndicator()) // 로딩 표시
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙 정렬
            children: [
              // 프로필 이미지 표시
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profileImg),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 20),

              // 랭킹 점수 표시
              Text(
                "랭킹 점수: $rankPt",
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // PVPPage로 이동하는 버튼
              ElevatedButton(
                onPressed: _navigateToPVPPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  "PVP 배틀",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),

              // QuizBattlePage로 이동하는 버튼
              ElevatedButton(
                onPressed: _navigateToQuizBattlePage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  backgroundColor: Colors.greenAccent,
                ),
                child: const Text(
                  "퀴즈 배틀",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}