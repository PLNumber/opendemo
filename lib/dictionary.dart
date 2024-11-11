import 'package:flutter/material.dart';

/*사전 페이지*/
class DictPage extends StatefulWidget {
  const DictPage({Key? key}) : super(key: key);

  @override
  _DictPageState createState() => _DictPageState();
}

class _DictPageState extends State<DictPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _results = [];

  // Example word list for testing purposes
  final List<String> _dictionary = [
    "apple",
    "banana",
    "grape",
    "orange",
    "peach",
    "pineapple",
    "watermelon"
  ];

  // Search function
  void _searchWord(String query) {
    final results = _dictionary
        .where((word) => word.contains(query.toLowerCase()))
        .toList();
    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("사전 창"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            /*단어 검색 입력 필드*/
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '단어 검색',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchWord(_searchController.text),
                ),
              ),
              onSubmitted: _searchWord,
            ),
            SizedBox(height: 20),

            /*검색 결과 표시*/
            Expanded(
              child: _results.isEmpty
                  ? Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_results[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}