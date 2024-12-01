import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<bool> purchased = [];
  int shopPoints = 0;
  List<String> itemImages = [];
  List<int> itemPrices = [0, 150, 200, 250, 300, 350];
  List<String> itemNames = [
    "K I T",
    "주먹두",
    "꼬부기두",
    "HUH",
    "바나나캣",
    "슬픈고양이"
  ];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopData();
  }

  Future<void> _fetchShopData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("사용자가 로그인되지 않았습니다.");
      }

      String uid = currentUser.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(uid)
          .get();

      QuerySnapshot imageDocs = await FirebaseFirestore.instance
          .collection('Images')
          .get();

      List<String> urls = [];
      for (var doc in imageDocs.docs) {
        if (doc['URL'] != null) {
          urls.addAll(List<String>.from(doc['URL']));
        }
      }

      if (userDoc.exists) {
        setState(() {
          purchased = List<bool>.from(userDoc['purchased'] ?? []);
          shopPoints = userDoc['shopPt'] ?? 0;
          itemImages = urls;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching shop data: $e");
      setState(() {
        isLoading = false;
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
                fontSize: 24, // 포인트 텍스트 크기 증가
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: itemImages.length,
                itemBuilder: (context, index) {
                  String name = index < itemNames.length
                      ? itemNames[index]
                      : "아이템 ${index + 1}";
                  int price = index < itemPrices.length
                      ? itemPrices[index]
                      : 0;

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      leading: Image.network(
                        itemImages[index],
                        width: 80, // 이미지 크기 증가
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error,
                            size: 40, // 에러 아이콘 크기 증가
                          );
                        },
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20, // 제목 텍스트 크기 증가
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '구매 포인트: $price 포인트',
                        style: const TextStyle(
                          fontSize: 16, // 부제목 텍스트 크기 증가
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: const Text(
                          '적용',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: shopPoints >= price
                            ? () {
                          _buyItem(index, price);
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
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
