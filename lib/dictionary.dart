import 'package:flutter/material.dart';
import 'package:opendemo/api.dart';

class DictPage extends StatefulWidget {
  const DictPage({Key? key}) : super(key: key);

  @override
  _DictPageState createState() => _DictPageState();
}

class _DictPageState extends State<DictPage> {
  final TextEditingController _searchController = TextEditingController();

  String _definition = "";
  String _errorMessage = '';
  bool _isLoading = false;
  List<String> _recentWords = [];
  final KoreanDictionaryAPI _api = KoreanDictionaryAPI();

  Future<void> _searchWord() async {
    final word = _searchController.text.trim();
    if (word.isEmpty) {
      setState(() {
        _errorMessage = '단어를 입력해 주세요.';
        _definition = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final definition = await _api.search(word);
      setState(() {
        _definition = definition.isEmpty ? '정의가 없습니다.' : definition;
        _errorMessage = '';
      });
      if (!_recentWords.contains(word)) {
        setState(() {
          _recentWords.add(word);
          if (_recentWords.length > 5) {
            _recentWords.removeAt(0); // 최근 검색어는 최대 5개로 제한
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'API 호출 실패: $e';
        _definition = '';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '단어 정의 검색',
          style: TextStyle(color: Colors.white),
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
                labelStyle: const TextStyle(color: Colors.teal),
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.teal),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
                filled: true,
                fillColor: Colors.teal[50],
                hintStyle: TextStyle(color: Colors.teal[300]),
              ),
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
              child: const Text('정의 찾기'),
            ),
            const SizedBox(height: 20.0),
            if (_recentWords.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: _recentWords.map((word) {
                  return GestureDetector(
                    onTap: () => _searchFromChip(word),
                    child: Chip(
                      label: Text(word),
                      onDeleted: () {
                        setState(() {
                          _recentWords.remove(word);
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
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _definition.isEmpty
                        ? const Text('정의가 없습니다.')
                        : Container(
                      key: ValueKey(_definition),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.teal, width: 1),
                      ),
                      child: Text(
                        _definition,
                        style: const TextStyle(fontSize: 18.0, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
