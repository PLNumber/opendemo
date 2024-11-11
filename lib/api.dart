import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KoreanDictionaryAPI {
  late final String kdsApiKey;
  late final String openAiApiKey;
  final String kdsApiUrl = 'https://krdict.korean.go.kr/api/search';

  KoreanDictionaryAPI() {
    // .env 파일에서 API 키를 가져옵니다.
    kdsApiKey = dotenv.env['api.KDKEY'] ?? '';
    openAiApiKey = dotenv.env['api.OAKEY'] ?? '';
  }

  // 단어 정의를 검색하는 함수
  Future<String> search(String query) async {
    final response = await http.get(
      Uri.parse('$kdsApiUrl?key=$kdsApiKey&q=$query'),
    );

    // 응답 상태 확인
    if (response.statusCode == 200) {
      try {
        // XML 문서 파싱
        var document = XmlDocument.parse(response.body);

        // 응답 XML을 로그로 출력하여 내용 확인
        print('응답 XML: ${response.body}'); // 응답 XML 로그 확인

        // <item> 태그를 찾아 각 단어의 정의 추출
        var items = document.findAllElements('item');
        String definitions = '';

        if (items.isEmpty) {
          return '결과가 없습니다.';
        }

        for (var item in items) {
          // 단어 추출
          var word = item.findElements('word').first.text;
          print('단어: $word');  // 단어가 잘 추출되는지 확인

          // <sense> 태그를 찾아 정의 추출
          var senses = item.findElements('sense');
          for (var sense in senses) {
            var definition = sense.findElements('definition').map((e) => e.text).join(', ');
            definitions += '$word: $definition\n'; // 단어와 정의를 조합하여 추가
          }
        }

        return definitions.isEmpty ? '정의가 없습니다.' : definitions;
      } catch (e) {
        print('파싱 오류: $e');
        return '파싱 오류가 발생했습니다.';
      }
    } else {
      return 'API 호출 실패: ${response.statusCode}';
    }
  }
}
