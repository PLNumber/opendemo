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
  String _errorMessage = ''; // 오류 메시지를 저장할 변수
  bool _isLoading = false;  // 로딩 상태 표시 변수
  final KoreanDictionaryAPI _api = KoreanDictionaryAPI();

  // 단어 정의 검색
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
      _isLoading = true; // 로딩 시작
      _errorMessage = ''; // 기존 오류 메시지 초기화
    });

    try {
      final definition = await _api.search(word);
      setState(() {
        _definition = definition.isEmpty ? '정의가 없습니다.' : definition;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'API 호출 실패: $e';
        _definition = '';
      });
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('단어 정의 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '단어를 입력',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _searchWord,  // 단어 정의 검색
              child: Text('정의 찾기'),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()  // 로딩 중 표시
                : _errorMessage.isNotEmpty
                ? Text(
              _errorMessage,
              style: TextStyle(fontSize: 18.0, color: Colors.red),
            ) // 오류 메시지 표시
                : Text(
              _definition.isEmpty ? '정의가 없습니다.' : _definition,
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
