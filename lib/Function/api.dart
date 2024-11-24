import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // debugPrint 사용을 위해
import 'package:html/parser.dart' as html; // HTML 파서 추가

class KoreanDictionaryAPI {
  late final String kdsApiKey;
  final String kdsApiUrl = 'https://opendict.korean.go.kr/api/search';

  KoreanDictionaryAPI() {
    kdsApiKey = dotenv.env['api.URSKEY'] ?? '';
    if (kdsApiKey.isEmpty) {
      throw Exception("Korean Dictionary API Key is missing.");
    }
  }

  // 단어 정의를 검색하는 함수
  Future<List<Map<String, String>>> search(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$kdsApiUrl?key=$kdsApiKey&q=$query'),
      );

      if (response.statusCode == 200) {
        return _parseXmlResponse(response.body);
      } else {
        debugPrint('API 호출 실패: ${response.statusCode}');
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API 호출 오류: $e');
      throw Exception('API 호출 중 오류가 발생했습니다.');
    }
  }

  // HTML 태그를 제거하는 함수
  String _removeHtmlTags(String definition) {
    final RegExp regExp = RegExp(r'<[^>]*>');
    return definition.replaceAll(regExp, '').trim();
  }

  // HTML 엔티티를 디코드하는 함수
  String _decodeHtmlEntities(String definition) {
    return html.parse(definition).body!.text.trim(); // 인스턴스 생성 없이 사용
  }

  // XML 응답을 파싱하여 단어와 정의를 리스트로 반환하는 함수
  List<Map<String, String>> _parseXmlResponse(String responseBody) {
    try {
      var document = XmlDocument.parse(responseBody);
      debugPrint('응답 XML: $responseBody');

      var items = document.findAllElements('item');
      List<Map<String, String>> definitionsList = [];

      for (var item in items) {
        var word = item.findElements('word').first.text;
        var senses = item.findElements('sense');
        for (var sense in senses) {
          var definition = sense.findElements('definition').map((e) => e.text).join(', ');
          definition = _removeHtmlTags(definition); // HTML 태그 제거
          definition = _decodeHtmlEntities(definition); // HTML 엔티티 디코드
          definitionsList.add({
            'word': word,
            'definition': definition,
          });
        }
      }

      return definitionsList.isEmpty
          ? [{'word': '결과가 없습니다.', 'definition': ''}]
          : definitionsList;
    } catch (e) {
      debugPrint('XML 파싱 오류: $e');
      return [{'word': '파싱 오류', 'definition': '파싱 오류가 발생했습니다.'}];
    }
  }
}
