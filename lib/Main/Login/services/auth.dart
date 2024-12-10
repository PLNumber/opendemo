import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용

class AuthService {
  // Google 로그인 함수
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // 웹 환경에서 Google 로그인
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // 팝업 방식 로그인
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleProvider);

        // Firestore에 사용자 데이터 저장
        await _saveUserDataToFirestore(userCredential);

        print('웹에서 Google 로그인 성공');
        return userCredential;
      } else {
        // 앱 환경에서 Google 로그인
        final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
        if (gUser == null) {
          print('Google 로그인 취소됨');
          return null;
        }

        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        // Firebase Credential 생성
        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        // Firebase Auth 로그인
        final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        // Firestore에 사용자 데이터 저장
        await _saveUserDataToFirestore(userCredential);

        print('앱에서 Google 로그인 성공');
        return userCredential;
      }
    } catch (e) {
      print('Google 로그인 실패: $e');
      return null;
    }
  }

  // Firestore에 사용자 데이터 저장
  // Firestore에 사용자 데이터 저장
  Future<void> _saveUserDataToFirestore(UserCredential userCredential) async {
    final userDoc = FirebaseFirestore.instance
        .collection('UserData')
        .doc(userCredential.user!.uid);

    final docSnapshot = await userDoc.get();

    // 사용자 데이터가 존재하지 않을 때만 저장
    if (!docSnapshot.exists) {
      await userDoc.set({
        'email': userCredential.user!.email,
        'createdAt': DateTime.now(),
        'currentMSG': '',
        'profileImg': 'https://ifh.cc/g/8AckGM.jpg',
        'purchased': [true, false, false, false, false, false],
        'removeAD': false,
        'win': 0,
        'loss': 0,
        'shopPt': 0,
        'rankPt': 100,
        'name': 'Player',
      });
      print('Firestore에 새 사용자 데이터 저장 완료');
    } else {
      print('Firestore에 이미 데이터가 존재합니다. 저장을 건너뜁니다.');
    }
  }

}
