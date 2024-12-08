import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:opendemo/Main/Login/services/reset_password.dart';
import '../../main.dart';
import '../component/button.dart';
import '../component/squaretitle.dart';
import '../component/textfield.dart';
import '../services/auth.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text edit controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //로그인 함수
// 로그인 함수
  void signUserIn() async {

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ErrorMessage('이메일과 비밀번호를 입력해주세요.');
      return;
    }
    //로딩 화면
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    //로그인 정보 전달
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // 로그인 성공 후 로딩 다이얼로그 닫기
      Navigator.pop(context);

      // 로그인 성공 후 메인 페이지로 이동 (여기서 적절한 페이지로 이동)
      // 예를 들어, `Navigator.pushReplacement`를 사용할 수 있습니다.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()), // MainPage()는 메인 페이지로 변경
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // 로그인 실패 시 로딩 다이얼로그 닫기

      // 에러 코드에 따라 문구를 분기 처리
      String errorMessage;
      if (e.code == 'invalid-email') {
        errorMessage = '유효하지 않은 이메일 형식입니다.';
      } else if (e.code == 'user-not-found') {
        errorMessage = '등록되지 않은 이메일입니다.';
      } else if (e.code == 'wrong-password') {
        errorMessage = '비밀번호가 잘못되었습니다.';
      } else if (e.code == 'user-disabled') {
        errorMessage = '사용이 중지된 계정입니다.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = '네트워크 연결에 문제가 발생했습니다.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = '요청이 너무 많습니다. 잠시 후 다시 시도하세요.';
      } else {
        errorMessage = '알 수 없는 오류가 발생했습니다. (${e.code})';
      }

      ErrorMessage(errorMessage); // 에러 메시지 출력 함수
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
                const SizedBox(height: 50),
                //로고
                const Icon(
                  Icons.auto_stories,
                  size: 100,
                ),

                const SizedBox(height: 50),

                Text(
                  '환영합니다.',
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () { ResetPasswordDialog.showResetPasswordDialog(context);},
                        child: Text(
                          '비밀번호를 잊어버렸나요?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                //로그인 버튼
                MyButton(
                  text: "로그인",
                  onTap: signUserIn,
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
                        onTap: () async {
                          final userCredential = await AuthService().signInWithGoogle();
                          if (userCredential != null) {
                            print('로그인 성공: ${userCredential.user!.email}');
                          } else {
                            print('로그인 실패');
                          }
                        },
                        imagePath: 'assets/images/google.png'),

                    //SizedBox(width: 25),

                    //그외
                    //SquareTitle(imagePath: 'lib/images/google.png'),
                  ],
                ),

                const SizedBox(height: 50),

                //회원가입

                Row(
                  children: [
                    Text(
                      '  회원가입한 적이 없나요?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        '지금 회원가입 하세요',
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
