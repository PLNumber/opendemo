import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../component/button.dart';
import '../component/squaretitle.dart';
import '../component/textfield.dart';
import '../services/auth.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  RegisterPage({
    super.key,
    required this.onTap,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text edit controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //회원가입
  void signUserUp() async {
    // 로딩 화면
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // 비밀번호 일치 확인
      if (passwordController.text == confirmPasswordController.text) {
        // Firebase Authentication에 계정 생성
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Firestore에 UID를 이름으로 하는 문서 생성
        await FirebaseFirestore.instance
            .collection('UserData') // 컬렉션 이름
            .doc(userCredential.user!.uid) // UID를 문서 ID로 사용
            .set({
          'email': emailController.text,
          'createdAt': DateTime.now(), // 계정 생성 시간,
          'currentMSG' : '',
          'profileImg' : 'https://ifh.cc/g/8AckGM.jpg',
          'purchased' : [true, false, false, false, false, false],
          'removeAD' : false,
          'win' : 0,
          'loss' : 0,
          'shopPt' : 0,
          'rankPt' : 0
        });

        print("Firestore에 사용자 문서가 생성되었습니다.");
      } else {
        // 비밀번호 불일치 에러 처리
        ErrorMessage("비밀번호가 일치하지 않습니다.");
      }

      Navigator.pop(context); // 로딩 화면 닫기
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // 로딩 화면 닫기
      ErrorMessage(e.code); // 에러 메시지 출력
    } catch (e) {
      Navigator.pop(context); // 로딩 화면 닫기
      ErrorMessage("알 수 없는 오류가 발생했습니다."); // 일반적인 오류 처리
      print(e);
    }
  }

  //에러 메시지 출력 함수
  void ErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); //창 닫기
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      //상단 상태창 침범하지 않는 용도
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                //로고
                const Icon(
                  Icons.auto_stories,
                  size: 100,
                ),

                const SizedBox(height: 25),

                Text(
                  '회원가입을 진행하세요.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // 이메일 입력칸
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //비밀번호 입력칸
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                //비밀번호 확인칸
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                //회원가입 버튼
                MyButton(
                  text: '회원 가입',
                  onTap: signUserUp,
                ),

                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //구글로 로그인 버튼
                    SquareTitle(
                        onTap: () => AuthService().signInWithGoogle(),
                        imagePath: 'assets/images/google.png'),

                    // SizedBox(width: 25),

                    //그외
                    //SquareTitle(imagePath: 'lib/images/google.png'),
                  ],
                ),

                const SizedBox(height: 50),

                //회원가입

                Row(
                  children: [
                    Text(
                      '계정이 이미 있나요?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        '지금 로그인 하세요',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
