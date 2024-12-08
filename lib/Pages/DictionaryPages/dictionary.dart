import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:opendemo/Function/api.dart';

class DictPage extends StatefulWidget {
  const DictPage({Key? key}) : super(key: key);

  @override
  _DictPageState createState() => _DictPageState();
}

class _DictPageState extends State<DictPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _definitions = [];
  String _errorMessage = '';
  bool _isLoading = false;
  List<String> _recentWords = [];
  final KoreanDictionaryAPI _api = KoreanDictionaryAPI();

  @override
  void initState() {
    super.initState();
    _loadRecentWords();
  }

  Future<void> _loadRecentWords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentWords = prefs.getStringList('recentWords') ?? [];
    });
  }

  Future<void> _saveRecentWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentWords', _recentWords);
  }

  Future<void> _searchWord() async {
    final word = _searchController.text.trim();
    if (word.isEmpty) {
      setState(() {
        _errorMessage = '단어를 입력해 주세요.';
        _definitions.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final definitions = await _api.search(word);
      setState(() {
        _definitions = definitions;
        _errorMessage = '';
      });
      if (!_recentWords.contains(word)) {
        setState(() {
          _recentWords.add(word);
          if (_recentWords.length > 5) {
            _recentWords.removeAt(0);
          }
          _saveRecentWords();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'API 호출 실패: $e';
        _definitions.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchFromChip(String word) {
    _searchController.text = word;
    _searchWord();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '단어 정의 검색',
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '단어를 입력',
                labelStyle: TextStyle(color: Colors.teal),
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.teal),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _definitions.clear();
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.black : Colors.teal[50], // 다크 모드에서 검은색 배경
                hintStyle: TextStyle(color: Colors.teal[300]),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // 입력 텍스트 색상
              onSubmitted: (_) => _searchWord(),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _searchWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                textStyle: const TextStyle(fontSize: 18.0),
              ),
              child: Text(
                '정의 찾기',
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // 다크 모드에서 흰색으로 변경
              ),
            ),
            const SizedBox(height: 20.0),
            if (_recentWords.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: _recentWords.map((word) {
                  return GestureDetector(
                    onTap: () => _searchFromChip(word),
                    child: Chip(
                      label: Text(
                        word,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // 검은색 텍스트
                      ),
                      onDeleted: () {
                        setState(() {
                          _recentWords.remove(word);
                          _saveRecentWords();
                        });
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20.0),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 18.0, color: Colors.red),
                textAlign: TextAlign.center,
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _definitions.length,
                  itemBuilder: (context, index) {
                    final item = _definitions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4, // 그림자 효과 추가
                      child: ListTile(
                        title: Text(
                          item['word'] ?? '단어 없음',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black, // 검은색 텍스트
                          ),
                        ),
                        subtitle: Text(
                          item['definition'] ?? '정의 없음',
                          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54), // 검은색 텍스트
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
}
