import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<bool> purchased = []; // DB에서 받아올 purchased 리스트
  int shopPoints = 0; // DB에서 받아올 shopPt
  List<String> itemImages = []; // DB에서 받아올 이미지 URL 리스트
  List<int> itemPrices = []; // DB에서 받아올 가격 리스트
  List<String> itemNames = []; // DB에서 받아올 아이템 이름 리스트
  bool isLoading = true; // 데이터를 로드 중인 상태

  @override
  void initState() {
    super.initState();
    _fetchShopData(); // Shop 데이터 가져오기
  }

  // Firestore에서 구매 상태(purchased)와 포인트(shopPt) 및 이미지 데이터 가져오는 함수
  Future<void> _fetchShopData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("사용자가 로그인되지 않았습니다.");
      }

      String uid = currentUser.uid;

      // UserData 컬렉션에서 purchased와 shopPt 가져오기
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(uid)
          .get();

      // Images 컬렉션에서 URL, cost, imageName 가져오기
      QuerySnapshot imageDocs = await FirebaseFirestore.instance
          .collection('Images')
          .get();

      List<String> urls = [];
      List<int> prices = [];
      List<String> names = [];

      // Image 컬렉션에서 URL, cost, imageName을 가져오기
      for (var doc in imageDocs.docs) {
        if (doc['URL'] != null && doc['cost'] != null && doc['imageName'] != null) {
          urls.addAll(List<String>.from(doc['URL']));
          prices.addAll(List<int>.from(doc['cost']));
          names.addAll(List<String>.from(doc['imageName']));
        }
      }

      if (userDoc.exists) {
        setState(() {
          purchased = List<bool>.from(userDoc['purchased'] ?? []);
          shopPoints = userDoc['shopPt'] ?? 0;
          itemImages = urls;
          itemPrices = prices;
          itemNames = names;
          isLoading = false; // 데이터 로드 완료
        });
      }
    } catch (e) {
      print("Error fetching shop data: $e");
      setState(() {
        isLoading = false; // 에러 발생 시 데이터 로드 완료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상점'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemImages.isEmpty
          ? const Center(child: Text('이미지가 없습니다.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '현재 포인트: $shopPoints',
              style: const TextStyle(
                fontSize: 24, // 포인트 텍스트 크기
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: itemImages.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: Image.network(
                        itemImages[index],
                        width: 80, // 이미지 크기
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error,
                            size: 40, // 에러 아이콘 크기
                          );
                        },
                      ),
                      title: Text(
                        itemNames[index],
                        style: const TextStyle(
                          fontSize: 20, // 제목 텍스트 크기
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '구매 포인트: ${itemPrices[index]} 포인트',
                        style: const TextStyle(
                          fontSize: 16, // 부제목 텍스트 크기
                        ),
                      ),
                      trailing: purchased.isNotEmpty &&
                          purchased.length > index &&
                          purchased[index]
                          ? ElevatedButton(
                        onPressed: () {
                          _applyItem(itemImages[index]);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text(
                          '적용',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: shopPoints >= itemPrices[index]
                            ? () {
                          _buyItem(index, itemPrices[index]);
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text(
                          '구매',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 아이템을 구매하는 함수
  void _buyItem(int index, int price) {
    setState(() {
      if (purchased.length <= index) {
        purchased.addAll(List<bool>.filled(index - purchased.length + 1, false));
      }
      purchased[index] = true;
      shopPoints -= price;
    });

    _updateShopData();
  }

  // Firestore에 구매 상태 및 포인트를 업데이트하는 함수
  Future<void> _updateShopData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("사용자가 로그인되지 않았습니다.");
      }

      String uid = currentUser.uid;
      await FirebaseFirestore.instance.collection('UserData').doc(uid).update({
        'purchased': purchased,
        'shopPt': shopPoints,
      });
    } catch (e) {
      print("Error updating shop data: $e");
    }
  }

  // 프로필 이미지를 적용하는 함수
  Future<void> _applyItem(String imageUrl) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("사용자가 로그인되지 않았습니다.");
      }

      String uid = currentUser.uid;
      await FirebaseFirestore.instance.collection('UserData').doc(uid).update({
        'profileImg': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 이미지가 변경되었습니다!')),
      );
    } catch (e) {
      print("Error applying profile image: $e");
    }
  }
}
