import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // debugPrint 사용을 위해

class KoreanDictionaryAPI {
  late final String kdsApiKey;
  final String kdsApiUrl = 'https://opendict.korean.go.kr/api/search';

  KoreanDictionaryAPI() {
    // API 키를 환경변수에서 불러오고, 누락된 경우 예외를 발생시킵니다.
    kdsApiKey = dotenv.env['api.URSKEY'] ?? '';
    if (kdsApiKey.isEmpty) {
      throw Exception("Korean Dictionary API Key is missing.");
    }
  }

  // 단어 정의를 검색하는 함수
  Future<String> search(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$kdsApiUrl?key=$kdsApiKey&q=$query'),
      );

      // 응답 상태 확인
      if (response.statusCode == 200) {
        return _parseXmlResponse(response.body);
      } else {
        return 'API 호출 실패: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('API 호출 오류: $e');
      return 'API 호출 중 오류가 발생했습니다.';
    }
  }

  // XML 응답을 파싱하여 정의를 추출하는 함수
  String _parseXmlResponse(String responseBody) {
    try {
      var document = XmlDocument.parse(responseBody);

      // 응답 XML을 로그로 출력하여 내용 확인
      debugPrint('응답 XML: $responseBody');

      // <item> 태그를 찾아 각 단어의 정의 추출
      var items = document.findAllElements('item');
      if (items.isEmpty) return '결과가 없습니다.';

      StringBuffer definitions = StringBuffer();
      for (var item in items) {
        // 단어 추출
        var word = item.findElements('word').first.text;
        debugPrint('단어: $word'); // 단어가 잘 추출되는지 확인

        // <sense> 태그를 찾아 정의 추출
        var senses = item.findElements('sense');
        for (var sense in senses) {
          var definition =
              sense.findElements('definition').map((e) => e.text).join(', ');
          definitions.write('$word: $definition\n');
        }
      }

      return definitions.isEmpty ? '정의가 없습니다.' : definitions.toString();
    } catch (e) {
      debugPrint('XML 파싱 오류: $e');
      return '파싱 오류가 발생했습니다.';
    }
  }
}

//openai 로 단어 리스트 가져오기
Future<List<String>> fetchWordList() async {
  final apiKey = dotenv.env['api.OAKEY'] ?? '';
  if (apiKey.isEmpty) {
    throw Exception("OpenAI API Key가 없거나 제대로 로드되지 않았습니다.");
  }

  final url = Uri.parse("https://api.openai.com/v1/chat/completions");

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": "문해력 학습용 단어 10개를 제공해주세요."}
      ],
      "max_tokens": 100,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final text = data['choices'][0]['message']['content'] as String;
    return text
        .split('\n')
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();
  } else {
    final error = jsonDecode(response.body);
    if (error['error']['code'] == 'insufficient_quota') {
      throw Exception("사용 가능한 쿼터가 초과되었습니다. OpenAI 요금제 및 청구 내역을 확인해주세요.");
    } else {
      throw Exception("단어를 가져오는 데 실패했습니다: ${response.body}");
    }
  }
}
