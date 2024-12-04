import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  signInWithGoogle() async {
    try {
      // Google 로그인
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
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Firestore에 사용자 데이터 저장
      await FirebaseFirestore.instance
          .collection('UserData') // 컬렉션 이름
          .doc(userCredential.user!.uid) // UID를 문서 ID로 사용
          .set({
        'email': userCredential.user!.email, // 이메일
        'createdAt': DateTime.now(), // 계정 생성 시간
        'currentMSG': '',
        'profileImg': 'https://ifh.cc/g/8AckGM.jpg', // 기본 프로필 이미지
        'purchased': [true, false, false, false, false, false],
        'removeAD': false,
        'win': 0,
        'loss': 0,
        'shopPt': 0,
        'rankPt': 0,
        'name': 'Player' // 기본 이름
      });

      print('로그인 및 Firestore 저장 성공');
      return userCredential;
    } catch (e) {
      print('로그인 실패: $e');
      return null;
    }
  }
}
