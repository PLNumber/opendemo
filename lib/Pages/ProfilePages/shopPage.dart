import 'package:flutter/material.dart';

class GridViewScreen extends StatelessWidget {
  final List<String> imageUrls = [
    "https://ifh.cc/g/8AckGM.jpg",
    "https://ifh.cc/g/L59g64.jpg",
    "https://ifh.cc/g/9sJkbf.jpg",
    "https://ifh.cc/g/qd2MQr.png",
    "https://ifh.cc/g/Kbwg5j.jpg",
    "https://ifh.cc/g/6dRKzO.webp",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("상점 페이지"),
        centerTitle: true,
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 한 줄에 몇 개의 아이템을 표시할지
          crossAxisSpacing: 8.0, // 아이템 간의 가로 간격
          mainAxisSpacing: 8.0, // 아이템 간의 세로 간격
          childAspectRatio: 1.0, // 아이템의 가로 세로 비율
        ),
        itemCount: imageUrls.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // 선택된 이미지 URL을 반환하면서 현재 화면 종료
              Navigator.pop(context, imageUrls[index]);
            },
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
                    return Center(child: Icon(Icons.error, color: Colors.red));
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
