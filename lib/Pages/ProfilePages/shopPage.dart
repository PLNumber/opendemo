import 'package:flutter/material.dart';

class GridViewScreen extends StatefulWidget {
  @override
  _GridViewScreenState createState() => _GridViewScreenState();
}

class _GridViewScreenState extends State<GridViewScreen> {
  final List<String> imageUrls = [
    "https://ifh.cc/g/8AckGM.jpg",
    "https://ifh.cc/g/L59g64.jpg",
    "https://ifh.cc/g/9sJkbf.jpg",
    "https://ifh.cc/g/qd2MQr.png",
    "https://ifh.cc/g/Kbwg5j.jpg",
    "https://ifh.cc/g/6dRKzO.webp",
  ];

  final List<int> prices = [10, 20, 15, 12, 25, 18]; // 각 아이템의 가격
  List<bool> isPurchased = [false, false, false, false, false, false]; // 구매 여부 관리
  int userPoints = 100; // 초기 소지 포인트

  void handleTap(int index) {
    if (isPurchased[index]) {
      // 이미 구매한 경우 이전 페이지로 URL 전달
      Navigator.pop(context, imageUrls[index]);
    } else {
      // 구매 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("구매 확인"),
          content: Text("${prices[index]} 포인트로 구매하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 취소 버튼
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                if (userPoints >= prices[index]) {
                  setState(() {
                    userPoints -= prices[index]; // 포인트 차감
                    isPurchased[index] = true; // 구매 상태 업데이트
                  });
                }
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: Text("구매"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("상점 페이지"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 소지 포인트를 표시하는 공간
          Container(
            color: Colors.blueGrey[50],
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "소지 포인트",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "$userPoints 포인트",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1.0, color: Colors.grey), // 구분선
          // GridView 표시
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.8,
              ),
              itemCount: imageUrls.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => handleTap(index), // 구매 및 클릭 처리 함수 호출
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrls[index],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                    child: Icon(Icons.error, color: Colors.red));
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      // 구매 여부에 따라 텍스트 변경
                      Text(
                        isPurchased[index] ? "구매함" : "${prices[index]} 포인트",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: isPurchased[index] ? Colors.green : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
