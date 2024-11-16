import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // debugPrint 사용을 위해

class KoreanDictionaryAPI {
  late final String kdsApiKey;
  final String kdsApiUrl = 'https://krdict.korean.go.kr/api/search';

  KoreanDictionaryAPI() {
    // API 키를 환경변수에서 불러오고, 누락된 경우 예외를 발생시킵니다.
    kdsApiKey = dotenv.env['api.KDKEY'] ?? '';
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
        debugPrint('단어: $word');  // 단어가 잘 추출되는지 확인

        // <sense> 태그를 찾아 정의 추출
        var senses = item.findElements('sense');
        for (var sense in senses) {
          var definition = sense.findElements('definition').map((e) => e.text).join(', ');
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

class OpenAIAPI {
  late final String openAIApiKey;
  final String openAIUrl = 'https://api.openai.com/v1/completions';
  static const String openAIModel = 'text-davinci-003'; // 모델 이름을 상수로 지정

  OpenAIAPI() {
    openAIApiKey = dotenv.env['api.OAKEY'] ?? '';
    if (openAIApiKey.isEmpty) {
      throw Exception("OpenAI API Key is missing.");
    }
  }

  Future<String> generateQuestion(String word, String definition) async {
    try {
      final response = await http.post(
        Uri.parse(openAIUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIApiKey',
        },
        body: jsonEncode({
          'model': openAIModel,
          'prompt': '단어 "$word"의 뜻은 "$definition"입니다. 이 단어를 사용하여 국어 문제를 만들어 주세요.',
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'];
        if (choices != null && choices.isNotEmpty) {
          return choices[0]['text'].toString().trim();
        } else {
          return '응답이 없습니다.';
        }
      } else {
        return 'OpenAI API 호출 실패: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('OpenAI API 호출 오류: $e');
      return '질문 생성 중 오류가 발생했습니다.';
    }
  }
}
