import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

// 데이터 저장 함수
Future<void> saveDataSecure(String key, String value) async {
  await _storage.write(key: key, value: value);
}

// 데이터 불러오기 함수
Future<String?> loadDataSecure(String key) async {
  return await _storage.read(key: key);
}

// 데이터 삭제 함수
Future<void> deleteDataSecure(String key) async {
  await _storage.delete(key: key);
}

// 프로필 이미지 저장 함수
Future<void> saveProfileImage(String imagePath) async {
  await saveDataSecure('profileImage', imagePath);
}

// 프로필 이미지 불러오기 함수
Future<String?> loadProfileImage() async {
  return await loadDataSecure('profileImage');
}
