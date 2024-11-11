import 'dart:convert';
import 'package:http/http.dart' as http;

/*한국어 기초 대사전 api*/
class KoreanDictionaryService {
  final String kdsApiKey = '646F0B38023B534EE9BE9EA279A3B7CD';
  final String kdsApiUrl = 'https://opendict.korean.go.kr/api/search';

  Future<Map<String, dynamic>> searchWord(String word) async {
    final response = await http.get(Uri.parse(
        '$kdsApiUrl?key=$kdsApiKey&type_search=search&part=word&q=$word'
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }
}

/*openai api*/
class OpenAIService {
  final String oaApiKey = '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';
  final String oaApiUrl = 'https://api.openai.com/v1/completions';

  Future<String> generateQuestion(String word, String definition) async {
    final response = await http.post(
      Uri.parse(oaApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $oaApiKey',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt':
        '단어 "$word"의 뜻은 "$definition"입니다. 이 단어를 사용하여 국어 문제를 만들어 주세요.',
        'max_tokens': 100,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['text'].toString().trim();
    } else {
      throw Exception('Failed to load data');
    }
  }
}